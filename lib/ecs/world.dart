import 'dart:convert';
import 'dart:io';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:path_provider/path_provider.dart';

import 'package:rogueverse/ecs/systems.dart';
import 'package:rogueverse/ecs/events.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';

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


@MappableClass()
class World with WorldMappable {
  int tickId = 0; // TODO not de/serializing to json/map
  int lastId = 0; // TODO not de/serializing to json/map
  final List<System> systems;
  final EventBus eventBus = EventBus();

  @MappableField(hook: ComponentsHook())
  Map<String, Map<int, Component>> components;

  World(this.systems, this.components, [this.tickId = 0, this.lastId = 0]);

  Entity getEntity(int entityId) {
    return Entity(parentCell: this, id: entityId);
  }

  List<Entity> entities() {
    var entityIds = <int>{};

    for (var componentMap in components.values) {
      entityIds.addAll(componentMap.keys);
    }
    return entityIds.map((id) => getEntity(id)).toList();
  }

  Map<int, C> get<C extends Component>() {
    return components.putIfAbsent(C.toString(), () => {}).cast<int, C>();
  }

  Entity add(List<Component> comps) {
    var entityId = lastId++;
    for (var c in comps) {
      var entitiesWithComponent =
      components.putIfAbsent(c.componentType, () => {});
      entitiesWithComponent[entityId] = c;
    }

    eventBus.publish(Event<int>(
      eventType: EventType.added,
      id: null,
      value: entityId,
    ));
    return getEntity(entityId);
  }

  void remove(int entityId) {
    for (var entityComponentMap in components.entries) {
      entityComponentMap.value.removeWhere((id, c) => id == entityId);
    }

    eventBus.publish(Event<int>(
      eventType: EventType.removed,
      id: null,
      value: entityId,
    ));
  }

  /// Executes a single ECS update tick.
  void tick() {
    eventBus.publish(Event<PreTickEvent>(
        eventType: EventType.updated, value: PreTickEvent(tickId), id: tickId));
    clearLifetimeComponents<
        BeforeTick>(); // TODO would be cool to find a better way of pulling this out from the class.

    for (var s in systems) {
      s.update(this);
    }

    clearLifetimeComponents<
        AfterTick>(); // TODO would be cool to find a better way of pulling this out from the class.
    eventBus.publish(Event<PostTickEvent>(
        eventType: EventType.updated,
        value: PostTickEvent(tickId),
        id: tickId));

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
        }
      }
    }
  }
}


/// A dart_mappable hook to handle de/serializing the complex map (for JSON).
/// Necessary as we cannot use integers as JSON keys, so we convert to/from strings instead.
class ComponentsHook extends MappingHook  {
  const ComponentsHook();

  /// Receives the ecoded value before decoding.
  @override
  Object? beforeDecode(Object? value) {
    //var comps = value as Map<String, Map<int, Component>>;
    var comps = value as Map<String, dynamic>;
    return comps.map((type, entityMap) {
      var idMap = entityMap as Map<String, dynamic>;
      return MapEntry(
        type, entityMap.map((id, comp) => MapEntry(id.toString(), MapperContainer.globals.fromMap(comp))));
    });
  }

  /// Receives the decoded value before encoding.
  @override
  Object? beforeEncode(Object? value) {
    var comps = value as Map<String, Map<int, Component>>;
    return comps.map((type, entityMap) => MapEntry(
        type, entityMap.map((id, comp) => MapEntry(id.toString(), MapperContainer.globals.toMap(comp)))));
  }
}



class WorldSaves {
  static Future<World?> loadSave() async {
    var supportDir = await getApplicationSupportDirectory();
    var saveGame = File("${supportDir.path}/save.json");
    if (saveGame.existsSync()) {
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

    saveFile.open(mode: FileMode.write);
    var writer = saveFile.openWrite();
    writer.write(saveState);
    await writer.flush();
    await writer.close();

    return;
  }
}