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


/// Handles tap events on the game grid to select entities at tapped positions.
class EntityTapComponent extends PositionComponent with TapCallbacks {
  final ValueNotifier<Entity?> notifier;
  final double gridSize;
  final World world;

  /// Creates a tap handler for entity selection.
  ///
  /// [gridSize] is the size of each grid cell in pixels.
  /// [notifier] updates with the selected entity or null.
  /// [world] provides access to entity data.
  EntityTapComponent(this.gridSize, this.notifier, this.world);

  /// Intercepts all tap events by covering the entire component area.
  @override
  bool containsLocalPoint(Vector2 point) => true;

  /// Allows tap events to propagate to other components.
  @override
  void onTapDown(TapDownEvent event) {
    event.continuePropagation = true;
  }

  /// Converts tap position to grid coordinates and selects the entity at that location.
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

/// Displays a visual border around the currently selected entity.
class EntityTapVisualizerComponent extends SvgTileComponent with HasVisibility {
  final ValueNotifier<Entity?> notifier;

  /// Creates a visualizer that tracks entity selection changes.
  ///
  /// [notifier] provides the currently selected entity. Instead of adding a
  /// listener, we check the value each frame. This is so if the entity itself
  /// moves, we need this component to match its movements.
  EntityTapVisualizerComponent(this.notifier) : super(svgAssetPath: 'images/border.svg', size: Vector2(32, 32), position: Vector2(0, 0)) {
    isVisible = false;
  }

  /// Updates the border position to match the selected entity's location.
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
}