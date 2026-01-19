import 'package:rogueverse/ecs/components.dart';

/// Pure storage operations for ECS components.
///
/// Provides low-level component storage without change notifications or
/// template resolution. Used internally by World for data management.
class ComponentStorage {
  /// Internal component storage: component type name -> entity ID -> component
  final Map<String, Map<int, Component>> _components;

  /// Counter for generating unique entity IDs (public for serialization)
  int lastId;

  ComponentStorage([Map<String, Map<int, Component>>? components, this.lastId = 0])
      : _components = components ?? {};

  /// Get all entities with component of type C
  Map<int, C> get<C extends Component>() {
    return _components.putIfAbsent(C.toString(), () => {}).cast<int, C>();
  }

  /// Get components by string type name
  Map<int, Component> getByName(String componentType) {
    return _components.putIfAbsent(componentType, () => {});
  }

  /// Check if entity has a component by type name
  bool has(int entityId, String componentType) {
    final map = _components[componentType];
    return map?.containsKey(entityId) ?? false;
  }

  /// Get a specific component from an entity
  T? getComponent<T extends Component>(int entityId) {
    final map = _components[T.toString()];
    return map?[entityId] as T?;
  }

  /// Get a specific component from an entity by type name
  Component? getComponentByName(int entityId, String componentType) {
    final map = _components[componentType];
    return map?[entityId];
  }

  /// Set component on entity (returns old value if any)
  Component? set(int entityId, Component c) {
    final map = _components.putIfAbsent(c.componentType, () => {});
    final oldValue = map[entityId];
    map[entityId] = c;
    return oldValue;
  }

  /// Remove component from entity (returns removed value if any)
  Component? remove(int entityId, String componentType) {
    final map = _components[componentType];
    return map?.remove(entityId);
  }

  /// Create new entity ID
  int createEntityId() => lastId++;

  /// Get all entity IDs that have at least one component
  Set<int> get allEntityIds {
    final ids = <int>{};
    for (final map in _components.values) {
      ids.addAll(map.keys);
    }
    return ids;
  }

  /// Clear all components from an entity
  void removeEntity(int entityId) {
    for (final map in _components.values) {
      map.remove(entityId);
    }
  }

  /// Clear all data
  void clear() {
    _components.clear();
  }

  /// Direct access to the raw components map (for serialization/deserialization)
  Map<String, Map<int, Component>> get components => _components;

  /// Load components from a map (used during deserialization)
  void loadFrom(Map<String, Map<int, Component>> newComponents) {
    _components.clear();
    _components.addAll(newComponents);
  }
}
