import 'dart:async' show StreamController;

import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/events.dart';

/// A reusable filter that can be built ahead of time to select
/// entities with specific component requirements.
///
/// You can require components (with optional predicates) or exclude
/// them (also with optional predicates).
///
/// Example:
/// ```dart
/// final query = Query()
///   ..require<LocalPosition>((pos) => pos.x == 3 && pos.y == 5)
///   ..require<Renderable>()
///   ..exclude<PlayerControlled>();
///
/// for (final entity in query.find(chunk)) {
///   // Only entities at (3,5) with Renderable and not PlayerControlled
/// }
/// ```
class Query {
  final Map<Type, bool Function(Component comp)?> _required = {};
  final Map<Type, bool Function(Component comp)?> _excluded = {};

  /// Require component [T] with optional [predicate].
  Query require<T extends Component>([bool Function(T comp)? predicate]) {
    _required[T] =
    predicate != null ? (dynamic comp) => predicate(comp as T) : null;
    return this;
  }

  /// Exclude component [T] with optional [predicate].
  Query exclude<T extends Component>([bool Function(T comp)? predicate]) {
    _excluded[T] =
    predicate != null ? (dynamic comp) => predicate(comp as T) : null;
    return this;
  }

  /// Returns all matching entities in the world.
  ///
  /// Uses a two-pass approach:
  /// 1. First pass: entities with required components directly
  /// 2. Second pass: entities with FromTemplate that might inherit required components
  ///
  /// This ensures entities using template inheritance are properly discovered.
  Iterable<Entity> find(World world) sync* {
    if (_required.isEmpty) {
      throw StateError('Query must have at least one required component.');
    }

    // Track yielded entity IDs to avoid duplicates
    final yielded = <int>{};

    // First pass: entities with the component directly
    // Find the smallest component set to iterate over for better performance.
    Type? smallestType;
    int smallestCount = double.maxFinite.toInt();

    for (final type in _required.keys) {
      final store = world.components[type.toString()] ?? {};
      final count = store.length;
      if (count < smallestCount) {
        smallestType = type;
        smallestCount = count;
      }
    }

    final store = world.components[smallestType.toString()] ?? {};

    for (final id in store.keys) {
      if (isMatching(world, id)) {
        yielded.add(id);
        yield world.getEntity(id);
      }
    }

    // Second pass: entities with FromTemplate that might inherit required components
    final fromTemplateMap = world.components['FromTemplate'] ?? {};
    for (final id in fromTemplateMap.keys) {
      if (yielded.contains(id)) continue; // Already checked
      if (isMatching(world, id)) {
        yielded.add(id);
        yield world.getEntity(id);
      }
    }
  }

  /// Returns matching entities from the provided list of allowed entity IDs.
  ///
  /// Since we're filtering by a known set of IDs, we simply iterate through
  /// them and check if they match (isMatching handles template resolution).
  Iterable<Entity> findFromIds(World world, List<int> possibleIds) sync* {
    if (_required.isEmpty) {
      throw StateError('Query must have at least one required component.');
    }

    for (final id in possibleIds) {
      if (isMatching(world, id)) {
        yield world.getEntity(id);
      }
    }
  }

  /// Returns the first matching entity or null.
  Entity? first(World world) => find(world).firstOrNull;

  bool any(World world) => find(world).firstOrNull != null;


  /// Checks if an entity matches this query, considering template inheritance.
  ///
  /// Uses Entity.hasType() and Entity.getByName() which resolve through
  /// templates via FromTemplate component.
  bool isMatching(World world, int entityId) {
    final entity = world.getEntity(entityId);

    for (final entry in _required.entries) {
      final type = entry.key;
      final predicate = entry.value;
      final typeName = type.toString();

      // Use entity.hasType which resolves through templates
      if (!entity.hasType(typeName)) return false;

      if (predicate != null) {
        // Use entity.getByName which resolves through templates
        final component = entity.getByName(typeName);
        if (component == null || !predicate(component)) {
          return false;
        }
      }
    }

    for (final entry in _excluded.entries) {
      final type = entry.key;
      final predicate = entry.value;
      final typeName = type.toString();

      // Use entity.hasType which resolves through templates
      if (!entity.hasType(typeName)) continue;

      final component = entity.getByName(typeName);
      if (component != null) {
        if (predicate == null || predicate(component)) {
          return false;
        }
      }
    }

    return true;
  }


  /// Returns true if the given [entity] matches the query.
  bool isMatchEntity(Entity entity) => isMatching(entity.parentCell, entity.id);

