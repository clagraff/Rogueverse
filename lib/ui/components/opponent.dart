import 'dart:math';

import 'package:flame/effects.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ui/components/agent.dart';

var random = Random();

class Opponent extends Agent {
  final World world;
  Effect? effect;

  Opponent(this.world,
      {required super.registry,
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
