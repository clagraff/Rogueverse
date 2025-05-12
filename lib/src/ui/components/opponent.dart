import 'dart:math';

import 'package:flame/effects.dart';
import 'package:rogueverse/src/ai/behavior_tree.dart';
import 'package:rogueverse/src/engine/ecs.dart';
import 'package:rogueverse/src/ui/components/agent.dart';

var random = Random();

class Opponent extends Agent {
  Effect? effect;
  late BehaviorTree tree;

  Opponent({
    required super.chunk,
    required super.entity,
    required super.svgAssetPath,
    super.position,
    super.size
  }) {
    tree = BehaviorTree(ActionNode((b) {
      entity.set<MoveByIntent>(
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
    chunk.onBeforeTick((c) {
      tree.tick();
    }).asDisposable().disposeLater(this as Disposer);
    return super.onLoad();
  }
}
