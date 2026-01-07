import 'dart:math';

import 'package:flame/effects.dart';
import 'package:rogueverse/game/components/agent.dart';

var random = Random();

class Opponent extends Agent {
  Effect? effect;

  Opponent({required super.world,
      required super.entity,
      required super.assetPath,
      super.position,
      super.size});

  @override
  void onRemove() {
    disposeAll();
    super.onRemove();
  }
}
