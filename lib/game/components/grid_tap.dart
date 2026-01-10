import 'package:flame/components.dart' hide World;
import 'package:flame/effects.dart' show OpacityEffect, EffectController;
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/game/components/svg_visual_component.dart'
    show SvgVisualComponent;
import 'package:rogueverse/game/utils/grid_coordinates.dart'
    show GridCoordinates;

class XY {
  final int x;
  final int y;

  XY(this.x, this.y);

  @override
  String toString() {
    return "XY(x: $x, y: $y)";
  }
}

class GridTapComponent extends PositionComponent with TapCallbacks {
  final ValueNotifier<XY> notifier;
  final double gridSize;

  GridTapComponent(this.gridSize, this.notifier);

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onTapDown(TapDownEvent event) {
    event.continuePropagation = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    event.continuePropagation = true;
    var screenPosition = event.localPosition;
    final gridPos = GridCoordinates.screenToGrid(screenPosition);
    notifier.value = XY(gridPos.x, gridPos.y);
  }
}

class GridTapVisualizerComponent extends SvgVisualComponent with HasVisibility {
  final ValueNotifier<XY> notifier;

  GridTapVisualizerComponent(this.notifier)
      : super(
            svgAssetPath: 'images/crosshair.svg',
            size: Vector2.all(GridCoordinates.tileSize),
            position: Vector2(0, 0)) {
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
    position = GridCoordinates.gridToScreen(LocalPosition(x: xy.x, y: xy.y));

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
