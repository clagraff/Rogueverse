import 'dart:developer';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/systems/collision_system.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'movement_system.mapper.dart';

/// A system that processes unblocked movement requests.
///
/// Updates positions and adds [DidMove] to track movement history.
/// Must run after CollisionSystem (which removes blocked MoveByIntents).
@MappableClass()
class MovementSystem extends System with MovementSystemMappable {
  static final _logger = Logger('MovementSystem');

  @override
  Set<Type> get runAfter => {CollisionSystem};

  @override
  void update(World world) {
    Timeline.timeSync("MovementSystem: update", () {
      final moveIntents = world.get<MoveByIntent>();
      final ids = moveIntents.keys.toList();

      for (final id in ids) {
        final e = world.getEntity(id);
        _logger.finest("moving entity", {"entity": e});

        // Skip if entity is docked
        if (e.has<Docked>()) {
          _logger.finest("skipping docked entity movement", {"entity": e});
          continue;
        }

        final pos = e.get<LocalPosition>();
        final intent = e.get<MoveByIntent>();
        if (pos == null || intent == null) {
          _logger.warning("cannot move due to missing position or intent", {"entity": e, "pos": pos, "intent": intent});
          continue;
        }

        final from = LocalPosition(x: pos.x, y: pos.y);
        final to = LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy);

        e.upsert<LocalPosition>(
            LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy));

        // Emit DirectionIntent based on movement (DirectionSystem will update Direction)
        // Skip if this is a strafe movement (maintain current direction)
        if (!intent.isStrafe) {
          e.upsert(DirectionIntent(Direction.fromOffset(intent.dx, intent.dy)));
        }

        e.upsert(DidMove(from: from, to: to));
        e.remove<MoveByIntent>();

        final direction = e.get<Direction>();
        _logger.finest("moved entity", {"entity": e, "from": from, "to": to, "direction": direction?.facing});
      }
    });
  }
}
