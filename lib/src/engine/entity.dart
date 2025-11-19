import 'components.dart';
import 'registry.dart';
import 'events.dart';

class Entity {
  final Registry parentCell;
  final int id;

  Entity({required this.parentCell, required this.id});

  bool has<C extends Component>() {
    var entitiesWithComponent = parentCell.components[C] ?? {};
    return entitiesWithComponent.containsKey(id);
  }

  C? get<C extends Component>([C? orDefault]) {
    var entitiesWithComponent = parentCell.components.putIfAbsent(C, () => <int, Component>{});
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

  List<Component> getAll() {
    List<Component> comps = [];
    parentCell.components.forEach((k, v) {
      if (v.keys.contains(id)) {
        var thing = v[id]!;
        comps.add(thing);
      }
    });

    return comps;
  }

  void upsert<C extends Component>(C c) {
    var entitiesWithComponent = parentCell.components.putIfAbsent(C, () => {});
    var alreadyExisted = entitiesWithComponent.containsKey(id);

    entitiesWithComponent[id] = c;

    parentCell.eventBus.publish(Event<C>(eventType: alreadyExisted ? EventType.updated : EventType.added, id: id, value: c));
  }

  void remove<C>() {
    var entitiesWithComponent = parentCell.components.putIfAbsent(C, () => {});
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