  /// Returns a copy of this query.
  Query copy() {
    final q = Query();
    q._required.addAll(_required);
    q._excluded.addAll(_excluded);
    return q;
  }
}

/// A filtered view of a World based on a Query.
/// Provides the same interface as World but only operates on entities matching the query.
/// Write operations (add/remove) affect the underlying World and may create entities
/// that don't match the view's query.
class View implements IWorldView {
  final World world;
  final Query query;

  /// Cached set of entity IDs currently matching the query
  final Set<int> _matchingEntities = {};
  
  /// Stream controller for view membership changes (entities entering/leaving)
  final _membershipChanges = StreamController<ViewMembershipChange>.broadcast(sync: true);
  
  /// Stream of entities entering or leaving this view
  Stream<ViewMembershipChange> get viewMembershipChanges => _membershipChanges.stream;

  View({required this.world, required this.query}) {
    _initializeCache();
    _setupChangeListener();
  }

  void _initializeCache() {
    _matchingEntities.clear();
    for (final entity in query.find(world)) {
      _matchingEntities.add(entity.id);
    }
  }

  void _setupChangeListener() {
    world.componentChanges.listen((change) {
      final wasMatching = _matchingEntities.contains(change.entityId);
      final isMatching = query.isMatching(world, change.entityId);

      if (isMatching && !wasMatching) {
        // Entity entered the view
        _matchingEntities.add(change.entityId);
        _membershipChanges.add(ViewMembershipChange(
          entityId: change.entityId,
          kind: ViewMembershipKind.entered,
        ));
      } else if (!isMatching && wasMatching) {
        // Entity left the view
        _matchingEntities.remove(change.entityId);
        _membershipChanges.add(ViewMembershipChange(
          entityId: change.entityId,
          kind: ViewMembershipKind.exited,
        ));
      }
    });
  }

  // Read operations - filtered by query
  
  @override
  Entity getEntity(int entityId) {
    return world.getEntity(entityId);
  }

  @override
  List<Entity> entities() {
    return _matchingEntities.map((id) => world.getEntity(id)).toList();
  }

  @override
  Map<int, C> get<C extends Component>() {
    final worldComponents = world.get<C>();
    return Map.fromEntries(
      worldComponents.entries.where((e) => _matchingEntities.contains(e.key))
    );
  }

  @override
  Map<int, Component> getByName(String componentType) {
    final worldComponents = world.getByName(componentType);
    return Map.fromEntries(
      worldComponents.entries.where((e) => _matchingEntities.contains(e.key))
    );
  }

  // Write operations - delegate to underlying world
  
  @override
  Entity add(List<Component> comps) {
    return world.add(comps);
  }

  @override
  void remove(int entityId) {
    world.remove(entityId);
  }

  // Notifications - filtered to only entities in the view
  // Use ChangeStreamFilters extension methods for additional filtering
  
  @override
  Stream<Change> get componentChanges {
    return world.componentChanges.where((c) => _matchingEntities.contains(c.entityId));
  }
}

enum ViewMembershipKind { entered, exited }

class ViewMembershipChange {
  final int entityId;
  final ViewMembershipKind kind;

  const ViewMembershipChange({
    required this.entityId,
    required this.kind,
  });
}

// class CachedQuery {
//   final Query _query;
//   final Registry _world;
//   final Set<int> _matching = {};
//   final List<Disposable> _subscriptions = [];
//
//   CachedQuery(this._query, this._world) {
//     _initialize();
//   }
//
//   void _initialize() {
//     // Listen for all relevant component types (added/updated/removed)
//     for (final type in _query._required.keys.followedBy(_query._excluded.keys)) {
//       _subscriptions.add(
//           _world.eventBus.on(type).listen((event) {
//             final id = event.id as int;
//
//             final matches = _query.isMatching(_world, id);
//             final exists = _matching.contains(id);
//
//             if (matches && !exists) {
//               _matching.add(id);
//             } else if (!matches && exists) {
//               _matching.remove(id);
//             }
//           }).asDisposable()
//       );
//     }
//
//     // Initial fill
//     for (final entity in _query.find(_world)) {
//       _matching.add(entity.id);
//     }
//   }
//
//   Iterable<Entity> get entities sync* {
//     for (final id in _matching) {
//       yield _world.getEntity(id);
//     }
//   }
//
//   void dispose() {
//     for (final d in _subscriptions) {
//       d.dispose();
//     }
//     _subscriptions.clear();
//   }
// }