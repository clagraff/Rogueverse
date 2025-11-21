import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import '../../../src/ecs/ecs.barrel.dart' as ecs;
import '../../../src/ui/ui.barrel.dart';

class HealthBar extends Component {
  final Paint paint;
  int health = 0;

  HealthBar([Paint? paint])
      : paint = paint ??
            (Paint()
              ..colorFilter = const ColorFilter.mode(
                Color(0xFFFF9C2B), // Red color
                BlendMode.srcIn,
              ));


  void onHealthChange(ecs.Entity e) {
    health = max(e.get<ecs.Health>()!.current, 0); // Dont allow anything below zero.
    removeAll(children);

    for(var i = 0.0; i < health; i++) {
      var comp = SvgTileComponent(
          svgAssetPath: "images/heart.svg",
          position: Vector2(5 + (35 * i), 5),
          size: Vector2(32, 32));
      comp.paint = paint;
      add(comp);
    }
  }
}
