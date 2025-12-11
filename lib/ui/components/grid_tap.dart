import 'package:flame/components.dart' hide World;
import 'package:flame/effects.dart' show OpacityEffect, EffectController;
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ui/components/svg_component.dart' show SvgTileComponent;

class XY {
  final int x;
  final int y;

  XY(this.x, this.y);
}

class GridTapComponent extends PositionComponent with TapCallbacks {
  final ValueNotifier<XY> notifier;
  final double gridSize;

  GridTapComponent(this.gridSize, this.notifier);

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onTapUp(TapUpEvent event) {
    var screenPosition = event.localPosition;
    var x = (screenPosition.x / gridSize).floor();
    var y = (screenPosition.y / gridSize).floor();

    notifier.value = XY(x, y);
  }
}

class GridTapVisualizerComponent extends SvgTileComponent with HasVisibility {
  final ValueNotifier<XY> notifier;

  GridTapVisualizerComponent(this.notifier) : super(svgAssetPath: 'images/crosshair.svg', size: Vector2(32, 32), position: Vector2(0, 0)) {
    notifier.addListener(onListen);
    isVisible = false;
  }

  @override
  void onRemove() {
    notifier.removeListener(onListen);
    super.onRemove();
  }

  void onListen() {
    // Reset so crosshair is visible
    isVisible = true;
    opacity = 1;

    var xy = notifier.value;
    position = Vector2(xy.x * 32, xy.y * 32);

    // Remove any previous opacity effects so they don't stack
    children.whereType<OpacityEffect>().forEach((e) => e.removeFromParent());

    // Add a fresh, one-shot fade-out
    add(
      OpacityEffect.to(
        0,
        EffectController(duration: 0.75),
        // Depending on your Flame version, this may be `onComplete` or `onMax`.
        onComplete: () {
          // When the fade ends, hide the crosshair
          //isVisible = false;
        },
      ),
    );
  }
}