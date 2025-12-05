import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ecs/events.dart';

class Entity {
  final World parentCell;
  final int id;

  Entity({required this.parentCell, required this.id});

  bool has<C extends Component>() {
    var entitiesWithComponent = parentCell.components[C.toString()] ?? {};
    return entitiesWithComponent.containsKey(id);
  }

  // TODO maybe have a dedicated `getOrUpsert`?
  C? get<C extends Component>([C? orDefault]) {
    var entitiesWithComponent = parentCell.components.putIfAbsent(C.toString(), () => <int, Component>{});
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