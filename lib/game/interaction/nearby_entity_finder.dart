import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/interaction/interaction_definition.dart';
import 'package:rogueverse/game/interaction/interaction_registry.dart';

/// Result of finding interactable entities nearby.
class InteractableEntity {
  final Entity entity;
  final List<InteractionDefinition> availableInteractions;

  InteractableEntity({
    required this.entity,
    required this.availableInteractions,
  });

  /// Gets the display name for this entity.
  /// Uses the Name component if available, otherwise falls back to the
  /// generic label from the first available interaction.
  String get displayName {
    final name = entity.get<Name>()?.name;
    if (name != null) return name;
    if (availableInteractions.isNotEmpty) {
      return availableInteractions.first.genericLabel;
    }
    return 'Unknown';
  }
}

/// Result containing both target interactions and self-actions.
class InteractionFinderResult {
  /// Entities with available target interactions.
  final List<InteractableEntity> targetInteractions;

  /// Self-actions available to the player (e.g., Wait).
  final List<InteractionDefinition> selfActions;

  InteractionFinderResult({
    required this.targetInteractions,
    required this.selfActions,
  });

  /// Returns true if there are any interactions available.
  bool get hasInteractions =>
      targetInteractions.isNotEmpty || selfActions.isNotEmpty;
}

/// Finds entities near the player that have available interactions.
class NearbyEntityFinder {
  /// Find all available interactions for the player.
  ///
  /// Returns both target interactions (on nearby entities) and self-actions.
  /// Only includes entities that are currently visible to the player.
  ///
  /// [world] - The ECS world to query.
  /// [origin] - The player's current position.
  /// [parentId] - The parent entity ID for scoping (null = root level).
  /// [playerEntity] - The player entity (for visibility and self-action checks).
  static InteractionFinderResult findAllInteractions({
    required World world,
    required LocalPosition origin,
    required int? parentId,
    required Entity playerEntity,
  }) {
    return InteractionFinderResult(
      targetInteractions: findInteractableEntities(
        world: world,
        origin: origin,
        parentId: parentId,
        playerEntity: playerEntity,
      ),
      selfActions: findSelfActions(playerEntity),
    );
  }

  /// Find all entities that have at least one available interaction within range.
  ///
  /// Each interaction has its own range - an entity is included if ANY of its
  /// interactions are within range of the [origin] position.
  /// Only includes entities that are currently visible to the player.
  /// Results are sorted by alignment with the player's facing direction.
  ///
  /// [world] - The ECS world to query.
  /// [origin] - The player's current position.
  /// [parentId] - The parent entity ID for scoping (null = root level).
  /// [playerEntity] - The player entity (for visibility checks).
  static List<InteractableEntity> findInteractableEntities({
    required World world,
    required LocalPosition origin,
    required int? parentId,
    required Entity playerEntity,
  }) {
    final results = <int, InteractableEntity>{};

    // Get visible entities from the player's vision
    final visibleEntities = playerEntity.get<VisibleEntities>();

    // For each registered target interaction type, find entities within range
    for (final interaction in InteractionRegistry.interactions) {
      final entitiesForInteraction = _findEntitiesForInteraction(
        world: world,
        origin: origin,
        parentId: parentId,
        interaction: interaction,
      );

      // Add to results, merging interactions for same entity
      for (final entity in entitiesForInteraction) {
        // Skip entities that aren't currently visible
        if (visibleEntities != null && !visibleEntities.entityIds.contains(entity.id)) {
          continue;
        }

        if (results.containsKey(entity.id)) {
          results[entity.id]!.availableInteractions.add(interaction);
        } else {
          results[entity.id] = InteractableEntity(
            entity: entity,
            availableInteractions: [interaction],
          );
        }
      }
    }

    // Sort by direction alignment (entities in front first)
    final facing = playerEntity.get<Direction>()?.facing;
    final resultList = results.values.toList();

    if (facing != null) {
      resultList.sort((a, b) {
        final scoreA = _directionAlignmentScore(origin, a.entity, facing);
        final scoreB = _directionAlignmentScore(origin, b.entity, facing);
        return scoreA.compareTo(scoreB);
      });
    }

    return resultList;
  }

