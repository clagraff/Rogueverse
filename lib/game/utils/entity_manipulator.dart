import 'package:rogueverse/ecs/components.dart' show LocalPosition, BlocksMovement, HasParent, FromTemplate, Component;
import 'package:rogueverse/ecs/entity.dart' show Entity;
import 'package:rogueverse/ecs/query.dart' show Query;
import 'package:rogueverse/ecs/world.dart' show World;

/// Utility class for manipulating entities in the ECS world.
///
/// Centralizes entity placement and removal logic. Placement always replaces
/// existing entities at the target position.
class EntityManipulator {
  /// Places an entity at the specified position, replacing any existing entity.
  ///
  /// If there's already an entity with [BlocksMovement] at [pos], it will be destroyed
  /// and replaced with a new entity linked to [templateEntityId] via FromTemplate.
  ///
  /// Parameters:
  /// - [world]: The ECS world to manipulate
  /// - [templateEntityId]: The ID of the template entity to link to
  /// - [pos]: The grid position to place the entity
  /// - [parentId]: The parent entity ID (for room containment)
  static void placeEntity(World world, int templateEntityId, LocalPosition pos, int? parentId) {
    // Remove existing BlocksMovement entities
    final existing = queryBlockingAt(world, pos, parentId);
    for (var entity in existing) {
      entity.destroy();
    }

    // Create new entity with FromTemplate reference
    final components = <Component>[
      FromTemplate(templateEntityId),
      pos,
    ];
    if (parentId != null) {
      components.add(HasParent(parentId));
    }
    world.add(components);
  }

  /// Removes all entities with [BlocksMovement] at the specified position.
  ///
  /// Unlike [placeEntity], this always removes and never places.
  ///
  /// Parameters:
  /// - [world]: The ECS world to manipulate
  /// - [pos]: The grid position to remove entities from
  static void removeEntitiesAt(World world, LocalPosition pos, int? parentId) {
    final entities = queryBlockingAt(world, pos, parentId);
    for (var entity in entities) {
      entity.destroy();
    }
  }

  /// Queries for entities with [BlocksMovement] at the specified position.
  ///
  /// Returns a list of entities that occupy the grid cell at [pos] and
  /// have the [BlocksMovement] component.
  ///
  /// Parameters:
  /// - [world]: The ECS world to query
  /// - [pos]: The grid position to check
  ///
  /// Returns a list of [Entity] objects (may be empty if no blocking entities exist).
  static List<Entity> queryBlockingAt(World world, LocalPosition pos, int? parentId) {
    var query = Query()
        .require<LocalPosition>((lp) => lp.x == pos.x && lp.y == pos.y)
        .require<BlocksMovement>();

    if (parentId != null) {
      query = query.require<HasParent>((p) => p.parentEntityId == parentId);
    } else {
      query = query.exclude<HasParent>();
    }

    return query
        .find(world)
        .toList();
  }
}
