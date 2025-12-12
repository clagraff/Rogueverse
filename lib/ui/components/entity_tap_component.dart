import 'package:flame/components.dart' hide World;
import 'package:flame/effects.dart' show OpacityEffect, EffectController;
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ui/components/svg_component.dart' show SvgTileComponent;


class EntityTapComponent extends PositionComponent with TapCallbacks {
  final ValueNotifier<Entity?> notifier;
  final double gridSize;
  final World world;

  EntityTapComponent(this.gridSize, this.notifier, this.world);

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
    var x = (screenPosition.x / gridSize).floor();
    var y = (screenPosition.y / gridSize).floor();

    var matched = false;
    world.get<LocalPosition>().forEach((entityId, localPos) {
      if (x == localPos.x && y == localPos.y) {
        Logger("EntityTap").info("Tapped $entityId");
        notifier.value = world.getEntity(entityId);
        matched = true;
      }
    });

    if (!matched && notifier.value != null) {
      Logger("EntityTap").info("untapped ${notifier.value!.id}");
      notifier.value = null;
    }
  }
}

class EntityTapVisualizerComponent extends SvgTileComponent with HasVisibility {
  final ValueNotifier<Entity?> notifier;

  EntityTapVisualizerComponent(this.notifier) : super(svgAssetPath: 'images/border.svg', size: Vector2(32, 32), position: Vector2(0, 0)) {
    notifier.addListener(onListen);
    isVisible = false;
  }

  @override
  Future<void> onLoad() async {
    isVisible = false;
    super.onLoad();
  }

  @override
  void onRemove() {
    notifier.removeListener(onListen);
    super.onRemove();
  }

  @override
  void update(double dt) {
    var entity = notifier.value;
    if (entity == null) {
      isVisible = false;
      return;
    }

    var lp = entity.get<LocalPosition>();
    if (lp == null) {
      isVisible = false;
      return;
    }

    position = Vector2(lp.x * 32, lp.y * 32);
    isVisible = true;

    super.update(dt);
  }

  void onListen() {
    // Reset so crosshair is visible
    isVisible = true;

    var entity = notifier.value;
    if (entity == null) {
      isVisible = false;
      return;
    }

    var lp = entity.get<LocalPosition>();
    if (lp == null) {
      isVisible = false;
      return;
    }

    position = Vector2(lp.x * 32, lp.y * 32);
    isVisible = true;
  }


}