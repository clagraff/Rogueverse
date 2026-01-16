import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Debug component that renders a crosshair at where the camera thinks
/// the center of the viewport is. Useful for diagnosing camera/viewport
/// alignment issues.
class CameraCenterDebug extends PositionComponent with HasGameReference {
  static const double crosshairSize = 20.0;
  static const double lineWidth = 2.0;

  final Paint _paint = Paint()
    ..color = Colors.red
    ..strokeWidth = lineWidth
    ..style = PaintingStyle.stroke;

  final Paint _fillPaint = Paint()
    ..color = Colors.red.withValues(alpha: 0.3)
    ..style = PaintingStyle.fill;

  @override
  void render(Canvas canvas) {
    // Get the center of the visible world rect
    final visibleRect = game.camera.visibleWorldRect;
    final centerX = visibleRect.center.dx;
    final centerY = visibleRect.center.dy;

    // Draw crosshair
    canvas.drawLine(
      Offset(centerX - crosshairSize, centerY),
      Offset(centerX + crosshairSize, centerY),
      _paint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - crosshairSize),
      Offset(centerX, centerY + crosshairSize),
      _paint,
    );

    // Draw center circle
    canvas.drawCircle(Offset(centerX, centerY), 5, _fillPaint);
    canvas.drawCircle(Offset(centerX, centerY), 5, _paint);
  }
}
