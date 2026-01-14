import 'package:flame/components.dart' hide World;
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/game/components/svg_visual_component.dart'
    show SvgVisualComponent;
import 'package:rogueverse/game/utils/grid_coordinates.dart'
    show GridCoordinates;

/// Handles tap events on the game grid to select entities at tapped positions.
///
/// Single tap: Select the entity at that position
class EntityTapComponent extends PositionComponent with TapCallbacks {
  final ValueNotifier<Set<Entity>> notifier;
  final ValueNotifier<int?>? observerEntityIdNotifier;
  final ValueNotifier<int?> viewedParentNotifier;
  final double gridSize;
  final World world;

  /// Whether this handler is enabled. Disabled in gameplay mode, enabled in editing mode.
  bool isEnabled = false;

  final Logger _logger = Logger("EntityTapComponent");

  /// Creates a tap handler for entity selection.
  ///
  /// [gridSize] is the size of each grid cell in pixels.
  /// [notifier] updates with the selected entity or null.
  /// [world] provides access to entity data.
  /// [observerEntityIdNotifier] updates with the selected entity's ID for vision tracking.
  /// [viewedParentNotifier] is read to determine which parent's children to query.
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
    if (!isEnabled) return;

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
      notifier.value = {tappedEntity};
      _logger.info("setting observed entity", {"entity": tappedEntity});
      observerEntityIdNotifier?.value = tappedEntity.id;
      matched = true;
      // Properties panel is already visible in editing mode via dock panels
    }

    if (!matched && notifier.value.isNotEmpty) {
      _logger.info("entity untapped");
      notifier.value = {};
      // Clear observer entity ID when deselecting
      _logger.info("clearing observed entity");
      observerEntityIdNotifier?.value = null;
    }
  }

}

/// Displays visual borders around all currently selected entities.
class EntityTapVisualizerComponent extends PositionComponent {
  final ValueNotifier<Set<Entity>> notifier;
  final List<SvgVisualComponent> _borders = [];

  /// Creates a visualizer that tracks entity selection changes.
  ///
  /// [notifier] provides the currently selected entities. Instead of adding a
  /// listener, we check the value each frame. This is so if an entity
  /// moves, we need the borders to match their movements.
  EntityTapVisualizerComponent(this.notifier);

  /// Updates border positions to match the selected entities' locations.
  @override
  void update(double dt) {
    final entities = notifier.value.toList();

    // Remove excess borders
    while (_borders.length > entities.length) {
      final border = _borders.removeLast();
      border.removeFromParent();
    }

    // Add borders if needed
    while (_borders.length < entities.length) {
      final border = SvgVisualComponent(
        svgAssetPath: 'images/border.svg',
        size: Vector2(32, 32),
        position: Vector2(0, 0),
      );
      _borders.add(border);
      add(border);
    }

    // Update positions (entities without LocalPosition get positioned offscreen)
    for (var i = 0; i < entities.length; i++) {
      final entity = entities[i];
      final border = _borders[i];
      final lp = entity.get<LocalPosition>();

      if (lp != null) {
        border.position = GridCoordinates.gridToScreen(lp);
      } else {
        // Move offscreen if no position
        border.position = Vector2(-1000, -1000);
      }
    }

    super.update(dt);
  }
}
