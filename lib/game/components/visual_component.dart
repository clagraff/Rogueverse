import 'package:flame/components.dart';

/// Abstract base class for all visual rendering components.
/// Subclasses implement specific rendering types (SVG, PNG, animated, etc.)
abstract class VisualComponent extends PositionComponent with HasPaint {
  VisualComponent({Vector2? position, Vector2? size}) {
    this.position = position ?? Vector2.zero();
    this.size = size ?? Vector2.all(32);
  }
}
