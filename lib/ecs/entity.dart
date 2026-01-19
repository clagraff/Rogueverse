import 'package:collection/collection.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ecs/events.dart';
import 'package:rogueverse/ecs/template_resolver.dart';

class Entity {
  static final _logger = Logger('Entity');

  final World parentCell;
  final int id;

  Entity({required this.parentCell, required this.id});

  @override
  String toString() {
    var name = get<Name>();
    if (name != null && name.name.isNotEmpty) {
      return "Entity(id: $id, Name: \"${name.name}\")";
    }
    return "Entity(id: $id)";
  }

  /// Stream of component changes for this specific entity.
  /// Use [ChangeStreamFilters] extension methods for filtered subscriptions.
  Stream<Change> get changes =>
      parentCell.componentChanges.where((c) => c.entityId == id);

  /// Checks if this entity has component C, considering template inheritance.
  ///
  /// Resolution order:
  /// 1. Check if entity has component C directly → true (direct always wins)
  /// 2. Check if [FromTemplate.excludedTypes] blocks type C → false
  /// 3. If entity has [FromTemplate], recursively check template (up to 3 levels)
  bool has<C extends Component>() {
    return parentCell.templateResolver.has(id, C.toString());
  }

  /// Check if entity has component by type name (for Query system).
  bool hasType(String typeName) {
    return parentCell.templateResolver.has(id, typeName);
  }

  /// Get component directly without template resolution (internal helper).
  T? _getDirectComponent<T extends Component>() {
    final entitiesWithComponent = parentCell.components[T.toString()] ?? {};
    return entitiesWithComponent[id] as T?;
  }

  /// Gets component C, considering template inheritance.
  ///
  /// Returns the actual component instance (may be from template - not a copy).
  /// If [orDefault] is provided and no component is found, the default is
  /// stored on this entity and returned.
  ///
  /// Resolution order:
  /// 1. Check if entity has component C directly → return it (direct always wins)
  /// 2. Check if [FromTemplate.excludedTypes] blocks type C → null (or apply default)
  /// 3. If entity has [FromTemplate], recursively check template (up to 3 levels)
  /// 4. Apply orDefault if provided (stores on entity, not template)
  C? get<C extends Component>([C? orDefault]) {
    final result = parentCell.templateResolver.get<C>(id);
    if (result != null) return result;

    if (orDefault != null) {
      _setDirectComponent(C.toString(), orDefault);
      return orDefault;
    }

    return null;
  }

  /// Set component directly (internal helper).
  void _setDirectComponent(String typeName, Component c) {
    var entitiesWithComponent = parentCell.components.putIfAbsent(typeName, () => {});
    entitiesWithComponent[id] = c;
    parentCell.notifyChange(Change(
      entityId: id,
      componentType: typeName,
      oldValue: null,
      newValue: c,
    ));
  }

  /// Gets component of type [C], or creates and adds it if missing.
  ///
  /// More explicit alternative to `get<C>(defaultValue)`.
  /// Always returns a non-null component.
  C getOrUpsert<C extends Component>(C defaultValue) {
    return get<C>(defaultValue)!;
  }

  /// Gets component by type name, considering template inheritance.
  ///
  /// Returns the actual component instance (may be from template - not a copy).
  Component? getByName(String componentType, [Component? orDefault]) {
    final result = parentCell.templateResolver.getByName(id, componentType);
    if (result != null) return result;

    if (orDefault != null) {
      _setDirectComponent(componentType, orDefault);
      return orDefault;
    }

    return null;
  }

  /// Gets all components on this entity, including those inherited from templates.
  ///
  /// Template components are included unless:
  /// - The entity has its own version (override)
  /// - The type is in [FromTemplate.excludedTypes]
  List<Component> getAll() {
    return parentCell.templateResolver.getAll(id);
  }

  void upsert<C extends Component>(C c) {
    // Clear exclusion if this type was excluded (so direct component is visible)
    _clearExclusionIfNeeded(c.componentType);

    var entitiesWithComponent =
        parentCell.components.putIfAbsent(c.componentType, () => {});
    var existing =
        entitiesWithComponent.entries.firstWhereOrNull((e) => e.key == id);

    entitiesWithComponent[id] = c;

    _logger.finest('component upserted', {
      "entity": this,
      "componentType": c.componentType,
      "wasExisting": existing != null,
      "component": c
    });

    parentCell.notifyChange(Change(
        entityId: id,
        componentType: C.toString(),
        oldValue: existing?.value,
        newValue: c));
  }

  void upsertByName(Component c) {
    // Clear exclusion if this type was excluded (so direct component is visible)
    _clearExclusionIfNeeded(c.componentType);

    var entitiesWithComponent = parentCell.components.putIfAbsent(c.componentType, () => {});
    var existing = entitiesWithComponent.entries.firstWhereOrNull((e) => e.key == id);

    entitiesWithComponent[id] = c;

    parentCell.notifyChange(Change(entityId: id, componentType: c.componentType, oldValue: existing?.value, newValue: c));
  }

