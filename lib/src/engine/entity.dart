import 'registry.dart';
import 'events.dart';

class Entity {
  final Registry parentCell;
  final int id;

  Entity({required this.parentCell, required this.id});

  bool has<C>() {
    var entitiesWithComponent = parentCell.components[C.toString()] ?? {};
    return entitiesWithComponent.containsKey(id);
  }

  C? get<C>([C? orDefault]) {
    var entitiesWithComponent = parentCell.components.putIfAbsent(C.toString(), () => {});
    if (entitiesWithComponent.containsKey(id)) {
      return entitiesWithComponent[id] as C;
    }

    if (orDefault != null) {
      entitiesWithComponent[id] = orDefault;
      parentCell.eventBus.publish(Event<C>(eventType:EventType.added, id: id, value: orDefault));

      return orDefault;
    }

    return null;
  }

  List<dynamic> getAll() {
    var comps = [];
    parentCell.components.forEach((k, v) {
      if (v.keys.contains(id)) {
        comps.add(v[id]!);
      }
    });

    return comps;
  }

  void upsert<C>(C c) {
    var entitiesWithComponent = parentCell.components.putIfAbsent(C.toString(), () => {});
    var alreadyExisted = entitiesWithComponent.containsKey(id);

    entitiesWithComponent[id] = c;

    parentCell.eventBus.publish(Event<C>(eventType: alreadyExisted ? EventType.updated : EventType.added, id: id, value: c));
  }

  void remove<C>() {
    var entitiesWithComponent = parentCell.components.putIfAbsent(C.toString(), () => {});
    var componentExists = entitiesWithComponent.containsKey(id);

    if (componentExists) {
      var oldComponent = entitiesWithComponent[id] as C;
      entitiesWithComponent.remove(id);

      parentCell.eventBus.publish(Event<C>(eventType: EventType.removed, id: id, value: oldComponent));
    }
  }

  void destroy() {
    parentCell.remove(id);
  }
}