import 'package:dart_mappable/dart_mappable.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';

part 'entity_template.mapper.dart';

/// A serializable template for spawning entities with a predefined set of components.
///
/// Unlike the old builder pattern, this stores actual component instances which
/// can be serialized to/from JSON for persistence. Each template has a unique ID
/// and a user-friendly display name.
///
/// Example:
/// ```dart
/// final wallTemplate = EntityTemplate(
///   id: 'wall-stone',
///   displayName: 'Stone Wall',
///   components: [
///     Name(name: 'Wall'),
///     Renderable('images/wall.svg'),
///     BlocksMovement(),
///   ],
/// );
///
/// final wall = wallTemplate.build(world);
/// ```
@MappableClass()
class EntityTemplate with EntityTemplateMappable {
  /// Unique identifier for this template.
  ///
  /// Generated sequentially by the TemplateRegistry. Used for internal referencing and storage.
  final int id;

  /// User-friendly display name for this template.
  ///
  /// Shown in the UI when browsing templates. Can be duplicated across templates.
  /// This is NOT the same as a Name component - templates may or may not have
  /// Name components in their component list.
  final String displayName;

  /// The components that will be added to entities created from this template.
  ///
  /// These are the actual component instances that will be copied to new entities.
  /// The list should not include LocalPosition as that's typically added at
  /// placement time based on where the entity is spawned.
  @MappableField(hook: ComponentListHook())
  final List<Component> components;

  EntityTemplate({
    required this.id,
    required this.displayName,
    required this.components,
  });

  /// Builds a new entity from this template.
  ///
  /// Creates an entity in the given world with all components from the template.
  /// Additional base components can be provided (e.g., LocalPosition).
  ///
  /// Note: LocalPosition components in the template are skipped since position
  /// should be provided via baseComponents at placement time.
  Entity build(World world, {List<Component> baseComponents = const []}) {
    final entity = world.add([...baseComponents]);

    // Add all template components to the entity, skipping LocalPosition
    // since position is provided at placement time via baseComponents
    for (final component in components) {
      if (component is! LocalPosition) {
        entity.upsertByName(component);
      }
    }

    return entity;
  }


  /// Extracts components from an entity to create a template.
  ///
  /// This is used when saving an entity from the inspector as a new template.
  /// Retrieves all components currently attached to the entity.
  ///
  /// Note: LocalPosition components are excluded from templates since entity
  /// position should be determined at placement time, not stored in the template.
  static EntityTemplate fromEntity({
    required int id,
    required String displayName,
    required Entity entity,
  }) {
    final components = <Component>[];

    // Get all component types from the world
    final world = entity.parentCell;
    for (final componentTypeEntry in world.components.entries) {
      final componentMap = componentTypeEntry.value;
      final component = componentMap[entity.id];

      // Skip LocalPosition - it should be set at placement time, not in template
      if (component != null && component is! LocalPosition) {
        components.add(component);
      }
    }

    return EntityTemplate(
      id: id,
      displayName: displayName,
      components: components,
    );
  }

  /// Gets the Renderable component if this template has one.
  ///
  /// Used by the UI to display the template's icon.
  Renderable? get renderable {
    try {
      return components.firstWhere((c) => c is Renderable) as Renderable;
    } catch (e) {
      return null;
    }
  }
}

/// A dart_mappable hook to handle serializing/deserializing the component list.
///
/// Necessary because components are polymorphic - we need to preserve their
/// concrete types during JSON serialization.
class ComponentListHook extends MappingHook {
  const ComponentListHook();

  @override
  Object? beforeDecode(Object? value) {
    final list = value as List<dynamic>;
    return list
        .map((item) => MapperContainer.globals.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Object? beforeEncode(Object? value) {
    final list = value as List<Component>;
    return list.map((component) => MapperContainer.globals.toMap(component)).toList();
  }
}
