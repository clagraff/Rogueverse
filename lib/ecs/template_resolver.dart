import 'dart:async' show StreamSubscription, scheduleMicrotask;

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/events.dart';

/// Handles template inheritance resolution for the ECS.
///
/// Template entities allow sharing component definitions across multiple
/// entities. When an entity has a [FromTemplate] component, it can inherit
/// components from its template entity (with templates chaining supported).
///
/// This class consolidates all template-related logic:
/// - Component resolution (has/get operations with template fallback)
/// - Dependency tracking (which entities depend on which templates)
/// - Change propagation (notifying dependents when templates change)
class TemplateResolver {
  /// Maximum depth for template inheritance resolution.
  static const int maxDepth = 3;

  /// Component types that should NEVER be inherited from templates.
  /// These are marker/identity components that only apply to the specific entity.
  static const Set<String> nonInheritableTypes = {
    'IsTemplate',      // Template marker - only the template itself IS a template
    'FromTemplate',    // Template reference - each entity has its own (includes exclusions)
  };

  /// Storage accessor function for component lookups
  final Map<String, Map<int, Component>> Function() _getComponents;

  /// Entity getter function for resolving template entities
  final dynamic Function(int entityId) _getEntity;

  /// Change notification function
  final void Function(Change change) _notifyChange;

  /// Stream of component changes to listen for updates
  final Stream<Change> _componentChanges;

  /// Reverse index: template entity ID -> set of entities with FromTemplate pointing to it.
  /// Used for efficient event propagation when templates change.
  final Map<int, Set<int>> _templateDependents = {};

  /// Subscriptions for cleanup
  final List<StreamSubscription> _subscriptions = [];

  TemplateResolver({
    required Map<String, Map<int, Component>> Function() getComponents,
    required dynamic Function(int entityId) getEntity,
    required void Function(Change change) notifyChange,
    required Stream<Change> componentChanges,
  })  : _getComponents = getComponents,
        _getEntity = getEntity,
        _notifyChange = notifyChange,
        _componentChanges = componentChanges {
    _setupDependencyTracking();
    _setupChangeForwarding();
    _initializeIndex();
  }

  /// Check if entity has component (with template resolution).
  ///
  /// Resolution order:
  /// 1. Check if entity has component directly → true (direct always wins)
  /// 2. Check if [FromTemplate.excludedTypes] blocks type → false
  /// 3. If entity has [FromTemplate], recursively check template (up to 3 levels)
  bool has(int entityId, String typeName, {int depth = 0}) {
    final components = _getComponents();

    // 1. Check direct component FIRST - direct always wins
    final entitiesWithComponent = components[typeName] ?? {};
    if (entitiesWithComponent.containsKey(entityId)) {
      return true;
    }

    // 2. Check exclusions (only blocks template inheritance)
    final fromTemplate = _getDirectComponent<FromTemplate>(entityId);
    if (fromTemplate != null && fromTemplate.excludedTypes.contains(typeName)) {
      return false;
    }

    // 3. Check template (with depth limit) - but not for non-inheritable types
    if (depth < maxDepth && !nonInheritableTypes.contains(typeName)) {
      if (fromTemplate != null) {
        return has(fromTemplate.templateEntityId, typeName, depth: depth + 1);
      }
    }

    return false;
  }

  /// Get component (with template resolution).
  ///
  /// Returns the actual component instance (may be from template - not a copy).
  ///
  /// Resolution order:
  /// 1. Check if entity has component directly → return it (direct always wins)
  /// 2. Check if [FromTemplate.excludedTypes] blocks type → null
  /// 3. If entity has [FromTemplate], recursively check template (up to 3 levels)
  T? get<T extends Component>(int entityId, {int depth = 0}) {
    final typeName = T.toString();
    final components = _getComponents();

    // 1. Check direct component FIRST - direct always wins
    final entitiesWithComponent = components[typeName] ?? {};
    if (entitiesWithComponent.containsKey(entityId)) {
      return entitiesWithComponent[entityId] as T;
    }

    // 2. Check exclusions (only blocks template inheritance)
    final fromTemplate = _getDirectComponent<FromTemplate>(entityId);
    if (fromTemplate != null && fromTemplate.excludedTypes.contains(typeName)) {
      return null;
    }

    // 3. Check template (with depth limit) - but not for non-inheritable types
    if (depth < maxDepth && !nonInheritableTypes.contains(typeName)) {
      if (fromTemplate != null) {
        return get<T>(fromTemplate.templateEntityId, depth: depth + 1);
      }
    }

    return null;
  }

  /// Get component by type name (with template resolution).
  Component? getByName(int entityId, String componentType, {int depth = 0}) {
    final components = _getComponents();

    // 1. Check direct component FIRST - direct always wins
    final entitiesWithComponent = components[componentType] ?? {};
    if (entitiesWithComponent.containsKey(entityId)) {
      return entitiesWithComponent[entityId];
    }

    // 2. Check exclusions (only blocks template inheritance)
    final fromTemplate = _getDirectComponent<FromTemplate>(entityId);
    if (fromTemplate != null && fromTemplate.excludedTypes.contains(componentType)) {
      return null;
    }

    // 3. Check template (with depth limit) - but not for non-inheritable types
    if (depth < maxDepth && !nonInheritableTypes.contains(componentType)) {
      if (fromTemplate != null) {
        return getByName(fromTemplate.templateEntityId, componentType, depth: depth + 1);
      }
    }

    return null;
  }

