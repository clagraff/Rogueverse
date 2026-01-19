import 'dart:collection';
import 'dart:developer';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'behavior_system.mapper.dart';

/// Executes AI behavior trees to generate intents for entities.
///
/// Emits intents (MoveByIntent, AttackIntent, etc.) that other systems process.
@MappableClass()
class BehaviorSystem extends BudgetedSystem with BehaviorSystemMappable {
  static final _logger = Logger('BehaviorSystem');

  final Queue<(Entity entity, Behavior behavior)> queue = Queue<(Entity entity, Behavior behavior)>();

  /// Schedule AI behaviors to be processed during the budget run.
  @override
  void update(World world) {
    Timeline.timeSync("BehaviorSystem: update", () {
      final behaviors = world.get<Behavior>();
      behaviors.forEach((e, b) {
        var entity = world.getEntity(e);
        queue.addLast((entity, b));
      });
    });
  }

  /// Process AI behavior trees within the given duration. May exceed duration.
  @override
  bool budget(World world, Duration budget) {
    return Timeline.timeSync("BehaviorSystem: budget", () {
      final sw = Stopwatch()..start();
      if (queue.isEmpty) {
        return false;
      }

      while (sw.elapsed < budget && queue.isNotEmpty) {
        var entry = queue.removeFirst();
        var entity =  entry.$1;
        var behaviorComponent = entry.$2;

        var result = behaviorComponent.behavior.tick(entity);
        _logger.finest("ran behavior tree", {"entity": entity, "node": behaviorComponent.behavior.runtimeType, "result": result});

        if (queue.isEmpty) {
          _logger.finest('behavior queue is empty');
          return false;
        }
      }

      return true;
    });
  }
}
