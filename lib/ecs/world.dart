import 'dart:async' show StreamController;
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:json_patch/json_patch.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rogueverse/ecs/ecs.dart';

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

/// Cache for fast parent-child relationship queries in the entity hierarchy.
///
/// Maintains bidirectional indices for quick lookups without scanning all entities.
/// Rebuilt from component data each tick by HierarchySystem.
class HierarchyCache {
  /// Maps child entity ID to parent entity ID
  Map<int, int> childToParent = {};

  /// Maps parent entity ID to set of child entity IDs
  Map<int, Set<int>> parentToChildren = {};

  /// Flag to indicate cache needs rebuilding
  bool isDirty = true;

  /// Rebuild cache from world's HasParent components
  void rebuild(World world) {
    childToParent.clear();
    parentToChildren.clear();

    final parents = world.get<HasParent>();
    for (final entry in parents.entries) {
      final childId = entry.key;
      final parentId = entry.value.parentEntityId;

      childToParent[childId] = parentId;
      parentToChildren.putIfAbsent(parentId, () => {}).add(childId);
    }

    isDirty = false;
  }

  /// Get all children of a parent entity
  Set<int> getChildren(int parentId) {
    return parentToChildren[parentId] ?? {};
  }

  /// Get parent of a child entity (null if no parent)
  int? getParent(int childId) {
    return childToParent[childId];
  }

  /// Get all children that have a specific component
  List<Entity> getChildrenWith<C extends Component>(World world, int parentId) {
    return getChildren(parentId)
        .map((id) => world.getEntity(id))
        .where((e) => e.has<C>())
        .toList();
  }

  /// Get all sibling entities (entities with same parent)
  Set<int> getSiblings(int entityId) {
    final parentId = getParent(entityId);
    if (parentId == null) return {};

    return getChildren(parentId).where((id) => id != entityId).toSet();
  }
}

@MappableClass()
class World with WorldMappable implements IWorldView {
  static final _logger = Logger('World');
  
  int tickId = 0; // TODO not de/serializing to json/map?
  int lastId = 0; // TODO not de/serializing to json/map?
  final List<System> systems;

  final _componentChanges = StreamController<Change>.broadcast(sync: true);
  
  @override
  Stream<Change> get componentChanges => _componentChanges.stream;

  void notifyChange(Change change) {
    _componentChanges.add(change);
  }

  @MappableField(hook: ComponentsHook())
  Map<String, Map<int, Component>> components;

  /// Cache for fast parent-child hierarchy queries
  /// Not serialized - rebuilt from HasParent components on world load
  final HierarchyCache hierarchyCache = HierarchyCache();

  /// Cache for Entity wrapper objects to avoid creating new instances on every getEntity() call
  /// Not serialized - Entity objects are lightweight wrappers around data
  final Map<int, Entity> _entityCache = {};

  World(this.systems, this.components, [this.tickId = 0, this.lastId = 0]);

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
    var entityIds = <int>{};

