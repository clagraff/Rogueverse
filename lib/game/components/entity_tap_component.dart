import 'package:flame/components.dart' hide World;
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/game/components/svg_visual_component.dart'
    show SvgVisualComponent;
import 'package:rogueverse/game/utils/grid_coordinates.dart'
    show GridCoordinates;

/// Handles tap events on the game grid to select entities at tapped positions.
class EntityTapComponent extends PositionComponent with TapCallbacks {
  final ValueNotifier<Entity?> notifier;
  final ValueNotifier<int?>? observerEntityIdNotifier;
  final ValueNotifier<int?> viewedParentNotifier;
  final double gridSize;
  final World world;

  final Logger _logger = Logger("EntityTapComponent");

  /// Creates a tap handler for entity selection.
  ///
  /// [gridSize] is the size of each grid cell in pixels.
  /// [notifier] updates with the selected entity or null.
  /// [world] provides access to entity data.
  /// [observerEntityIdNotifier] updates with the selected entity's ID for vision tracking.
  EntityTapComponent(this.gridSize, this.notifier, this.world,
      {this.observerEntityIdNotifier, required this.viewedParentNotifier});

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
    final gridPos = GridCoordinates.screenToGrid(screenPosition);
    var x = gridPos.x;
    var y = gridPos.y;

    var matched = false;
    var query = Query().require<LocalPosition>((lp) => lp.x == x && lp.y == y);
    if (viewedParentNotifier.value != null) {
      query = query.require<HasParent>((hp) => hp.parentEntityId == viewedParentNotifier.value);
    } else {
      query = query.exclude<HasParent>();
    }

    var tappedEntity = query.find(world).firstOrNull;
    if (tappedEntity != null) {
      _logger.info("entity tapped", {"entity": tappedEntity});
      notifier.value = tappedEntity;
      _logger.info("setting observed entity", {"entity": tappedEntity});
      observerEntityIdNotifier?.value = tappedEntity.id;
      matched = true;
    }

    if (!matched && notifier.value != null) {
      _logger.info("entity untapped", {"entityId": notifier.value!.id});
      notifier.value = null;
      // Clear observer entity ID when deselecting
      _logger.info("clearing observed entity");
      observerEntityIdNotifier?.value = null;
    }
  }
}

/// Displays a visual border around the currently selected entity.
class EntityTapVisualizerComponent extends SvgVisualComponent with HasVisibility {
  final ValueNotifier<Entity?> notifier;

  /// Creates a visualizer that tracks entity selection changes.
  ///
  /// [notifier] provides the currently selected entity. Instead of adding a
  /// listener, we check the value each frame. This is so if the entity itself
  /// moves, we need this component to match its movements.
  EntityTapVisualizerComponent(this.notifier)
      : super(
            svgAssetPath: 'images/border.svg',
            size: Vector2(32, 32),
            position: Vector2(0, 0)) {
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

    position = GridCoordinates.gridToScreen(lp);
    isVisible = true;

    super.update(dt);
  }
}
