import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/world.dart';

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
      parentCell.notifyChange(Change(entityId: id, componentType: orDefault.componentType, oldValue: null, newValue: orDefault));

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
      parentCell.notifyChange(Change(entityId: id, componentType: orDefault.componentType, oldValue: null, newValue: orDefault));

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

    parentCell.notifyChange(Change(entityId: id, componentType: C.toString(), oldValue: existing?.value, newValue: c));
  }

  void upsertByName(Component c) {
    var entitiesWithComponent = parentCell.components.putIfAbsent(c.componentType, () => {});
    var existing = entitiesWithComponent.entries.firstWhereOrNull((e) => e.key == id);
    var alreadyExisted = existing != null;

    entitiesWithComponent[id] = c;

    parentCell.notifyChange(Change(entityId: id, componentType: c.componentType, oldValue: existing?.value, newValue: c));
  }

  void remove<C>() {
    var entitiesWithComponent = parentCell.components.putIfAbsent(C.toString(), () => {});
    var existing = entitiesWithComponent.entries.firstWhereOrNull((e) => e.key == id);
    var componentExists = existing != null;

    if (componentExists) {
      var oldComponent = entitiesWithComponent[id] as C;
      entitiesWithComponent.remove(id);

      parentCell.notifyChange(Change(entityId: id, componentType: C.toString(), oldValue: existing.value, newValue: null));
    }
  }

  void removeByName(String componentType) {
    var entitiesWithComponent = parentCell.components.putIfAbsent(componentType, () => {});
    var existing = entitiesWithComponent.entries.firstWhereOrNull((e) => e.key == id);
    var componentExists = existing != null;

    if (componentExists) {
      var oldComponent = entitiesWithComponent[id] as Component;
      entitiesWithComponent.remove(id);

      parentCell.notifyChange(Change(entityId: id, componentType: componentType, oldValue: existing.value, newValue: null));
    }
  }

  void destroy() {
    parentCell.remove(id);
  }
}