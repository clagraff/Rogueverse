import 'dart:developer';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/systems/collision_system.dart';
import 'package:rogueverse/ecs/systems/movement_system.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'direction_system.mapper.dart';

/// Processes DirectionIntent and updates Direction component.
///
/// Must run after CollisionSystem and MovementSystem (both emit DirectionIntent).
@MappableClass()
class DirectionSystem extends System with DirectionSystemMappable {
  static final _logger = Logger('DirectionSystem');

  @override
  Set<Type> get runAfter => {CollisionSystem, MovementSystem};

  @override
  void update(World world) {
    Timeline.timeSync("DirectionSystem: update", () {
      final intents = world.get<DirectionIntent>();

      for (final id in intents.keys.toList()) {
        final e = world.getEntity(id);
        final intent = e.get<DirectionIntent>();
        if (intent == null) continue;

        final current = e.get<Direction>()?.facing ?? CompassDirection.south;
        final newDir = intent.direction;

        // Only record DidChangeDirection if direction changed AND entity didn't move
        // (DidMove indicates movement already happened)
        if (current != newDir && !e.has<DidMove>()) {
          e.upsert(DidChangeDirection(from: current, to: newDir));
        }

        e.upsert(Direction(newDir));
        e.remove<DirectionIntent>();

        _logger.finest("direction set", {"entity": e, "direction": newDir});
      }
    });
  }
}
