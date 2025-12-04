import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:rogueverse/ecs/components.dart' as components;
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ui/components/svg_component.dart';

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


  void onHealthChange(Entity e) {
    health = max(e.get<components.Health>()!.current, 0); // Dont allow anything below zero.
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
