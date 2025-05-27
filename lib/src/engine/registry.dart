import 'systems.dart';
import 'events.dart';
import 'components.dart';
import 'entity.dart';

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

class Registry {
  int tickId = 0;
  int lastId = 0;
  Map<String, Map<int, dynamic>> components = {};
  final List<System> systems;

  Registry(this.systems, this.components);

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

  Map<int, dynamic> get<C>() {
    return components.putIfAbsent(C.toString(), () => {});
  }

  Entity add(List<dynamic> comps) {
    var entityId = lastId++;
    for (var c in comps) {
      var entitiesWithComponent =
      components.putIfAbsent(c.runtimeType.toString(), () => {});
      entitiesWithComponent[entityId] = c;
    }

    EventBus().publish(Event<int>(
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

    EventBus().publish(Event<int>(
      eventType: EventType.removed,
      id: null,
      value: entityId,
    ));
  }

  /// Executes a single ECS update tick.
  void tick() {
    EventBus().publish(Event<PreTickEvent>(
        eventType: EventType.updated, value: PreTickEvent(tickId), id: tickId));
    clearLifetimeComponents<BeforeTick>(); // TODO would be cool to find a better way of pulling this out from the class.

    var sortedSystems = systems
      ..sort((a, b) => a.priority.compareTo(b
          .priority)); // TODO: move this elsewhere? Just sort once? Or when new systems are added?

    for (var s in sortedSystems) {
      s.update(this);
    }

    clearLifetimeComponents<AfterTick>();  // TODO would be cool to find a better way of pulling this out from the class.
    EventBus().publish(Event<PostTickEvent>(
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
        if (entityToComponent.value is BeforeTick &&
            entityToComponent.value.tick()) {
          // if is BeforeTick and is dead, remove.
          componentMap.remove(entityToComponent.key);
        }
      }
    }
  }
}