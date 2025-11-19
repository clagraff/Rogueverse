import 'entity.dart';
import 'registry.dart';
import 'components.dart';

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

  /// Returns all matching entities in the [chunk].
  Iterable<Entity> find(Registry registry) sync* {
    if (_required.isEmpty) {
      throw StateError('Query must have at least one required component.');
    }

    final firstRequiredType = _required.keys.first;
    final store = registry.components.putIfAbsent(firstRequiredType, () => {});

    for (final id in store.keys) {
      if (isMatching(registry, id)) {
        yield registry.getEntity(id);
      }
    }
  }

  /// Returns matching entities in the [chunk] from the provided list of allowed entity IDs.
  Iterable<Entity> findFromIds(Registry registry, List<int> possibleIds) sync* {
    if (_required.isEmpty) {
      throw StateError('Query must have at least one required component.');
    }

    final firstRequiredType = _required.keys.first;
    final store = registry.components.putIfAbsent(firstRequiredType, () => {});

    for (final id in store.keys) {
      if (!possibleIds.contains(id)) {
        continue;
      }

      if (isMatching(registry, id)) {
        yield registry.getEntity(id);
      }
    }
  }

  /// Returns the first matching entity or null.
  Entity? first(Registry registry) => find(registry).firstOrNull;

  bool any(Registry registry) => find(registry).firstOrNull != null;


  bool isMatching(Registry registry, int entityId) {
    for (final entry in _required.entries) {
      final type = entry.key;
      final predicate = entry.value;
      final store = registry.components.putIfAbsent(type, () => {});
      if (!store.containsKey(entityId)) return false;

      if (predicate != null && !predicate(store[entityId]!)) { // TODO should we handle store[entityId]! better?
        return false;
      }
    }

    for (final entry in _excluded.entries) {
      final type = entry.key;
      final predicate = entry.value;
      final store = registry.components.putIfAbsent(type, () => {});
      if (!store.containsKey(entityId)) continue;

      if (predicate == null || predicate(store[entityId]!)) {  // TODO should we handle store[entityId]! better?
        return false;
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

// class CachedQuery {
//   final Query _query;
//   final Registry _registry;
//   final Set<int> _matching = {};
//   final List<Disposable> _subscriptions = [];
//
//   CachedQuery(this._query, this._registry) {
//     _initialize();
//   }
//
//   void _initialize() {
//     // Listen for all relevant component types (added/updated/removed)
//     for (final type in _query._required.keys.followedBy(_query._excluded.keys)) {
//       _subscriptions.add(
//           _registry.eventBus.on(type).listen((event) {
//             final id = event.id as int;
//
//             final matches = _query.isMatching(_registry, id);
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
//     for (final entity in _query.find(_registry)) {
//       _matching.add(entity.id);
//     }
//   }
//
//   Iterable<Entity> get entities sync* {
//     for (final id in _matching) {
//       yield _registry.getEntity(id);
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