  /// Clears an exclusion for the given type if it exists in FromTemplate.excludedTypes.
  ///
  /// Called when upserting a component directly, so the direct component will be
  /// visible and the exclusion state stays clean.
  void _clearExclusionIfNeeded(String typeName) {
    // Don't try to clear exclusions when upserting FromTemplate itself (avoids recursion)
    if (typeName == 'FromTemplate') return;

    final fromTemplate = _getDirectComponent<FromTemplate>();
    if (fromTemplate != null && fromTemplate.excludedTypes.contains(typeName)) {
      final newExclusions = Set<String>.from(fromTemplate.excludedTypes)..remove(typeName);
      final newFromTemplate = FromTemplate(
        fromTemplate.templateEntityId,
        excludedTypes: newExclusions,
      );
      // Use _setDirectComponent to avoid recursion (don't call upsertByName)
      _setDirectComponent('FromTemplate', newFromTemplate);
    }
  }

  /// Sets an intent on this entity, clearing any existing intents first.
  ///
  /// Only one [IntentComponent] should exist per entity at a time.
  /// This method ensures that by removing all existing intents before
  /// setting the new one.
  void setIntent(IntentComponent intent) {
    _logger.info("setIntent called on entity $id: ${intent.componentType}");

    // Remove all existing IntentComponents
    final componentsToRemove = <String>[];
    parentCell.components.forEach((componentType, entitiesMap) {
      if (entitiesMap.containsKey(id)) {
        final component = entitiesMap[id];
        if (component is IntentComponent) {
          componentsToRemove.add(componentType);
        }
      }
    });

    for (final componentType in componentsToRemove) {
      removeByName(componentType);
    }

    // Set the new intent
    upsert(intent);
    _logger.info("intent set successfully on entity $id");
  }

  /// Removes component C from this entity.
  ///
  /// If the entity has the component directly, it is removed.
  /// If the component comes from a template (via [FromTemplate]), the type
  /// is added to [FromTemplate.excludedTypes] to block inheritance.
  void remove<C>() {
    _removeByTypeName(C.toString());
  }

  /// Removes component by type name.
  ///
  /// If the entity has the component directly, it is removed.
  /// If the component comes from a template (via [FromTemplate]), the type
  /// is added to [FromTemplate.excludedTypes] to block inheritance.
  void removeByName(String componentType) {
    _removeByTypeName(componentType);
  }

  void _removeByTypeName(String typeName) {
    var entitiesWithComponent = parentCell.components[typeName] ?? {};
    var existing = entitiesWithComponent.entries.firstWhereOrNull((e) => e.key == id);

    if (existing != null) {
      // Entity has it directly - remove it
      entitiesWithComponent.remove(id);
      parentCell.notifyChange(Change(
        entityId: id,
        componentType: typeName,
        oldValue: existing.value,
        newValue: null,
      ));
    }

    // Always check if template also has this component and add exclusion if needed
    final fromTemplate = _getDirectComponent<FromTemplate>();
    if (fromTemplate != null) {
      final templateEntity = parentCell.getEntity(fromTemplate.templateEntityId);
      if (templateEntity.hasType(typeName)) {
        _addExclusion(typeName, fromTemplate);
      }
    }
  }

  /// Add a component type to [FromTemplate.excludedTypes] (internal helper).
  ///
  /// Also emits a synthetic change notification for the excluded component type
  /// so that systems (like VisionSystem) can respond to the effective removal.
  void _addExclusion(String typeName, FromTemplate fromTemplate) {
    final newFromTemplate = FromTemplate(
      fromTemplate.templateEntityId,
      excludedTypes: {...fromTemplate.excludedTypes, typeName},
    );
    upsertByName(newFromTemplate);

    // Emit synthetic change notification for the excluded component
    // so systems like VisionSystem know to update
    parentCell.notifyChange(Change(
      entityId: id,
      componentType: typeName,
      oldValue: null, // We don't have the actual old value (it was on template)
      newValue: null, // Component is now effectively "removed" (excluded)
    ));
  }

  void destroy() {
    _logger.finest("destroyed entity", {"entity": this});
    parentCell.remove(id);
  }

  // ============================================================
  // Public API for direct vs inherited component access
  // ============================================================

  /// Check if component is directly on this entity (not inherited from template).
  bool hasDirectByName(String typeName) {
    final entitiesWithComponent = parentCell.components[typeName] ?? {};
    return entitiesWithComponent.containsKey(id);
  }

  /// Check if component of type [C] is directly on this entity.
  bool hasDirect<C extends Component>() {
    return hasDirectByName(C.toString());
  }

