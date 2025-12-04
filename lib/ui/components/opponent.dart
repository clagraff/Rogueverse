import 'dart:math';

import 'package:flame/effects.dart';
import 'package:rogueverse/ai/behavior_tree.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ui/components/agent.dart';

var random = Random();

class Opponent extends Agent {
  final World world;
  Effect? effect;
  late BehaviorTree tree;

  Opponent(this.world,
      {required super.registry,
      required super.entity,
      required super.svgAssetPath,
      super.position,
      super.size}) {
    tree = BehaviorTree(ActionNode((b) {
      entity.upsert<MoveByIntent>(
          MoveByIntent(dx: random.nextInt(3) - 1, dy: random.nextInt(3) - 1));
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
    registry.eventBus.on<PreTickEvent>().forEach((e) {
      tree.tick();
    });

    return super.onLoad();
  }
}
