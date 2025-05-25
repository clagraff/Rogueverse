import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:rogueverse/src/engine/ecs.dart';
import 'package:rogueverse/src/engine/engine.gen.dart';
import '../../../src/ui/ui.gen.dart';

class HealthBar extends Component {
  final Paint paint;
  int health = 0;

  HealthBar([Paint? paint])
      : paint = paint ??
            (Paint()
              ..colorFilter = const ColorFilter.mode(
                Color(0xFFFF0000), // Red color
                BlendMode.srcIn,
              ));


  void onHealthChange(Entity2 e) {
    health = max(e.get<Health>()!.current, 0); // Dont allow anything below zero.
    children.clear();

    for(var i = 0.0; i < health; i++) {
      add(SvgTileComponent(
          svgAssetPath: "images/heart.svg",
          position: Vector2(5 + (35 * i), 5),
          size: Vector2(32, 32),
          paint: paint));
    }
  }
}
