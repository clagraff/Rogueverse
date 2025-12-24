import 'dart:math';

import 'package:flame/components.dart' hide Component;
import 'package:flutter/material.dart';

import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/game/game_area.dart';

/// Debug overlay that visualizes an entity's field of view.
/// Shows visible tiles as a yellow tinted overlay.
class VisionConeOverlay extends PositionComponent {
  final Entity entity;

  VisionConeOverlay(this.entity);

  @override
  void render(Canvas canvas) {
    // Only show vision cone if this entity is an active observer
    final gameArea = findParent<GameArea>();
    if (gameArea == null) return;
    
    final isActiveObserver = gameArea.visionCamera.activeObservers.value.contains(entity.id);
    if (!isActiveObserver) return;

    final visibleTiles = entity.get<VisibleEntities>()?.visibleTiles;
    if (visibleTiles == null || visibleTiles.isEmpty) return;

    // Get entity's grid position for relative rendering
    final entityPos = entity.get<LocalPosition>();
    if (entityPos == null) return;

    final fillPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Render tiles RELATIVE to entity position (since this is a child of Agent)
    for (final tile in visibleTiles) {
      // Calculate offset from entity
      final relativeX = (tile.x - entityPos.x) * 32.0;
      final relativeY = (tile.y - entityPos.y) * 32.0;
      
      final rect = Rect.fromLTWH(relativeX, relativeY, 32.0, 32.0);

      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, borderPaint);
    }

    // Optional: Draw FOV cone direction indicator
    final visionRadius = entity.get<VisionRadius>();
    final direction = entity.get<Direction>();

    if (visionRadius != null &&
        direction != null &&
        visionRadius.fieldOfViewDegrees < 360) {
      _drawDirectionIndicator(canvas, direction, visionRadius);
    }
  }

  /// Draw a small arrow indicating the direction of vision (at entity center)
  void _drawDirectionIndicator(Canvas canvas, Direction direction, VisionRadius visionRadius) {
    // Center of entity (relative to parent) is at (16, 16) - center of 32x32 tile
    final centerX = 16.0;
    final centerY = 16.0;

    final angle = _directionToAngle(direction.facing) * (pi / 180.0);
    final arrowLength = 20.0;

    final arrowPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw main arrow line
    final endX = centerX + arrowLength * cos(angle);
    final endY = centerY + arrowLength * sin(angle);
    canvas.drawLine(Offset(centerX, centerY), Offset(endX, endY), arrowPaint);

    // Draw arrowhead
    final headLength = 6.0;
    final headAngle = 25.0 * (pi / 180.0);

    final leftX = endX - headLength * cos(angle - headAngle);
    final leftY = endY - headLength * sin(angle - headAngle);
    final rightX = endX - headLength * cos(angle + headAngle);
    final rightY = endY - headLength * sin(angle + headAngle);

    canvas.drawLine(Offset(endX, endY), Offset(leftX, leftY), arrowPaint);
    canvas.drawLine(Offset(endX, endY), Offset(rightX, rightY), arrowPaint);
  }

  int _directionToAngle(CompassDirection dir) {
    switch (dir) {
      case CompassDirection.east:
        return 0;
      case CompassDirection.northeast:
        return 45;
      case CompassDirection.north:
        return 90;
      case CompassDirection.northwest:
        return 135;
      case CompassDirection.west:
        return 180;
      case CompassDirection.southwest:
        return 225;
      case CompassDirection.south:
        return 270;
      case CompassDirection.southeast:
        return 315;
    }
  }
}
