import 'dart:math';

import 'package:flame/effects.dart';
import '../../ai/ai.barrel.dart';
import '../../ecs/ecs.barrel.dart' as ecs;
import '../../ui/components/components.barrel.dart';

var random = Random();

class Opponent extends Agent {
  final ecs.World world;
  Effect? effect;
  late BehaviorTree tree;

  Opponent(this.world,
      {required super.registry,
      required super.entity,
      required super.svgAssetPath,
      super.position,
      super.size}) {
    tree = BehaviorTree(ActionNode((b) {
      entity.upsert<ecs.MoveByIntent>(
          ecs.MoveByIntent(dx: random.nextInt(3) - 1, dy: random.nextInt(3) - 1));
      return BehaviorStatus.success;
    }), blackboard: Blackboard());
  }

  static const movementDistance = 1; // ECS units, not pixels!

  @override
  void onRemove() {
    disposeAll();
    super.onRemove();
  }

  @override
  Future<void> onLoad() {
    registry.eventBus.on<ecs.PreTickEvent>().forEach((e) {
      tree.tick();
    });

    return super.onLoad();
  }
}
