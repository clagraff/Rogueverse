import 'dart:async' show StreamController, scheduleMicrotask;
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

  /// Reverse index: template entity ID -> set of entities with FromTemplate pointing to it.
  /// Used for efficient event propagation when templates change.
  /// Not serialized - rebuilt from FromTemplate components on world load.
  final Map<int, Set<int>> _templateDependents = {};

  World(this.systems, this.components, [this.tickId = 0, this.lastId = 0]) {
    _setupTemplateDependencyTracking();
    _setupTemplateChangeForwarding();
    _initializeTemplateDependencyIndex();
  }

  /// Sets up reactive tracking of FromTemplate component changes.
  /// Updates _templateDependents index when FromTemplate is added/removed/changed.
  void _setupTemplateDependencyTracking() {
    componentChanges.listen((change) {
      if (change.componentType != 'FromTemplate') return;

      // Handle FromTemplate removal or change (remove old mapping)
      if (change.oldValue != null) {
        final old = change.oldValue as FromTemplate;
        _templateDependents[old.templateEntityId]?.remove(change.entityId);
      }

      // Handle FromTemplate addition or change (add new mapping)
      if (change.newValue != null) {
        final newFt = change.newValue as FromTemplate;
        _templateDependents
            .putIfAbsent(newFt.templateEntityId, () => {})
            .add(change.entityId);
      }
    });
  }

  /// Sets up event propagation when template components change.
  /// When a template's component changes, emits synthetic Change events
  /// for all dependent entities so their listeners can update.
  void _setupTemplateChangeForwarding() {
    componentChanges.listen((change) {
      final entity = getEntity(change.entityId);
      // Only propagate from template entities
      if (!entity.has<IsTemplate>()) return;
      // Don't propagate FromTemplate changes themselves
      if (change.componentType == 'FromTemplate') return;
      // Don't propagate IsTemplate changes
      if (change.componentType == 'IsTemplate') return;
      // Don't propagate ExcludesComponent changes
      if (change.componentType == 'ExcludesComponent') return;

      // Defer propagation to avoid re-entrancy (can't fire events while firing)
      scheduleMicrotask(() {
        _propagateToAllDependents(change.entityId, change);
      });
    });
  }

  /// Propagates a component change from a template to all dependent entities.
  void _propagateToAllDependents(int templateId, Change originalChange) {
    final directDependents = _templateDependents[templateId] ?? {};
    for (final dependentId in directDependents) {
      final dependent = getEntity(dependentId);

      // Skip if dependent excludes this component
      final excludes = dependent.get<ExcludesComponent>();
      if (excludes?.excludedTypes.contains(originalChange.componentType) == true) {
        continue;
      }

      // Skip if dependent has its own override of this component
      final hasDirectComponent =
          components[originalChange.componentType]?.containsKey(dependentId) ?? false;
      if (hasDirectComponent) continue;

      // Emit synthetic change for this dependent
      notifyChange(Change(
        entityId: dependentId,
        componentType: originalChange.componentType,
        oldValue: originalChange.oldValue,
        newValue: originalChange.newValue,
      ));

      // Recursively propagate if this dependent is also a template
      if (dependent.has<IsTemplate>()) {
        _propagateToAllDependents(dependentId, originalChange);
      }
    }
  }

  /// Initializes the template dependency index from existing FromTemplate components.
  /// Called on world creation and after loadFrom().
  void _initializeTemplateDependencyIndex() {
    _templateDependents.clear();
    final fromTemplateMap = components['FromTemplate'] ?? {};
    for (final entry in fromTemplateMap.entries) {
      final ft = entry.value as FromTemplate;
      _templateDependents
          .putIfAbsent(ft.templateEntityId, () => {})
          .add(entry.key);
    }
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

    // Rebuild template dependency index
    _initializeTemplateDependencyIndex();

    // Reset and rebuild systems that maintain state (e.g., spatial indexes)
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

class WorldSaves {
  static final Logger _logger = Logger("WorldSaves");

  /// In-memory copy of the initial state Map, used for computing save diffs.
  /// Set during loadInitialState() or loadSaveWithPatch().
  static Map<String, dynamic>? _cachedInitialState;

  /// Simple lock to prevent concurrent write operations.
  static bool _writeLock = false;

  /// The path to the current save patch file for this game session.
  /// Set by loadSaveWithPatch() or setCurrentSavePath().
  /// Used by SaveSystem for periodic saves.
  static String? _currentSavePatchPath;

  /// Gets the current save patch path. Returns null if no save is loaded.
  static String? get currentSavePatchPath => _currentSavePatchPath;

  /// Sets the current save patch path for this game session.
  static void setCurrentSavePath(String? path) {
    _currentSavePatchPath = path;
    _logger.info("set current save path", {"path": path});
  }

  /// Returns a read-only reference to the cached initial state.
  /// Throws if no initial state is loaded.
  static Map<String, dynamic> get initialState {
    if (_cachedInitialState == null) {
      throw StateError(
          'No initial state loaded. Call loadInitialState() or loadSaveWithPatch() first.');
    }
    return _cachedInitialState!;
  }

  /// Migrates existing save files to new structure if needed.
  /// Call this once during app startup before loading.
  static Future<void> migrateIfNeeded() async {
    var supportDir = await getApplicationSupportDirectory();

    // Migration 1: save.json -> initial.json
    var oldSaveFile = File("${supportDir.path}/save.json");
    var newInitialFile = File("${supportDir.path}/initial.json");

    if (oldSaveFile.existsSync() && !newInitialFile.existsSync()) {
      _logger.info("migrating save.json to initial.json");
      await oldSaveFile.rename(newInitialFile.path);
    }

    // Migration 2: save.patch.json -> saves/default.patch.json
    var oldPatchFile = File("${supportDir.path}/save.patch.json");
    if (await oldPatchFile.exists()) {
      var savesDir = await getSavesDirectory();
      var newPatchFile = File("${savesDir.path}/default.patch.json");
      _logger.info("migrating save.patch.json to saves/default.patch.json");
      await oldPatchFile.rename(newPatchFile.path);
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

  /// Loads the game by reading initial.json and applying a save patch.
  ///
  /// [savePatchPath] - Optional path to the save patch file. If null, loads
  /// initial state only (no patch applied).
  ///
  /// Flow:
  /// 1. Load initial.json (caches in memory)
  /// 2. If savePatchPath provided and exists, apply it to get current state
  /// 3. Return the resulting World
  ///
  /// Throws if patch application fails.
  static Future<World?> loadSaveWithPatch([String? savePatchPath]) async {
    var task = TimelineTask(filterKey: "fileio");
    task.start("save: load with patch");

    try {
      var supportDir = await getApplicationSupportDirectory();
      var initialFile = File("${supportDir.path}/initial.json");

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

      // Store the current save path for this session
      _currentSavePatchPath = savePatchPath;

      // Step 2: Apply patch if exists
      Map<String, dynamic> finalState;
      if (savePatchPath != null) {
        var patchFile = File(savePatchPath);
        if (patchFile.existsSync()) {
          _logger.info("applying save patch", {"path": patchFile.path});
          var patchJson =
              jsonDecode(patchFile.readAsStringSync()) as List<dynamic>;
          var patchOps = patchJson.cast<Map<String, dynamic>>();

          // Apply RFC 6902 patch
          try {
            finalState = JsonPatch.apply(initialJson, patchOps, strict: false)
                as Map<String, dynamic>;
          } catch (e) {
            _logger.warning(
                "Failed to apply save patch - initial state may have changed. "
                "Discarding patch and using initial state only.",
                {"error": e.toString(), "patchPath": patchFile.path});
            // Fall back to initial state without patch
            finalState = initialJson;
          }
        } else {
          _logger.info("save patch file not found, using initial state",
              {"path": savePatchPath});
          finalState = initialJson;
        }
      } else {
        _logger.info("no save patch path provided, using initial state");
        finalState = initialJson;
      }

      // Step 3: Deserialize to World
      return WorldMapper.fromMap(finalState);
    } finally {
      task.finish();
    }
  }

  /// Computes the diff between initial state and current world,
  /// then writes the patch to the specified save file.
  ///
  /// [savePatchPath] - Optional path to write the save patch. If null, uses
  /// the current save path set by loadSaveWithPatch() or setCurrentSavePath().
  ///
  /// Uses the cached initial state from loadInitialState/loadSaveWithPatch.
  /// Throws StateError if no initial state is cached or no save path is set.
  static Future<void> writeSavePatch(World world, [String? savePatchPath]) async {
    var effectivePath = savePatchPath ?? _currentSavePatchPath;
    if (effectivePath == null) {
      _logger.warning("no save path specified and no current save path set, skipping");
      return;
    }

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

      var patchFile = File(effectivePath);

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

  /// Gets (and creates if needed) the saves directory.
  static Future<Directory> getSavesDirectory() async {
    var supportDir = await getApplicationSupportDirectory();
    var savesDir = Directory("${supportDir.path}/saves");
    if (!await savesDir.exists()) {
      await savesDir.create(recursive: true);
    }
    return savesDir;
  }

  /// Lists all save files in the saves directory.
  /// Returns saves sorted by last modified date (newest first).
  static Future<List<SaveFileInfo>> listSaves() async {
    var savesDir = await getSavesDirectory();
    var saves = <SaveFileInfo>[];

    await for (var entity in savesDir.list()) {
      if (entity is File && entity.path.endsWith('.patch.json')) {
        var stat = await entity.stat();
        var fileName = entity.uri.pathSegments.last;
        var name = fileName.replaceAll('.patch.json', '');
        saves.add(SaveFileInfo(
          name: name,
          path: entity.path,
          lastModified: stat.modified,
        ));
      }
    }

    // Sort by last modified, newest first
    saves.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return saves;
  }

  /// Creates a new save file with the given name.
  /// Returns the path to the new save file.
  /// Throws if a save with this name already exists.
  static Future<String> createNewSave(String name) async {
    var savesDir = await getSavesDirectory();
    var savePath = "${savesDir.path}/$name.patch.json";
    var saveFile = File(savePath);

    if (await saveFile.exists()) {
      throw StateError('Save file "$name" already exists.');
    }

    // Write empty patch array
    await saveFile.writeAsString('[]');
    _logger.info("created new save", {"path": savePath});
    return savePath;
  }

  /// Deletes a save file.
  static Future<void> deleteSave(String savePath) async {
    var file = File(savePath);
    if (await file.exists()) {
      await file.delete();
      _logger.info("deleted save", {"path": savePath});
    }
  }
}

/// Information about a save file.
class SaveFileInfo {
  final String name;
  final String path;
  final DateTime lastModified;

  SaveFileInfo({
    required this.name,
    required this.path,
    required this.lastModified,
  });
}
