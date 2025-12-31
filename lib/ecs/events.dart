import 'package:rogueverse/ecs/components.dart';

/// Enum representing the kind of change that occurred to a component.
enum ChangeKind { added, removed, updated }

/// Represents a change to a component on an entity.
/// 
/// Tracks the old and new values to provide full context about the change.
/// The [kind] is derived from the presence of old/new values:
/// - added: oldValue is null, newValue is not null
/// - removed: oldValue is not null, newValue is null
/// - updated: both oldValue and newValue are not null
class Change {
  final int entityId;
  final String componentType;
  final Component? oldValue;
  final Component? newValue;

  const Change({
    required this.entityId,
    required this.componentType,
    required this.oldValue,
    required this.newValue,
  });

  ChangeKind get kind {
    if (oldValue == null && newValue != null) return ChangeKind.added;
    if (oldValue != null && newValue == null) return ChangeKind.removed;
    return ChangeKind.updated;
  }
}

/// Extension methods for filtering streams of component changes.
/// 
/// These methods work on any [Stream<Change>], whether it's from a World,
/// View, or Entity. The stream may already be pre-filtered (e.g., View filters
/// by query, Entity filters by entity ID), and these methods add additional
/// filtering by component type and change kind.
/// 
/// Example usage:
/// ```dart
/// // World - all Health changes across all entities
/// world.componentChanges.onComponentAdded<Health>().listen(...);
/// 
/// // View - Health changes only for entities matching the view's query
/// view.componentChanges.onComponentAdded<Health>().listen(...);
/// 
/// // Entity - Health changes only for this specific entity
/// entity.changes.onComponentAdded<Health>().listen(...);
/// ```
extension ChangeStreamFilters on Stream<Change> {
  /// Filters changes by entity ID, component type, and/or change kind.
  /// 
  /// All parameters are optional - null values are not filtered.
  Stream<Change> onChange({int? entityId, String? componentType, ChangeKind? kind}) =>
      where((c) =>
          (entityId == null || c.entityId == entityId) &&
          (componentType == null || c.componentType == componentType) &&
          (kind == null || c.kind == kind));

  /// Filters to changes for a specific entity ID.
  Stream<Change> onEntityChange(int entityId) => onChange(entityId: entityId);

  /// Filters to any change (added, removed, or updated) for component type [C].
  Stream<Change> onComponentChanged<C extends Component>() =>
      onChange(componentType: C.toString());

  /// Filters to any change (added, removed, or updated) for the named component type.
  Stream<Change> onComponentChangedByName(String componentType) =>
      onChange(componentType: componentType);

  /// Filters to additions of component type [C].
  Stream<Change> onComponentAdded<C extends Component>() =>
      onChange(componentType: C.toString(), kind: ChangeKind.added);

  /// Filters to additions of the named component type.
  Stream<Change> onComponentAddedByName(String componentType) =>
      onChange(componentType: componentType, kind: ChangeKind.added);

  /// Filters to removals of component type [C].
  Stream<Change> onComponentRemoved<C extends Component>() =>
      onChange(componentType: C.toString(), kind: ChangeKind.removed);

  /// Filters to removals of the named component type.
  Stream<Change> onComponentRemovedByName(String componentType) =>
      onChange(componentType: componentType, kind: ChangeKind.removed);

  /// Filters to updates of component type [C].
  Stream<Change> onComponentUpdated<C extends Component>() =>
      onChange(componentType: C.toString(), kind: ChangeKind.updated);

  /// Filters to updates of the named component type.
  Stream<Change> onComponentUpdatedByName(String componentType) =>
      onChange(componentType: componentType, kind: ChangeKind.updated);

  /// Filters to changes of component type [C] on a specific entity.
  Stream<Change> onEntityOnComponent<C extends Component>(int entityId) =>
      onChange(entityId: entityId, componentType: C.toString());

  /// Filters to changes of the named component type on a specific entity.
  Stream<Change> onEntityOnComponentByName(int entityId, String componentType) =>
      onChange(entityId: entityId, componentType: componentType);
}
