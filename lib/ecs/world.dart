import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/ecs/spatial/spatial_index.dart';
import 'package:rogueverse/ecs/spatial/spatial_service.dart';

part 'world.mapper.dart';

/// A simple Event marker to be used to hook into pre-tick processing.
class PreTickEvent {
  /// ID of the current tick being process.
  final int tickId;

  PreTickEvent(this.tickId);
}

/// A simple Event marker to be used to hook into pre-tick processing.
class PostTickEvent {
  /// ID of the current tick being process.
  final int tickId;

  PostTickEvent(this.tickId);
}

/// Interface for World and View classes to ensure consistent API.
/// Provides core entity and component operations with change notifications.
///
/// The base [componentChanges] stream provides all component change events.
/// Use the [ChangeStreamFilters] extension methods for filtered subscriptions.
abstract interface class IWorldView {
  // Read operations
  Entity getEntity(int entityId);
  List<Entity> entities();
  Map<int, C> get<C extends Component>();
  Map<int, Component> getByName(String componentType);

  // Write operations
  Entity add(List<Component> comps);
  void remove(int entityId);

  // Notifications - base stream only, use extension methods for filtering
  Stream<Change> get componentChanges;
}

@MappableClass()
class World with WorldMappable implements IWorldView {
  static final _logger = Logger('World');

  int tickId = 0;
  int lastId = 0;
  final List<System> systems;

  /// Event bus for component change notifications.
  /// Not serialized - recreated on world creation.
  final ComponentEventBus _events = ComponentEventBus();

  @override
  Stream<Change> get componentChanges => _events.changes;

  void notifyChange(Change change) {
    _events.emit(change);
  }

  @MappableField(hook: ComponentsHook())
  Map<String, Map<int, Component>> components;

  /// Storage wrapper for component operations.
  /// Not serialized - wraps the `components` map.
  late final ComponentStorage _storage;

  /// Template resolver for inheritance logic.
  /// Not serialized - recreated on world creation.
  late final TemplateResolver templateResolver;

  /// Reactive service for fast parent-child hierarchy queries.
  /// Not serialized - rebuilt from HasParent components on world load.
  late final HierarchyService _hierarchyService;

  /// Convenience accessor for hierarchy queries.
  /// The service is lazily initialized on first access.
  HierarchyService get hierarchyCache {
    _hierarchyService.ensureInitialized();
    return _hierarchyService;
  }

  /// Cache for Entity wrapper objects to avoid creating new instances on every getEntity() call
  /// Not serialized - Entity objects are lightweight wrappers around data
  final Map<int, Entity> _entityCache = {};

  /// Shared spatial index service for position-based queries.
  /// Not serialized - rebuilt from LocalPosition components on world load.
  late final SpatialService _spatialService;

  /// Convenience accessor for the spatial index.
  /// Use this for O(1) position lookups instead of scanning all entities.
  SpatialIndex get spatial {
    _spatialService.ensureInitialized();
    return _spatialService.index;
  }

  /// Systems sorted by dependency order.
  /// Computed once at startup via topological sort.
  late final List<System> _sortedSystems;

  World(this.systems, this.components, [this.tickId = 0, this.lastId = 0]) {
    _storage = ComponentStorage(components, lastId);
    templateResolver = TemplateResolver(
      getComponents: () => components,
      getEntity: getEntity,
      notifyChange: notifyChange,
      componentChanges: componentChanges,
    );
    _hierarchyService = HierarchyService(this);
    _spatialService = SpatialService(this);
    _sortedSystems = _topologicalSort(systems);
  }

