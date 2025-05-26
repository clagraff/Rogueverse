import 'dart:math';

import 'package:flame/effects.dart';
import 'package:rogueverse/src/ai/ai.gen.dart';
import 'package:rogueverse/src/engine/engine.gen.dart';
import 'package:rogueverse/src/ui/components/components.gen.dart';

var random = Random();

class Opponent extends Agent {
  final Registry world;
  Effect? effect;
  late BehaviorTree tree;

  Opponent(this.world,
      {required super.cell,
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
    EventBus().on<PreTickEvent>().forEach((e) {
      tree.tick();
    });

    return super.onLoad();
  }
}