  /// Find all available self-actions for the player.
  static List<InteractionDefinition> findSelfActions(Entity playerEntity) {
    return InteractionRegistry.selfInteractions
        .where((interaction) => interaction.isAvailable(playerEntity))
        .toList();
  }

  /// Find entities within range that have a specific interaction available.
  static List<Entity> _findEntitiesForInteraction({
    required World world,
    required LocalPosition origin,
    required int? parentId,
    required InteractionDefinition interaction,
  }) {
    final results = <Entity>[];

    // Query all entities with LocalPosition in the same parent context
    var query = Query().require<LocalPosition>();
    _applyParentFilter(query, parentId);

    for (final entity in query.find(world)) {
      // Check if interaction is available for this entity
      if (!interaction.isAvailable(entity)) continue;

      // Check if entity is within range
      final entityPos = entity.get<LocalPosition>()!;
      final distance = _manhattanDistance(origin, entityPos);

      if (distance <= interaction.range) {
        results.add(entity);
      }
    }

    return results;
  }

  /// Calculate Manhattan distance between two positions.
  static int _manhattanDistance(LocalPosition a, LocalPosition b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }

  /// Applies parent filtering to a query.
  static void _applyParentFilter(Query query, int? parentId) {
    if (parentId == null) {
      query.exclude<HasParent>();
    } else {
      query.require<HasParent>((p) => p.parentEntityId == parentId);
    }
  }

  /// Gets the display name for an entity, with fallback to generic label.
  static String getEntityDisplayName(
    Entity entity,
    InteractionDefinition interaction,
  ) {
    return entity.get<Name>()?.name ?? interaction.genericLabel;
  }

  /// Calculates how well an entity's position aligns with the player's facing direction.
  /// Lower score = better alignment (entity is more in front).
  /// 0 = directly in facing direction
  /// 1 = adjacent direction (45° off)
  /// 2 = perpendicular (90° off)
  /// 3 = adjacent to opposite (135° off)
  /// 4 = opposite direction (180° off)
  static int _directionAlignmentScore(
    LocalPosition origin,
    Entity target,
    CompassDirection facing,
  ) {
    final targetPos = target.get<LocalPosition>();
    if (targetPos == null) return 4; // No position = lowest priority

    // Calculate direction from origin to target
    final dx = targetPos.x - origin.x;
    final dy = targetPos.y - origin.y;

    // Same position = highest priority
    if (dx == 0 && dy == 0) return 0;

    // Determine the compass direction to the target
    final toTarget = _vectorToCompassDirection(dx, dy);
    if (toTarget == null) return 4;

    // Calculate angular difference
    return _compassDirectionDistance(facing, toTarget);
  }

  /// Converts a direction vector to a CompassDirection.
  static CompassDirection? _vectorToCompassDirection(int dx, int dy) {
    // Normalize to -1, 0, or 1
    final nx = dx == 0 ? 0 : (dx > 0 ? 1 : -1);
    final ny = dy == 0 ? 0 : (dy > 0 ? 1 : -1);

    return switch ((nx, ny)) {
      (0, -1) => CompassDirection.north,
      (0, 1) => CompassDirection.south,
      (1, 0) => CompassDirection.east,
      (-1, 0) => CompassDirection.west,
      (1, -1) => CompassDirection.northeast,
      (-1, -1) => CompassDirection.northwest,
      (1, 1) => CompassDirection.southeast,
      (-1, 1) => CompassDirection.southwest,
      _ => null,
    };
  }

  /// Calculates the "distance" between two compass directions (0-4).
  /// 0 = same, 1 = 45°, 2 = 90°, 3 = 135°, 4 = 180°
  static int _compassDirectionDistance(CompassDirection a, CompassDirection b) {
    if (a == b) return 0;

    // Map directions to angles (in 45° increments, 0-7)
    const angleMap = {
      CompassDirection.east: 0,
      CompassDirection.northeast: 1,
      CompassDirection.north: 2,
      CompassDirection.northwest: 3,
      CompassDirection.west: 4,
      CompassDirection.southwest: 5,
      CompassDirection.south: 6,
      CompassDirection.southeast: 7,
    };

    final angleA = angleMap[a]!;
    final angleB = angleMap[b]!;

    // Calculate minimum angular distance (wrapping around)
    var diff = (angleA - angleB).abs();
    if (diff > 4) diff = 8 - diff;

    return diff;
  }
}
