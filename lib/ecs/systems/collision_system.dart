import 'dart:developer';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'collision_system.mapper.dart';

/// A system that handles collision detection by checking for blocked movement.
///
/// If an entity attempts to move into an occupied tile, its move is cancelled.
/// Uses hierarchy-scoped queries: only checks collisions with sibling entities (same parent).
@MappableClass()
class CollisionSystem extends System with CollisionSystemMappable {
  static final _logger = Logger('CollisionSystem');

  @override
  void update(World world) {
    Timeline.timeSync("CollisionSystem: update", () {
      Timeline.startSync("CollisionSystem: gets");
      final positions = world.get<LocalPosition>();
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

        final dest = LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy);
        var blocked = false;

        // Get entities to check for collisions
        // If entity has parent, only check siblings (same parent)
        // Otherwise, check all entities (backward compatibility)
        final parentId = e.get<HasParent>()?.parentEntityId;

        if (parentId != null) {
          // Hierarchy-scoped: check only siblings
          final siblings = world.hierarchyCache.getSiblings(id);

          for (final siblingId in siblings) {
            final sibling = world.getEntity(siblingId);
            if (!sibling.has<BlocksMovement>()) continue;

            final siblingPos = sibling.get<LocalPosition>();
            if (siblingPos != null &&
                siblingPos.x == dest.x &&
                siblingPos.y == dest.y) {
              blocked = true;
              break;
            }
          }
        } else {
          // No parent: check all entities (old behavior)
          positions.forEach((key, value) {
            if (value.x == dest.x &&
                value.y == dest.y &&
                world.getEntity(key).has<BlocksMovement>()) {
              blocked = true;
            }
          });
        }

        if (blocked) {
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
