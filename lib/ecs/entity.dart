import 'package:collection/collection.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ecs/events.dart';

class Entity {
  static final _logger = Logger('Entity');

  /// Maximum depth for template inheritance resolution.
  static const int _maxTemplateDepth = 3;

  /// Component types that should never be inherited from templates.
  /// These are marker/identity components that only apply to the specific entity.
  static const Set<String> _nonInheritableTypes = {
    'IsTemplate',      // Template marker - only the template itself IS a template
    'FromTemplate',    // Template reference - each entity has its own (includes exclusions)
  };

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
    return _hasWithDepth(C.toString(), 0);
  }

  /// Check if entity has component by type name (for Query system).
  bool hasType(String typeName) {
    return _hasWithDepth(typeName, 0);
  }

  bool _hasWithDepth(String typeName, int depth) {
    // 1. Check direct component FIRST - direct always wins
    var entitiesWithComponent = parentCell.components[typeName] ?? {};
    if (entitiesWithComponent.containsKey(id)) {
      return true;
    }

    // 2. Check exclusions (only blocks template inheritance)
    final fromTemplate = _getDirectComponent<FromTemplate>('FromTemplate');
    if (fromTemplate != null && fromTemplate.excludedTypes.contains(typeName)) {
      return false;
    }

    // 3. Check template (with depth limit) - but not for non-inheritable types
    if (depth < _maxTemplateDepth && !_nonInheritableTypes.contains(typeName)) {
      if (fromTemplate != null) {
        final templateEntity = parentCell.getEntity(fromTemplate.templateEntityId);
        return templateEntity._hasWithDepth(typeName, depth + 1);
      }
    }

    return false;
  }

  /// Get component directly without template resolution (internal helper).
  T? _getDirectComponent<T extends Component>(String typeName) {
    var entitiesWithComponent = parentCell.components[typeName] ?? {};
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
    return _getWithDepth<C>(C.toString(), orDefault, 0);
  }

  C? _getWithDepth<C extends Component>(String typeName, C? orDefault, int depth) {
    // 1. Check direct component FIRST - direct always wins
    var entitiesWithComponent = parentCell.components[typeName] ?? {};
    if (entitiesWithComponent.containsKey(id)) {
      return entitiesWithComponent[id] as C;
    }

    // 2. Check exclusions (only blocks template inheritance)
    final fromTemplate = _getDirectComponent<FromTemplate>('FromTemplate');
    if (fromTemplate != null && fromTemplate.excludedTypes.contains(typeName)) {
      // If excluded and orDefault provided, add to entity
      if (orDefault != null) {
        _setDirectComponent(typeName, orDefault);
        return orDefault;
      }
      return null;
    }

    // 3. Check template (with depth limit) - but not for non-inheritable types
    if (depth < _maxTemplateDepth && !_nonInheritableTypes.contains(typeName)) {
      if (fromTemplate != null) {
        final templateEntity = parentCell.getEntity(fromTemplate.templateEntityId);
        final templateValue = templateEntity._getWithDepth<C>(typeName, null, depth + 1);
        if (templateValue != null) {
          return templateValue; // Return template's component (reference, not copy)
        }
      }
    }

    // 4. Apply default if provided
    if (orDefault != null) {
      _setDirectComponent(typeName, orDefault);
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
    return _getByNameWithDepth(componentType, orDefault, 0);
  }

  Component? _getByNameWithDepth(String componentType, Component? orDefault, int depth) {
    // 1. Check direct component FIRST - direct always wins
    var entitiesWithComponent = parentCell.components[componentType] ?? {};
    if (entitiesWithComponent.containsKey(id)) {
      return entitiesWithComponent[id] as Component;
    }

    // 2. Check exclusions (only blocks template inheritance)
    final fromTemplate = _getDirectComponent<FromTemplate>('FromTemplate');
    if (fromTemplate != null && fromTemplate.excludedTypes.contains(componentType)) {
      if (orDefault != null) {
        _setDirectComponent(componentType, orDefault);
        return orDefault;
      }
      return null;
    }

    // 3. Check template (with depth limit) - but not for non-inheritable types
    if (depth < _maxTemplateDepth && !_nonInheritableTypes.contains(componentType)) {
      if (fromTemplate != null) {
        final templateEntity = parentCell.getEntity(fromTemplate.templateEntityId);
        final templateValue = templateEntity._getByNameWithDepth(componentType, null, depth + 1);
        if (templateValue != null) {
          return templateValue;
        }
      }
    }

    // 4. Apply default if provided
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
    return _getAllWithDepth(0);
  }

  List<Component> _getAllWithDepth(int depth) {
    final comps = <String, Component>{};

    // Get FromTemplate and its exclusions
    final fromTemplate = _getDirectComponent<FromTemplate>('FromTemplate');
    final excludedTypes = fromTemplate?.excludedTypes ?? {};

    // Get template components first (lower priority - will be overridden)
    // But never inherit non-inheritable types or excluded types
    if (depth < _maxTemplateDepth) {
      if (fromTemplate != null) {
        final templateEntity = parentCell.getEntity(fromTemplate.templateEntityId);
        for (final c in templateEntity._getAllWithDepth(depth + 1)) {
          final typeName = c.componentType;
          if (!excludedTypes.contains(typeName) && !_nonInheritableTypes.contains(typeName)) {
            comps[typeName] = c;
          }
        }
      }
    }

    // Get direct components (override template values) - direct always wins, ignore exclusions
    parentCell.components.forEach((k, v) {
      if (v.containsKey(id)) {
        comps[k] = v[id]!;
      }
    });

    return comps.values.toList();
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

    final fromTemplate = _getDirectComponent<FromTemplate>('FromTemplate');
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
    final fromTemplate = _getDirectComponent<FromTemplate>('FromTemplate');
    if (fromTemplate != null) {
      final templateEntity = parentCell.getEntity(fromTemplate.templateEntityId);
      if (templateEntity._hasWithDepth(typeName, 0)) {
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
}