  /// Get all components on an entity (including inherited from templates).
  ///
  /// Template components are included unless:
  /// - The entity has its own version (override)
  /// - The type is in [FromTemplate.excludedTypes]
  List<Component> getAll(int entityId, {int depth = 0}) {
    final comps = <String, Component>{};
    final components = _getComponents();

    // Get FromTemplate and its exclusions
    final fromTemplate = _getDirectComponent<FromTemplate>(entityId);
    final excludedTypes = fromTemplate?.excludedTypes ?? {};

    // Get template components first (lower priority - will be overridden)
    // But never inherit non-inheritable types or excluded types
    if (depth < maxDepth && fromTemplate != null) {
      for (final c in getAll(fromTemplate.templateEntityId, depth: depth + 1)) {
        final typeName = c.componentType;
        if (!excludedTypes.contains(typeName) && !nonInheritableTypes.contains(typeName)) {
          comps[typeName] = c;
        }
      }
    }

    // Get direct components (override template values) - direct always wins
    components.forEach((k, v) {
      if (v.containsKey(entityId)) {
        comps[k] = v[entityId]!;
      }
    });

    return comps.values.toList();
  }

  /// Get component directly without template resolution (internal helper).
  T? _getDirectComponent<T extends Component>(int entityId) {
    final components = _getComponents();
    final entitiesWithComponent = components[T.toString()] ?? {};
    return entitiesWithComponent[entityId] as T?;
  }

  /// Sets up reactive tracking of FromTemplate component changes.
  /// Updates _templateDependents index when FromTemplate is added/removed/changed.
  void _setupDependencyTracking() {
    final subscription = _componentChanges.listen((change) {
      if (change.componentType != 'FromTemplate') return;

      // Handle FromTemplate removal or change (remove old mapping)
      if (change.oldValue != null) {
        final old = change.oldValue as FromTemplate;
        _templateDependents[old.templateEntityId]?.remove(change.entityId);
      }

      // Handle FromTemplate addition or change (add new mapping)
      if (change.newValue != null) {
        final newFt = change.newValue as FromTemplate;
        _templateDependents
            .putIfAbsent(newFt.templateEntityId, () => {})
            .add(change.entityId);
      }
    });
    _subscriptions.add(subscription);
  }

  /// Sets up event propagation when template components change.
  /// When a template's component changes, emits synthetic Change events
  /// for all dependent entities so their listeners can update.
  void _setupChangeForwarding() {
    final subscription = _componentChanges.listen((change) {
      final entity = _getEntity(change.entityId);
      // Only propagate from template entities
      if (!entity.has<IsTemplate>()) return;
      // Don't propagate FromTemplate changes themselves
      if (change.componentType == 'FromTemplate') return;
      // Don't propagate IsTemplate changes
      if (change.componentType == 'IsTemplate') return;

      // Defer propagation to avoid re-entrancy (can't fire events while firing)
      scheduleMicrotask(() {
        _propagateToAllDependents(change.entityId, change);
      });
    });
    _subscriptions.add(subscription);
  }

  /// Propagates a component change from a template to all dependent entities.
  void _propagateToAllDependents(int templateId, Change originalChange) {
    final directDependents = _templateDependents[templateId] ?? {};
    final components = _getComponents();

    for (final dependentId in directDependents) {
      final dependent = _getEntity(dependentId);

      // Skip if dependent excludes this component (via FromTemplate.excludedTypes)
      final fromTemplate = dependent.get<FromTemplate>();
      if (fromTemplate?.excludedTypes.contains(originalChange.componentType) == true) {
        continue;
      }

      // Skip if dependent has its own override of this component
      final hasDirectComponent =
          components[originalChange.componentType]?.containsKey(dependentId) ?? false;
      if (hasDirectComponent) continue;

      // Emit synthetic change for this dependent
      _notifyChange(Change(
        entityId: dependentId,
        componentType: originalChange.componentType,
        oldValue: originalChange.oldValue,
        newValue: originalChange.newValue,
      ));

      // Recursively propagate if this dependent is also a template
      if (dependent.has<IsTemplate>()) {
        _propagateToAllDependents(dependentId, originalChange);
      }
    }
  }

  /// Initializes the template dependency index from existing FromTemplate components.
  /// Called on creation and should be called after loadFrom().
  void _initializeIndex() {
    _templateDependents.clear();
    final components = _getComponents();
    final fromTemplateMap = components['FromTemplate'] ?? {};
    for (final entry in fromTemplateMap.entries) {
      final ft = entry.value as FromTemplate;
      _templateDependents
          .putIfAbsent(ft.templateEntityId, () => {})
          .add(entry.key);
    }
  }

  /// Reinitialize the template dependency index.
  /// Call this after loading/reloading world data.
  void reinitialize() {
    _initializeIndex();
  }

  /// Get all entity IDs that depend on a given template
  Set<int> getDependents(int templateId) {
    return _templateDependents[templateId] ?? {};
  }

  /// Dispose of this resolver, cleaning up subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
