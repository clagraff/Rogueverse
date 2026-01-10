import 'dart:math';

import 'package:flame/components.dart';

/// Abstract base class for all visual rendering components.
/// Subclasses implement specific rendering types (SVG, PNG, animated, etc.)
/// Supports horizontal/vertical flipping and rotation.
abstract class VisualComponent extends PositionComponent with HasPaint {
  final bool flipHorizontal;
  final bool flipVertical;
  final double rotationDegrees;

  VisualComponent({
    super.position,
    super.size,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.rotationDegrees = 0,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Apply flip transformations using Flame's scale
    if (flipHorizontal) flipHorizontallyAroundCenter();
    if (flipVertical) flipVerticallyAroundCenter();
    // Apply rotation (convert degrees to radians)
    angle = rotationDegrees * (pi / 180);
  }
}
