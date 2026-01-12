import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// A single vision cone tile that can fade in/out using Flame effects.
class VisionTile extends RectangleComponent {
  static const double _animationDuration = 0.100;
  static const Color _baseColor = Color(0xFFFFFF00);

  VisionTile()
      : super(
          size: Vector2.all(32),
          paint: Paint()..color = _baseColor.withValues(alpha: 0),
        );

  double _targetAlpha = 0.0;

  /// Configure tile position and target alpha, then fade in.
  void show({required Vector2 gridPosition, required double targetAlpha}) {
    position = gridPosition;
    _targetAlpha = targetAlpha;
    opacity = 0;

    // Remove any existing effects
    children.whereType<OpacityEffect>().forEach((e) => e.removeFromParent());

    // Fade in to target alpha
    add(OpacityEffect.to(
      _targetAlpha,
      EffectController(duration: _animationDuration),
    ));
  }

  /// Update target alpha (e.g., observer moved, distance changed).
  void updateTargetAlpha(double newTargetAlpha) {
    if ((_targetAlpha - newTargetAlpha).abs() > 0.01) {
      _targetAlpha = newTargetAlpha;
      children.whereType<OpacityEffect>().forEach((e) => e.removeFromParent());
      add(OpacityEffect.to(
        _targetAlpha,
        EffectController(duration: _animationDuration),
      ));
    }
  }

  /// Fade out, then call onComplete when done.
  void hide({required VoidCallback onComplete}) {
    children.whereType<OpacityEffect>().forEach((e) => e.removeFromParent());
    add(OpacityEffect.to(
      0,
      EffectController(duration: _animationDuration),
      onComplete: onComplete,
    ));
  }
}
