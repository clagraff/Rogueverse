import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';

/// Metadata and behavior for a specific component type in the inspector.
///
/// Each component type should have a corresponding [ComponentMetadata] instance
/// that defines how to display, create, and remove that component. This allows
/// the inspector to dynamically handle any registered component without hardcoded
/// switch statements.
abstract class ComponentMetadata {
  /// The display name of the component (e.g., "Name", "LocalPosition").
  String get componentName;

  /// Checks if the given entity has this component attached.
  bool hasComponent(Entity entity);

  /// Builds the content area for this component's properties.
  ///
  /// This is called when the component section is expanded. The widget should
  /// typically use a StreamBuilder to reactively update when component data changes.
  Widget buildContent(Entity entity);

  /// Creates a default instance of this component with sensible initial values.
  ///
  /// Used by the "Add Component" button to add new components to entities.
  Component createDefault();

  /// Removes this component from the given entity.
  void removeComponent(Entity entity);
}

/// Central registry for all component types that can be displayed in the inspector.
///
/// Components must be registered at app startup before the inspector is used.
/// Each component type should register its own [ComponentMetadata] implementation.
///
/// Example usage:
/// ```dart
/// ComponentRegistry.register(NameMetadata());
/// ComponentRegistry.register(HealthMetadata());
/// ```
class ComponentRegistry {
  /// Map of component names to their metadata implementations.
  static final Map<String, ComponentMetadata> _metadata = {};

  /// Registers a component metadata implementation.
  ///
  /// This should be called during app initialization for each component type
  /// that should be visible in the inspector.
  static void register(ComponentMetadata metadata) {
    _metadata[metadata.componentName] = metadata;
  }

  /// Returns all registered component metadata instances.
  ///
  /// Used by the inspector to display all components present on an entity.
  static List<ComponentMetadata> getAll() => _metadata.values.toList();

  /// Returns metadata for components that are not currently on the entity.
  ///
  /// Used by the "Add Component" button to show only components that can
  /// be added (i.e., ones not already present).
  static List<ComponentMetadata> getAvailable(Entity entity) {
    return _metadata.values
        .where((metadata) => !metadata.hasComponent(entity))
        .toList();
  }

  /// Returns metadata for components that are currently on the entity.
  ///
  /// Used by the inspector to display only the sections for components
  /// that the entity actually has.
  static List<ComponentMetadata> getPresent(Entity entity) {
    return _metadata.values
        .where((metadata) => metadata.hasComponent(entity))
        .toList();
  }

  /// Clears all registered components.
  ///
  /// Primarily used for testing. In production, components are typically
  /// registered once at startup and never cleared.
  static void clear() {
    _metadata.clear();
  }
}
