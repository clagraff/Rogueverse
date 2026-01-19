import 'dart:developer';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/systems/behavior_system.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'collision_system.mapper.dart';

/// A system that handles collision detection by checking for blocked movement.
///
/// If an entity attempts to move into an occupied tile, its move is cancelled.
/// Uses hierarchy-scoped queries: only checks collisions with sibling entities (same parent).
///
/// Must run after BehaviorSystem (which emits MoveByIntent) and before MovementSystem.
@MappableClass()
class CollisionSystem extends System with CollisionSystemMappable {
  static final _logger = Logger('CollisionSystem');

  @override
  Set<Type> get runAfter => {BehaviorSystem};

  @override
  void update(World world) {
    Timeline.timeSync("CollisionSystem: update", () {
      Timeline.startSync("CollisionSystem: gets");
      final blocks = world.get<BlocksMovement>();
      final moveIntents = world.get<MoveByIntent>();

      final movingEntityIds = moveIntents.keys.toList();
      Timeline.finishSync();

      if (blocks.isEmpty) return;

      for (final id in movingEntityIds) {
        final e = world.getEntity(id);
        final pos = e.get<LocalPosition>();
        final intent = e.get<MoveByIntent>();

        if (pos == null || intent == null) continue;

        final destX = pos.x + intent.dx;
        final destY = pos.y + intent.dy;
        final parentId = e.get<HasParent>()?.parentEntityId;

        // O(1) spatial index lookup instead of O(n) scan
        final blocked = world.spatial.hasEntityAt(
          destX,
          destY,
          parentId: parentId,
          predicate: (entityId) => world.getEntity(entityId).has<BlocksMovement>(),
        );

        if (blocked) {
          final dest = LocalPosition(x: destX, y: destY);
          // Emit DirectionIntent even when movement is blocked (DirectionSystem will update Direction)
          // Skip if this is a strafe movement (maintain current direction)
          if (!intent.isStrafe) {
            e.upsert(DirectionIntent(Direction.fromOffset(intent.dx, intent.dy)));
          }
          e.upsert(BlockedMove(dest));
          e.remove<MoveByIntent>();

          _logger.finest("collision blocked", {"entity": e, "from": pos, "to": dest});
        }
      }
    });
  }
}
