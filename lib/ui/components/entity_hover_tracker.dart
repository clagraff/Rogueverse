import 'package:flame/components.dart' hide World;
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/ecs/world.dart';

/// A Flame component that tracks mouse hover over entities and updates a title notifier.
///
/// When the mouse hovers over an entity with a Name component, the notifier is updated
/// with that entity's name. When not hovering over any named entity, it shows blank.
class EntityHoverTracker extends PositionComponent with HoverCallbacks {
  final World world;
  final ValueNotifier<String> titleNotifier;
  final double tileSize;
  final String defaultTitle;

  EntityHoverTracker({
    required this.world,
    required this.titleNotifier,
    this.tileSize = 32.0,
    this.defaultTitle = '',
  });

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onHoverUpdate(PointerHoverInfo info) {
    final gridPos = _toGridPosition(info.eventPosition.widget);
    _updateHoveredEntity(gridPos);
  }

  @override
  void onHoverExit() {
    // Reset to default when mouse leaves the game area
    titleNotifier.value = defaultTitle;
  }

  /// Updates the title based on what entity is at the given grid position.
  void _updateHoveredEntity(LocalPosition gridPos) {
    // Find all entities at this position with a Name component
    final entities = Query()
        .require<LocalPosition>((lp) => lp.x == gridPos.x && lp.y == gridPos.y)
        .require<Name>()
        .find(world)
        .toList();

    if (entities.isNotEmpty) {
      // If multiple entities at same position, show the first one with a name
      final name = entities.first.get<Name>();
      if (name != null) {
        titleNotifier.value = name.name;
      } else {
        titleNotifier.value = defaultTitle;
      }
    } else {
      titleNotifier.value = defaultTitle;
    }
  }

  /// Converts screen position to grid coordinates.
  LocalPosition _toGridPosition(Vector2 screenPosition) {
    return LocalPosition(
      x: (screenPosition.x / tileSize).floor(),
      y: (screenPosition.y / tileSize).floor(),
    );
  }
}