  /// Topologically sorts systems based on their declared dependencies.
  ///
  /// Uses Kahn's algorithm to produce a valid execution order where each
  /// system runs after all systems listed in its [System.runAfter].
  ///
  /// Throws [StateError] if circular dependencies are detected.
  List<System> _topologicalSort(List<System> systems) {
    if (systems.isEmpty) return [];

    // Build a map from Type to System instance
    final typeToSystem = <Type, System>{};
    for (final system in systems) {
      typeToSystem[system.runtimeType] = system;
    }

    // Build adjacency list and in-degree count
    // If A.runAfter contains B, then B -> A (B must run before A)
    final inDegree = <Type, int>{};
    final dependents = <Type, Set<Type>>{}; // B -> {A} means A depends on B

    for (final system in systems) {
      final type = system.runtimeType;
      inDegree.putIfAbsent(type, () => 0);
      dependents.putIfAbsent(type, () => {});

      for (final dependency in system.runAfter) {
        if (!typeToSystem.containsKey(dependency)) {
          _logger.warning(
            'System ${system.runtimeType} declares dependency on $dependency, '
            'but no such system is registered. Ignoring dependency.',
          );
          continue;
        }
        dependents.putIfAbsent(dependency, () => {}).add(type);
        inDegree[type] = (inDegree[type] ?? 0) + 1;
      }
    }

    // Kahn's algorithm: start with systems that have no dependencies
    final queue = <Type>[];
    for (final entry in inDegree.entries) {
      if (entry.value == 0) {
        queue.add(entry.key);
      }
    }

    final sorted = <System>[];
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      sorted.add(typeToSystem[current]!);

      for (final dependent in dependents[current] ?? <Type>{}) {
        inDegree[dependent] = inDegree[dependent]! - 1;
        if (inDegree[dependent] == 0) {
          queue.add(dependent);
        }
      }
    }

    // Check for cycles
    if (sorted.length != systems.length) {
      final remaining = systems
          .where((s) => !sorted.contains(s))
          .map((s) => s.runtimeType.toString())
          .toList();
      throw StateError(
        'Circular dependency detected among systems: $remaining. '
        'Check runAfter declarations for cycles.',
      );
    }

    _logger.info(
      'Systems sorted by dependencies',
      {'order': sorted.map((s) => s.runtimeType.toString()).toList()},
    );

    return sorted;
  }

  /// Get all entity IDs that depend on a given template.
  /// Delegates to TemplateResolver.
  Set<int> getTemplateDependents(int templateId) {
    return templateResolver.getDependents(templateId);
  }

  @override
  Entity getEntity(int entityId) {
    return _entityCache.putIfAbsent(
      entityId,
      () {
        _logger.finest("entity not in cache", {"entityId": entityId});
        return Entity(parentCell: this, id: entityId);
      },
    );
  }

  @override
  List<Entity> entities() {
    return _storage.allEntityIds.map((id) => getEntity(id)).toList();
  }

  @override
  Map<int, C> get<C extends Component>() {
    return _storage.get<C>();
  }

  @override
  Map<int, Component> getByName(String componentType) {
    return _storage.getByName(componentType);
  }

  @override
  Entity add(List<Component> comps) {
    var entityId = _storage.createEntityId();
    lastId = _storage.lastId; // Keep lastId in sync for serialization

    for (var c in comps) {
      _storage.set(entityId, c);
      notifyChange(Change(
          entityId: entityId,
          componentType: c.componentType,
          oldValue: null,
          newValue: c));
    }

    return getEntity(entityId);
  }

  @override
  void remove(int entityId) {
    for (var entityComponentMap in components.entries) {
      var entry = entityComponentMap.value.entries
          .firstWhereOrNull((e) => e.key == entityId);
      if (entry != null) {
        entityComponentMap.value.remove(entry.key);
        notifyChange(Change(
            entityId: entityId,
            componentType: entry.value.componentType,
            oldValue: entry.value,
            newValue: null));
      }
    }

    // Clear entity from cache when destroyed
    _entityCache.remove(entityId);
  }

  /// Reloads the world state from a JSON map, keeping the same World instance.
  ///
  /// This allows components holding references to this World to see the new state
  /// without needing to be recreated. Used for editor mode switching.
  ///
  /// Emits change notifications for all affected components so listeners can update.
  void loadFrom(Map<String, dynamic> jsonMap) {
    _logger.info("reloading world state from map");

    // Capture old state for change notifications
    final oldComponents = <String, Map<int, Component>>{};
    for (final entry in components.entries) {
      oldComponents[entry.key] = Map.from(entry.value);
    }

    // Clear current state
    _storage.clear();
    _entityCache.clear();

    // Deserialize new state using the mapper
    final newWorld = WorldMapper.fromMap(jsonMap);

    // Copy state from the new world
    _storage.loadFrom(newWorld.components);
    _storage.lastId = newWorld.lastId;
    tickId = newWorld.tickId;
    lastId = newWorld.lastId;

    // Rebuild hierarchy service (clears and resubscribes)
    _hierarchyService.resetState();

    // Reinitialize template resolver index
    templateResolver.reinitialize();

    // Reset the shared spatial index (must happen before system resets)
    _spatialService.resetState();

    // Reset systems that maintain their own state (e.g., dirty flagging, queues)
    // Must happen before emitting changes so subscribers see fresh data
    for (final system in systems) {
      if (system is VisionSystem) {
        system.resetState(this);
      }
    }

    // Emit change notifications for all affected components
    _emitLoadChanges(oldComponents, components);

    _logger.info("world state reloaded", {"entityCount": entities().length});
  }

  /// Emits change notifications comparing old and new component states.
  void _emitLoadChanges(
    Map<String, Map<int, Component>> oldComponents,
    Map<String, Map<int, Component>> newComponents,
  ) {
    // Collect all component types from both old and new
    final allTypes = {...oldComponents.keys, ...newComponents.keys};

    for (final componentType in allTypes) {
      final oldMap = oldComponents[componentType] ?? {};
      final newMap = newComponents[componentType] ?? {};
      final allEntityIds = {...oldMap.keys, ...newMap.keys};

      for (final entityId in allEntityIds) {
        final oldValue = oldMap[entityId];
        final newValue = newMap[entityId];

        // Skip only if both are null (no component existed before or after)
        if (oldValue == null && newValue == null) continue;

        // Emit change for all other cases (added, removed, or potentially updated)
        // We don't check equality since deserialized objects may not have
        // proper equality implementation, and it's safer to over-notify
        notifyChange(Change(
          entityId: entityId,
          componentType: componentType,
          oldValue: oldValue,
          newValue: newValue,
        ));
      }
    }
  }

  /// Executes a single ECS update tick.
  ///
  /// Systems are executed in dependency order (computed once at startup).
  void tick() {
    Timeline.timeSync("World: tick", () {
      _logger.fine("processing tick", {"tickId": tickId});

      clearLifetimeComponents<BeforeTick>();

      Timeline.timeSync("World: process systems", () {
        // Systems are pre-sorted by dependency order in constructor
        for (var s in _sortedSystems) {
          Timeline.timeSync("World: process ${s.runtimeType}", () {
            _logger.fine("processing system", {"system": s.runtimeType.toString()});
            s.update(this);
          });
        }
      });

      clearLifetimeComponents<AfterTick>();

      _logger.fine("processed tick", {"tickId": tickId});
      tickId++;
    });
  }

    void clearLifetimeComponents<T extends Lifetime>() {
      Timeline.timeSync("World: clear $T", () {
        for (var componentMap in components.values) {
          var entries = Map.of(componentMap)
              .entries; // Create copy since we'll be modifying the actual map.

          for (var entityToComponent in entries) {
            if (entityToComponent.value is T &&
                (entityToComponent.value as T).tick()) {
              // if is BeforeTick and is dead, remove.
              componentMap.remove(entityToComponent.key);

              notifyChange(Change(
                  entityId: entityToComponent.key,
                  componentType: entityToComponent.value.componentType,
                  oldValue: entityToComponent.value,
                  newValue: null));
            }
          }
        }
      });
  }

  /// Dispose of world resources.
  void dispose() {
    _events.dispose();
    templateResolver.dispose();
    _hierarchyService.dispose();
    _spatialService.dispose();
  }
}