  /// Get component only if it's directly on this entity (not from template).
  /// Returns null if the component is inherited or doesn't exist.
  Component? getDirectByName(String typeName) {
    final entitiesWithComponent = parentCell.components[typeName] ?? {};
    return entitiesWithComponent[id];
  }

  /// Get component of type [C] only if it's directly on this entity.
  C? getDirect<C extends Component>() {
    return getDirectByName(C.toString()) as C?;
  }

  /// Get all components that are directly on this entity (not inherited).
  Map<String, Component> getAllDirect() {
    final result = <String, Component>{};
    parentCell.components.forEach((typeName, entitiesMap) {
      if (entitiesMap.containsKey(id)) {
        result[typeName] = entitiesMap[id]!;
      }
    });
    return result;
  }

  /// Get all components inherited from template (not direct, not excluded).
  /// Returns empty map if entity has no [FromTemplate].
  Map<String, Component> getAllInherited() {
    final result = <String, Component>{};

    final fromTemplate = _getDirectComponent<FromTemplate>();
    if (fromTemplate == null) return result;

    final templateEntity = parentCell.getEntity(fromTemplate.templateEntityId);
    final excludedTypes = fromTemplate.excludedTypes;

    // Get all components from template (recursively)
    for (final component in templateEntity.getAll()) {
      final typeName = component.componentType;
      // Skip if excluded, non-inheritable, or we have a direct override
      if (excludedTypes.contains(typeName)) continue;
      if (TemplateResolver.nonInheritableTypes.contains(typeName)) continue;
      if (hasDirectByName(typeName)) continue;

      result[typeName] = component;
    }

    return result;
  }

  /// Get the template entity if this entity has [FromTemplate].
  /// Returns null if no template reference exists.
  Entity? getTemplateEntity() {
    final fromTemplate = _getDirectComponent<FromTemplate>();
    if (fromTemplate == null) return null;
    return parentCell.getEntity(fromTemplate.templateEntityId);
  }

  /// Get the list of excluded types from [FromTemplate].
  /// Returns empty set if no template reference exists.
  Set<String> getExcludedTypes() {
    final fromTemplate = _getDirectComponent<FromTemplate>();
    return fromTemplate?.excludedTypes ?? {};
  }

  /// Remove ONLY the direct component, without affecting exclusions.
  /// If template has this component, it will show through after removal.
  /// Does nothing if the component is not directly on this entity.
  void removeDirect<C>() {
    removeDirectByName(C.toString());
  }

  /// Remove ONLY the direct component by name, without affecting exclusions.
  /// If template has this component, it will show through after removal.
  /// Does nothing if the component is not directly on this entity.
  void removeDirectByName(String typeName) {
    final entitiesWithComponent = parentCell.components[typeName] ?? {};
    final existing = entitiesWithComponent[id];

    if (existing != null) {
      entitiesWithComponent.remove(id);
      parentCell.notifyChange(Change(
        entityId: id,
        componentType: typeName,
        oldValue: existing,
        newValue: null,
      ));
    }
    // Note: Unlike _removeByTypeName, we do NOT add an exclusion here
  }

  /// Add a type to [FromTemplate.excludedTypes] to block template inheritance.
  /// Does nothing if entity has no [FromTemplate] or template doesn't have this type.
  void excludeFromTemplate(String typeName) {
    final fromTemplate = _getDirectComponent<FromTemplate>();
    if (fromTemplate == null) return;

    // Check if template actually has this component
    final templateEntity = parentCell.getEntity(fromTemplate.templateEntityId);
    if (!templateEntity.hasType(typeName)) return;

    // Already excluded?
    if (fromTemplate.excludedTypes.contains(typeName)) return;

    _addExclusion(typeName, fromTemplate);
  }

  /// Remove a type from [FromTemplate.excludedTypes] to restore template inheritance.
  /// Does nothing if entity has no [FromTemplate] or type isn't excluded.
  void restoreFromTemplate(String typeName) {
    final fromTemplate = _getDirectComponent<FromTemplate>();
    if (fromTemplate == null) return;

    if (!fromTemplate.excludedTypes.contains(typeName)) return;

    final newExclusions = Set<String>.from(fromTemplate.excludedTypes)..remove(typeName);
    final newFromTemplate = FromTemplate(
      fromTemplate.templateEntityId,
      excludedTypes: newExclusions,
    );
    upsertByName(newFromTemplate);

    // Emit synthetic change notification so systems know the component is "back"
    final templateEntity = parentCell.getEntity(fromTemplate.templateEntityId);
    final templateComponent = templateEntity.getByName(typeName);
    parentCell.notifyChange(Change(
      entityId: id,
      componentType: typeName,
      oldValue: null,
      newValue: templateComponent,
    ));
  }
}
