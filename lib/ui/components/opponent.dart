import 'dart:math';

import 'package:flame/effects.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ui/components/agent.dart';

var random = Random();

class Opponent extends Agent {
  Effect? effect;

  Opponent({required super.world,
      required super.entity,
      required super.svgAssetPath,
      super.position,
      super.size});

  @override
  void onRemove() {
    disposeAll();
    super.onRemove();
  }
}