    for (var componentMap in components.values) {
      entityIds.addAll(componentMap.keys);
    }
    return entityIds.map((id) => getEntity(id)).toList();
  }

  @override
  Map<int, C> get<C extends Component>() {
    return components.putIfAbsent(C.toString(), () => {}).cast<int, C>();
  }

  @override
  Map<int, Component> getByName(String componentType) {
    return components
        .putIfAbsent(componentType, () => {})
        .cast<int, Component>();
  }

  @override
  Entity add(List<Component> comps) {
    var entityId = lastId++;
    for (var c in comps) {
      var entitiesWithComponent =
          components.putIfAbsent(c.componentType, () => {});
      entitiesWithComponent[entityId] = c;
      notifyChange(Change(
          entityId: entityId,
          componentType: c.componentType,
          oldValue: null,
          newValue: c));
    }

    // TODO notify on creation of new entitiy, separate from the component notifications?
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

    // TODO notify on deletion of an entity, separate from the component notifications?
  }

  /// Reloads the world state from a JSON map, keeping the same World instance.
  ///
  /// This allows components holding references to this World to see the new state
  /// without needing to be recreated. Used for editor mode switching.
  void loadFrom(Map<String, dynamic> jsonMap) {
    _logger.info("reloading world state from map");

    // Clear current state
    components.clear();
    _entityCache.clear();

    // Deserialize new state using the mapper
    final newWorld = WorldMapper.fromMap(jsonMap);

    // Copy state from the new world
    components.addAll(newWorld.components);
    tickId = newWorld.tickId;
    lastId = newWorld.lastId;

    // Rebuild hierarchy cache (also clears it internally)
    hierarchyCache.rebuild(this);

    _logger.info("world state reloaded", {"entityCount": entities().length});
  }

  /// Executes a single ECS update tick.
    void tick() {
      Timeline.timeSync("World: tick", () {
        _logger.fine("processing tick", {"tickId": tickId});

        // TODO pre-tick notification???
        clearLifetimeComponents<
            BeforeTick>(); // TODO would be cool to find a better way of pulling this out from the class.

        Timeline.timeSync("World: process systems", () {
          // Sort systems by priority (lower numbers run first)
          final sortedSystems = systems.toList()
            ..sort((a, b) => a.priority.compareTo(b.priority));
          
          for (var s in sortedSystems) {
            Timeline.timeSync("World: process ${s.runtimeType}", () {
              _logger.fine("processing system", {"system": s.runtimeType.toString()});
              s.update(this);
            });
          }
        });

        clearLifetimeComponents<
            AfterTick>(); // TODO would be cool to find a better way of pulling this out from the class.

        _logger.fine("processed tick", {"tickId": tickId});
        tickId++; // TODO: wrap around to avoid out of bounds type error?
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
}



/// A dart_mappable hook to handle de/serializing the complex map (for JSON).
/// Necessary as we cannot use integers as JSON keys, so we convert to/from strings instead.
class ComponentsHook extends MappingHook {
  const ComponentsHook();

  /// Receives the ecoded value before decoding.
  @override
  Object? beforeDecode(Object? value) {
    //var comps = value as Map<String, Map<int, Component>>;
    var comps = value as Map<String, dynamic>;
    return comps.map((type, entityMap) {
      return MapEntry(
          type,
          entityMap.map((id, comp) =>
              MapEntry(id.toString(), MapperContainer.globals.fromMap(comp))));
    });
  }

  /// Receives the decoded value before encoding.
  @override
  Object? beforeEncode(Object? value) {
    var comps = value as Map<String, Map<int, Component>>;
    return comps.map((type, entityMap) => MapEntry(
        type,
        entityMap.map((id, comp) =>
            MapEntry(id.toString(), MapperContainer.globals.toMap(comp)))));
  }
}

class WorldSaves {
  static final Logger _logger = Logger("WorldSaves");

  /// In-memory copy of the initial state Map, used for computing save diffs.
  /// Set during loadInitialState() or loadSaveWithPatch().
  static Map<String, dynamic>? _cachedInitialState;

  /// Simple lock to prevent concurrent write operations.
  static bool _writeLock = false;

  /// Returns a read-only reference to the cached initial state.
  /// Throws if no initial state is loaded.
  static Map<String, dynamic> get initialState {
    if (_cachedInitialState == null) {
      throw StateError(
          'No initial state loaded. Call loadInitialState() or loadSaveWithPatch() first.');
    }
    return _cachedInitialState!;
  }

  /// Migrates existing save.json to initial.json if needed.
  /// Call this once during app startup before loading.
  static Future<void> migrateIfNeeded() async {
    var supportDir = await getApplicationSupportDirectory();
    var oldSaveFile = File("${supportDir.path}/save.json");
    var newInitialFile = File("${supportDir.path}/initial.json");

    // Only migrate if old file exists and new file doesn't
    if (oldSaveFile.existsSync() && !newInitialFile.existsSync()) {
      _logger.info("migrating save.json to initial.json");
      await oldSaveFile.rename(newInitialFile.path);
    }
  }

  /// Loads the initial state from initial.json.
  /// Caches the Map in memory for future diff computations.
  /// Returns null if initial.json doesn't exist.
  static Future<World?> loadInitialState() async {
    var task = TimelineTask(filterKey: "fileio");
    task.start("save: read initial");

    try {
      var supportDir = await getApplicationSupportDirectory();
      var initialFile = File("${supportDir.path}/initial.json");

      if (!initialFile.existsSync()) {
        _logger.info("no initial.json found");
        return null;
      }

      _logger.info(
          "loading initial state", {"path": "${supportDir.path}/initial.json"});
      var jsonContents = initialFile.readAsStringSync();

      // Cache the parsed Map for diffing later
      _cachedInitialState = jsonDecode(jsonContents) as Map<String, dynamic>;

      return WorldMapper.fromJson(jsonContents);
    } finally {
      task.finish();
    }
  }

  /// Loads the game by reading initial.json and applying save.patch.json.
  ///
  /// Flow:
  /// 1. Load initial.json (caches in memory)
  /// 2. If save.patch.json exists, apply it to get current state
  /// 3. Return the resulting World
  ///
  /// Throws if patch application fails.
  static Future<World?> loadSaveWithPatch() async {
    var task = TimelineTask(filterKey: "fileio");
    task.start("save: load with patch");

    try {
      var supportDir = await getApplicationSupportDirectory();
      var initialFile = File("${supportDir.path}/initial.json");
      var patchFile = File("${supportDir.path}/save.patch.json");

      // Step 1: Load initial state
      if (!initialFile.existsSync()) {
        _logger.info("no initial.json found");
        return null;
      }

      _logger.info("loading initial state", {"path": initialFile.path});
      var initialJson =
          jsonDecode(initialFile.readAsStringSync()) as Map<String, dynamic>;

      // Cache initial state for future diff operations (deep copy)
      _cachedInitialState =
          jsonDecode(jsonEncode(initialJson)) as Map<String, dynamic>;

      // Step 2: Apply patch if exists
      Map<String, dynamic> finalState;
      if (patchFile.existsSync()) {
        _logger.info("applying save patch", {"path": patchFile.path});
        var patchJson = jsonDecode(patchFile.readAsStringSync()) as List<dynamic>;
        var patchOps = patchJson.cast<Map<String, dynamic>>();

        // Apply RFC 6902 patch
        finalState = JsonPatch.apply(initialJson, patchOps, strict: false)
            as Map<String, dynamic>;
      } else {
        _logger.info("no save patch found, using initial state");
        finalState = initialJson;
      }

      // Step 3: Deserialize to World
      return WorldMapper.fromMap(finalState);
    } finally {
      task.finish();
    }
  }

  /// Computes the diff between initial state and current world,
  /// then writes the patch to save.patch.json.
  ///
  /// Uses the cached initial state from loadInitialState/loadSaveWithPatch.
  /// Throws StateError if no initial state is cached.
  static Future<void> writeSavePatch(World world) async {
    if (_writeLock) {
      _logger.warning("write operation already in progress, skipping");
      return;
    }
    _writeLock = true;

    var task = TimelineTask(filterKey: "fileio");
    task.start("save: write patch");

    try {
      if (_cachedInitialState == null) {
        throw StateError('Cannot write save patch: no initial state loaded.');
      }

      var supportDir = await getApplicationSupportDirectory();
      var patchFile = File("${supportDir.path}/save.patch.json");

      // Get current state as Map
      var currentState = world.toMap();

      // Compute RFC 6902 patch
      var patchOps = JsonPatch.diff(_cachedInitialState!, currentState);

      // Write patch to file
      _logger.info("writing save patch",
          {"path": patchFile.path, "opCount": patchOps.length});

      var patchJson = JsonEncoder.withIndent("\t").convert(patchOps);
      var writer = patchFile.openWrite();
      writer.write(patchJson);
      await writer.flush();
      await writer.close();
    } finally {
      _writeLock = false;
      task.finish();
    }
  }

  /// Writes the complete world state to initial.json.
  /// Used by the editor to save authored content.
  /// Also updates the cached initial state.
  static Future<void> writeInitialState(World world,
      [bool indent = true]) async {
    if (_writeLock) {
      _logger.warning("write operation already in progress, skipping");
      return;
    }
    _writeLock = true;

    var task = TimelineTask(filterKey: "fileio");
    task.start("save: write initial");

    try {
      var indentChar = indent ? "\t" : "";
      var worldMap = world.toMap();
      var saveState = JsonEncoder.withIndent(indentChar).convert(worldMap);
      var supportDir = await getApplicationSupportDirectory();
      var initialFile = File("${supportDir.path}/initial.json");

      _logger.info("writing initial state", {"path": initialFile.path});

      var writer = initialFile.openWrite();
      writer.write(saveState);
      await writer.flush();
      await writer.close();

      // Update cached initial state (deep copy)
      _cachedInitialState =
          jsonDecode(jsonEncode(worldMap)) as Map<String, dynamic>;
    } finally {
      _writeLock = false;
      task.finish();
    }
  }

  /// Clears the save patch file (used when editor changes make patch invalid).
  static Future<void> clearSavePatch() async {
    var supportDir = await getApplicationSupportDirectory();
    var patchFile = File("${supportDir.path}/save.patch.json");

    if (patchFile.existsSync()) {
      _logger.info("clearing save patch", {"path": patchFile.path});
      await patchFile.delete();
    }
  }

  /// Legacy method - kept for backward compatibility during transition.
  /// Prefer writeInitialState() for editor saves and writeSavePatch() for gameplay saves.
  @Deprecated('Use writeInitialState() or writeSavePatch() instead')
  static Future<void> writeSave(World world, [bool indent = true]) async {
    await writeInitialState(world, indent);
  }
}
