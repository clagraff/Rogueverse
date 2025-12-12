import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
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

  Component? getByName(String componentType, [Component? orDefault]) {
    var entitiesWithComponent = parentCell.components.putIfAbsent(componentType, () => <int, Component>{});
    if (entitiesWithComponent.containsKey(id)) {
      return entitiesWithComponent[id] as Component;
    }

    if (orDefault != null) {
      entitiesWithComponent[id] = orDefault;
      parentCell.eventBus.publish(Event<Component>(eventType:EventType.added, id: id, value: orDefault)); // TODO gotta figure this out since `<Component>` is not good.

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
    var entitiesWithComponent = parentCell.components.putIfAbsent(c.componentType, () => {});
    var existing = entitiesWithComponent.entries.firstWhereOrNull((e) => e.key == id);
    var alreadyExisted = existing != null;

    entitiesWithComponent[id] = c;

    parentCell.notifyChange(ComponentChange(entityId: id, componentType: C.toString(), oldValue: existing?.value, newValue: c));
    parentCell.eventBus.publish(Event<C>(eventType: alreadyExisted ? EventType.updated : EventType.added, id: id, value: c));
  }

  void upsertByName(Component c) {
    var entitiesWithComponent = parentCell.components.putIfAbsent(c.componentType, () => {});
    var existing = entitiesWithComponent.entries.firstWhereOrNull((e) => e.key == id);
    var alreadyExisted = existing != null;

    entitiesWithComponent[id] = c;

    parentCell.notifyChange(ComponentChange(entityId: id, componentType: c.componentType, oldValue: existing?.value, newValue: c));
    parentCell.eventBus.publish(Event<Component>(eventType: alreadyExisted ? EventType.updated : EventType.added, id: id, value: c)); // TODO `<Component>` sucks
  }

  void remove<C>() {
    var entitiesWithComponent = parentCell.components.putIfAbsent(C.toString(), () => {});
    var existing = entitiesWithComponent.entries.firstWhereOrNull((e) => e.key == id);
    var componentExists = existing != null;

    if (componentExists) {
      var oldComponent = entitiesWithComponent[id] as C;
      entitiesWithComponent.remove(id);

      parentCell.notifyChange(ComponentChange(entityId: id, componentType: C.toString(), oldValue: existing.value, newValue: null));
      parentCell.eventBus.publish(Event<C>(eventType: EventType.removed, id: id, value: oldComponent));
    }
  }

  void removeByName(String componentType) {
    var entitiesWithComponent = parentCell.components.putIfAbsent(componentType, () => {});
    var existing = entitiesWithComponent.entries.firstWhereOrNull((e) => e.key == id);
    var componentExists = existing != null;

    if (componentExists) {
      var oldComponent = entitiesWithComponent[id] as Component;
      entitiesWithComponent.remove(id);

      parentCell.notifyChange(ComponentChange(entityId: id, componentType: componentType, oldValue: existing.value, newValue: null));
      parentCell.eventBus.publish(Event<Component>(eventType: EventType.removed, id: id, value: oldComponent)); // TODO `<Component>` sucks
    }
  }

  void destroy() {
    parentCell.remove(id);
  }
}