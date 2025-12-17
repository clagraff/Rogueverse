import 'package:rogueverse/ecs/components.dart' show LocalPosition, BlocksMovement;
import 'package:rogueverse/ecs/entity.dart' show Entity;
import 'package:rogueverse/ecs/entity_template.dart' show EntityTemplate;
import 'package:rogueverse/ecs/query.dart' show Query;
import 'package:rogueverse/ecs/world.dart' show World;

/// Utility class for manipulating entities in the ECS world.
///
/// Centralizes entity placement and removal logic with toggle behavior
/// (placing on an occupied cell removes the existing entity).
class EntityManipulator {
  /// Places an entity at the specified position, or toggles off if already occupied.
  ///
  /// If there's already an entity with [BlocksMovement] at [pos], it will be destroyed
  /// (toggle off). Otherwise, a new entity will be created from [template] (toggle on).
  ///
  /// Parameters:
  /// - [world]: The ECS world to manipulate
  /// - [template]: The entity template to instantiate
  /// - [pos]: The grid position to place the entity
  static void placeEntity(World world, EntityTemplate template, LocalPosition pos) {
    // Check for existing BlocksMovement entities
    final existing = queryBlockingAt(world, pos);

    if (existing.isNotEmpty) {
      // Toggle off - remove existing entities
      for (var entity in existing) {
        entity.destroy();
      }
    } else {
      // Toggle on - place new entity from template
      template.build(world, baseComponents: [pos]);
    }
  }

  /// Removes all entities with [BlocksMovement] at the specified position.
  ///
  /// Unlike [placeEntity], this always removes and never places.
  ///
  /// Parameters:
  /// - [world]: The ECS world to manipulate
  /// - [pos]: The grid position to remove entities from
  static void removeEntitiesAt(World world, LocalPosition pos) {
    final entities = queryBlockingAt(world, pos);
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
  static List<Entity> queryBlockingAt(World world, LocalPosition pos) {
    return Query()
        .require<LocalPosition>((lp) => lp.x == pos.x && lp.y == pos.y)
        .require<BlocksMovement>()
        .find(world)
        .toList();
  }
}
