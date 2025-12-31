import 'package:collection/collection.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ecs/events.dart';

class Entity {
  static final _logger = Logger('Entity');

  final World parentCell;
  final int id;

  Entity({required this.parentCell, required this.id}) {
    _logger.fine('entity_created: id=$id');
  }

  /// Stream of component changes for this specific entity.
  /// Use [ChangeStreamFilters] extension methods for filtered subscriptions.
  Stream<Change> get changes => 
      parentCell.componentChanges.where((c) => c.entityId == id);

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

    entitiesWithComponent[id] = c;

    // Log important component changes
    if (c is Health || c is LocalPosition || c is VisionRadius || c is Inventory) {
      _logger.finer('component_upserted: entity=$id, component=${c.componentType}, was_update=${existing != null}');
    }

    parentCell.notifyChange(Change(entityId: id, componentType: C.toString(), oldValue: existing?.value, newValue: c));
  }

  void upsertByName(Component c) {
    var entitiesWithComponent = parentCell.components.putIfAbsent(c.componentType, () => {});
    var existing = entitiesWithComponent.entries.firstWhereOrNull((e) => e.key == id);

    entitiesWithComponent[id] = c;

    parentCell.notifyChange(Change(entityId: id, componentType: c.componentType, oldValue: existing?.value, newValue: c));
  }

  void remove<C>() {
    var entitiesWithComponent = parentCell.components.putIfAbsent(C.toString(), () => {});
    var existing = entitiesWithComponent.entries.firstWhereOrNull((e) => e.key == id);

    if (existing != null) {
      entitiesWithComponent.remove(id);

      parentCell.notifyChange(Change(entityId: id, componentType: C.toString(), oldValue: existing.value, newValue: null));
    }
  }

  void removeByName(String componentType) {
    var entitiesWithComponent = parentCell.components.putIfAbsent(componentType, () => {});
    var existing = entitiesWithComponent.entries.firstWhereOrNull((e) => e.key == id);

    if (existing != null) {
      entitiesWithComponent.remove(id);

      parentCell.notifyChange(Change(entityId: id, componentType: componentType, oldValue: existing.value, newValue: null));
    }
  }

  void destroy() {
    _logger.fine('entity_destroyed: id=$id');
    parentCell.remove(id);
  }
}