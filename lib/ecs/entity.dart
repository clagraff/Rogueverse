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
    'FromTemplate',    // Template reference - each entity has its own
    'ExcludesComponent', // Exclusions are per-entity
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
  /// 1. Check if entity has [ExcludesComponent] blocking type C → false
  /// 2. Check if entity has component C directly → true
  /// 3. If entity has [FromTemplate], recursively check template (up to 3 levels)
  bool has<C extends Component>() {
    return _hasWithDepth(C.toString(), 0);
  }

  /// Check if entity has component by type name (for Query system).
  bool hasType(String typeName) {
    return _hasWithDepth(typeName, 0);
  }

  bool _hasWithDepth(String typeName, int depth) {
    // 1. Check exclusions
    final excludes = _getDirectComponent<ExcludesComponent>('ExcludesComponent');
    if (excludes != null && excludes.excludedTypes.contains(typeName)) {
      return false;
    }

    // 2. Check direct component
    var entitiesWithComponent = parentCell.components[typeName] ?? {};
    if (entitiesWithComponent.containsKey(id)) {
      return true;
    }

    // 3. Check template (with depth limit) - but not for non-inheritable types
    if (depth < _maxTemplateDepth && !_nonInheritableTypes.contains(typeName)) {
      final fromTemplate = _getDirectComponent<FromTemplate>('FromTemplate');
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
  /// 1. Check if entity has [ExcludesComponent] blocking type C → null (or apply default)
  /// 2. Check if entity has component C directly → return it
  /// 3. If entity has [FromTemplate], recursively check template (up to 3 levels)
  /// 4. Apply orDefault if provided (stores on entity, not template)
  C? get<C extends Component>([C? orDefault]) {
    return _getWithDepth<C>(C.toString(), orDefault, 0);
  }

  C? _getWithDepth<C extends Component>(String typeName, C? orDefault, int depth) {
    // 1. Check exclusions
    final excludes = _getDirectComponent<ExcludesComponent>('ExcludesComponent');
    if (excludes != null && excludes.excludedTypes.contains(typeName)) {
      // If excluded and orDefault provided, add to entity
      if (orDefault != null) {
        _setDirectComponent(typeName, orDefault);
        return orDefault;
      }
      return null;
    }

    // 2. Check direct component
    var entitiesWithComponent = parentCell.components[typeName] ?? {};
    if (entitiesWithComponent.containsKey(id)) {
      return entitiesWithComponent[id] as C;
    }

    // 3. Check template (with depth limit) - but not for non-inheritable types
    if (depth < _maxTemplateDepth && !_nonInheritableTypes.contains(typeName)) {
      final fromTemplate = _getDirectComponent<FromTemplate>('FromTemplate');
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
    // 1. Check exclusions
    final excludes = _getDirectComponent<ExcludesComponent>('ExcludesComponent');
    if (excludes != null && excludes.excludedTypes.contains(componentType)) {
      if (orDefault != null) {
        _setDirectComponent(componentType, orDefault);
        return orDefault;
      }
      return null;
    }

    // 2. Check direct component
    var entitiesWithComponent = parentCell.components[componentType] ?? {};
    if (entitiesWithComponent.containsKey(id)) {
      return entitiesWithComponent[id] as Component;
    }

    // 3. Check template (with depth limit) - but not for non-inheritable types
    if (depth < _maxTemplateDepth && !_nonInheritableTypes.contains(componentType)) {
      final fromTemplate = _getDirectComponent<FromTemplate>('FromTemplate');
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
  /// - The entity has [ExcludesComponent] blocking that type
  List<Component> getAll() {
    return _getAllWithDepth(0);
  }

  List<Component> _getAllWithDepth(int depth) {
    final comps = <String, Component>{};

    // Get exclusions first
    final excludes = _getDirectComponent<ExcludesComponent>('ExcludesComponent');
    final excludedTypes = excludes?.excludedTypes ?? {};

    // Get template components first (lower priority - will be overridden)
    // But never inherit non-inheritable types
    if (depth < _maxTemplateDepth) {
      final fromTemplate = _getDirectComponent<FromTemplate>('FromTemplate');
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

    // Get direct components (override template values)
    parentCell.components.forEach((k, v) {
      if (v.containsKey(id) && !excludedTypes.contains(k)) {
        comps[k] = v[id]!;
      }
    });

    return comps.values.toList();
  }

  void upsert<C extends Component>(C c) {
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
    var entitiesWithComponent = parentCell.components.putIfAbsent(c.componentType, () => {});
    var existing = entitiesWithComponent.entries.firstWhereOrNull((e) => e.key == id);

    entitiesWithComponent[id] = c;

    parentCell.notifyChange(Change(entityId: id, componentType: c.componentType, oldValue: existing?.value, newValue: c));
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
  /// If the component comes from a template (via [FromTemplate]), an
  /// [ExcludesComponent] is added to block inheritance of that type.
  void remove<C>() {
    _removeByTypeName(C.toString());
  }

  /// Removes component by type name.
  ///
  /// If the entity has the component directly, it is removed.
  /// If the component comes from a template (via [FromTemplate]), an
  /// [ExcludesComponent] is added to block inheritance of that type.
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
    } else {
      // Check if it comes from a template
      final fromTemplate = _getDirectComponent<FromTemplate>('FromTemplate');
      if (fromTemplate != null) {
        final templateEntity = parentCell.getEntity(fromTemplate.templateEntityId);
        if (templateEntity._hasWithDepth(typeName, 0)) {
          // Component comes from template - add exclusion
          _addExclusion(typeName);
        }
      }
    }
  }

  /// Add a component type to [ExcludesComponent] (internal helper).
  void _addExclusion(String typeName) {
    final existing = _getDirectComponent<ExcludesComponent>('ExcludesComponent');
    final newExcludes = existing != null
        ? ExcludesComponent({...existing.excludedTypes, typeName})
        : ExcludesComponent.single(typeName);
    upsertByName(newExcludes);
  }

  void destroy() {
    _logger.finest("destroyed entity", {"entity": this});
    parentCell.remove(id);
  }
}