/// A dart_mappable hook to handle de/serializing the complex map (for JSON).
/// Necessary as we cannot use integers as JSON keys, so we convert to/from strings instead.
class ComponentsHook extends MappingHook {
  const ComponentsHook();

  /// Receives the encoded value before decoding.
  /// Converts JSON string keys to integers and decodes components.
  @override
  Object? beforeDecode(Object? value) {
    var comps = value as Map<String, dynamic>;
    final result = <String, Map<int, Component>>{};

    for (final typeEntry in comps.entries) {
      final componentType = typeEntry.key;
      final entityMap = typeEntry.value as Map<String, dynamic>;
      final decodedMap = <int, Component>{};

      for (final entityEntry in entityMap.entries) {
        final entityId = int.parse(entityEntry.key);
        final compData = entityEntry.value as Map<String, dynamic>;
        final component = MapperContainer.globals.fromMap<Component>(compData);
        decodedMap[entityId] = component;
      }

      if (decodedMap.isNotEmpty) {
        result[componentType] = decodedMap;
      }
    }

    return result;
  }

  /// Receives the decoded value before encoding.
  /// Converts integer keys to strings for JSON compatibility.
  @override
  Object? beforeEncode(Object? value) {
    var comps = value as Map<String, Map<int, Component>>;
    return comps.map((type, entityMap) => MapEntry(
        type,
        entityMap.map((id, comp) =>
            MapEntry(id.toString(), MapperContainer.globals.toMap(comp)))));
  }
}
