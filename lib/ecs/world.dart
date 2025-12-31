import 'dart:async' show StreamController;
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rogueverse/ecs/ecs.dart';

import 'package:rogueverse/ecs/systems.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/events.dart';

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
      () => Entity(parentCell: this, id: entityId, isNewCreation: true),
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

  /// Executes a single ECS update tick.
  void tick() {
    final tickStopwatch = Stopwatch()..start();
    final systemTimings = <String, Duration>{};

    // TODO pre-tick notification???
    clearLifetimeComponents<
        BeforeTick>(); // TODO would be cool to find a better way of pulling this out from the class.

    for (var s in systems) {
      final systemStopwatch = Stopwatch()..start();
      s.update(this);
      systemStopwatch.stop();
      systemTimings[s.runtimeType.toString()] = systemStopwatch.elapsed;
    }

    clearLifetimeComponents<
        AfterTick>(); // TODO would be cool to find a better way of pulling this out from the class.

    // TODO post-tick notification???

    tickStopwatch.stop();
    
    // Log tick performance with per-system timing
    final systemTimingsStr = systemTimings.entries.sorted((e1, e2) {
          return e2.value.inMicroseconds.compareTo(e1.value.inMicroseconds);
        })
        .map((e) => '${e.key}=${e.value.toHumanReadableString()}')
        .join(' ');
    _logger.info('tick complete: tickId=$tickId duration=${tickStopwatch.elapsed.toHumanReadableString()}, $systemTimingsStr');

    tickId++; // TODO: wrap around to avoid out of bounds type error?
  }

  void clearLifetimeComponents<T extends Lifetime>() {
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
  static Future<World?> loadSave() async {
    var supportDir = await getApplicationSupportDirectory();
    var saveGame = File("${supportDir.path}/save.json");
    if (saveGame.existsSync()) {
      Logger("WorldSaves").info("loading save: ${supportDir.path}/save.json");
      var jsonContents = saveGame.readAsStringSync();
      return WorldMapper.fromJson(jsonContents);
    }

    return null;
  }

  static Future<void> writeSave(World world, [bool indent = true]) async {
    var indentChar = indent ? "\t" : "";
    var saveState = JsonEncoder.withIndent(indentChar).convert(world.toMap());
    var supportDir = await getApplicationSupportDirectory();
    var saveFile = File("${supportDir.path}/save.json");

    Logger("WorldSaves").info("writing save: ${supportDir.path}/save.json");

    saveFile.open(mode: FileMode.write);
    var writer = saveFile.openWrite();
    writer.write(saveState);
    await writer.flush();
    await writer.close();

    return;
  }
}
