import 'dart:math';

import 'package:flame/effects.dart';
import '../../ai/ai.barrel.dart';
import '../../engine/engine.barrel.dart' as engine;
import '../../ui/components/components.barrel.dart';

var random = Random();

class Opponent extends Agent {
  final engine.World world;
  Effect? effect;
  late BehaviorTree tree;

  Opponent(this.world,
      {required super.registry,
      required super.entity,
      required super.svgAssetPath,
      super.position,
      super.size}) {
    tree = BehaviorTree(ActionNode((b) {
      entity.upsert<engine.MoveByIntent>(
          engine.MoveByIntent(dx: random.nextInt(3) - 1, dy: random.nextInt(3) - 1));
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
    registry.eventBus.on<engine.PreTickEvent>().forEach((e) {
      tree.tick();
    });

    return super.onLoad();
  }
}
