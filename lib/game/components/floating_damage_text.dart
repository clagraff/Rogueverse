import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flutter/animation.dart';
import 'dart:ui';

/// A floating text component that displays damage numbers.
///
/// Spawned when an entity takes damage, floats upward and fades out.
/// Automatically removes itself after the animation completes.
///
/// Note: TextComponent doesn't support OpacityEffect, so we manually
/// animate the text color's alpha value in update().
class FloatingDamageText extends TextComponent {
  /// Duration of the float animation in seconds.
  static const double floatDuration = 0.8;

  /// Distance the text floats upward in pixels.
  static const double floatDistance = 24.0;

  final Color _baseColor;
  final double _fontSize;
  double _elapsed = 0;

  FloatingDamageText({
    required int damage,
    required Vector2 position,
    Color color = const Color(0xFFFF4444),
    double fontSize = 24.0,
  })  : _baseColor = color,
        _fontSize = fontSize,
        super(
          text: '-$damage',
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: FontWeight.bold,
              shadows: const [
                // Multiple shadows for a stronger outline effect
                Shadow(color: Color(0xFF000000), offset: Offset(-1, -1), blurRadius: 1),
                Shadow(color: Color(0xFF000000), offset: Offset(1, -1), blurRadius: 1),
                Shadow(color: Color(0xFF000000), offset: Offset(-1, 1), blurRadius: 1),
                Shadow(color: Color(0xFF000000), offset: Offset(1, 1), blurRadius: 1),
                Shadow(color: Color(0xFF000000), offset: Offset(0, 0), blurRadius: 3),
              ],
            ),
          ),
        );

  @override
  FutureOr<void> onLoad() {
    // Float upward effect
    add(
      MoveByEffect(
        Vector2(0, -floatDistance),
        EffectController(
          duration: floatDuration,
          curve: Curves.easeOutQuad,
        ),
      ),
    );

    // Remove after animation completes
    add(
      RemoveEffect(
        delay: floatDuration,
      ),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;

    // Calculate fade progress (0 to 1)
    final progress = (_elapsed / floatDuration).clamp(0.0, 1.0);

    // Apply easeIn curve for fade
    final fadeProgress = Curves.easeIn.transform(progress);

    // Calculate new alpha (fade from full to 0)
    final alpha = (1.0 - fadeProgress).clamp(0.0, 1.0);

    // Update text renderer with new alpha
    final shadowAlpha = (alpha * 255).toInt();
    textRenderer = TextPaint(
      style: TextStyle(
        fontSize: _fontSize,
        color: _baseColor.withValues(alpha: alpha),
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Color.fromARGB(shadowAlpha, 0, 0, 0), offset: const Offset(-1, -1), blurRadius: 1),
          Shadow(color: Color.fromARGB(shadowAlpha, 0, 0, 0), offset: const Offset(1, -1), blurRadius: 1),
          Shadow(color: Color.fromARGB(shadowAlpha, 0, 0, 0), offset: const Offset(-1, 1), blurRadius: 1),
          Shadow(color: Color.fromARGB(shadowAlpha, 0, 0, 0), offset: const Offset(1, 1), blurRadius: 1),
          Shadow(color: Color.fromARGB(shadowAlpha, 0, 0, 0), offset: const Offset(0, 0), blurRadius: 3),
        ],
      ),
    );
  }
}

/// A floating text component for pickup notifications.
///
/// Similar to FloatingDamageText but with different styling for pickups.
class FloatingPickupText extends TextComponent {
  /// Duration of the float animation in seconds.
  static const double floatDuration = 1.0;

  /// Distance the text floats upward in pixels.
  static const double floatDistance = 20.0;

  final Color _baseColor;
  final double _fontSize;
  double _elapsed = 0;

  FloatingPickupText({
    required String itemName,
    required Vector2 position,
    Color color = const Color(0xFF44FF44),
    double fontSize = 14.0,
  })  : _baseColor = color,
        _fontSize = fontSize,
        super(
          text: '+$itemName',
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: FontWeight.w500,
              shadows: const [
                Shadow(
                  color: Color(0xFF000000),
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        );

  @override
  FutureOr<void> onLoad() {
    // Float upward effect
    add(
      MoveByEffect(
        Vector2(0, -floatDistance),
        EffectController(
          duration: floatDuration,
          curve: Curves.easeOutQuad,
        ),
      ),
    );

    // Remove after animation completes
    add(
      RemoveEffect(
        delay: floatDuration,
      ),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;

    // Delayed fade: start fading at 40% of duration
    final fadeStart = floatDuration * 0.4;
    final fadeDuration = floatDuration * 0.6;

    double alpha = 1.0;
    if (_elapsed > fadeStart) {
      final fadeElapsed = _elapsed - fadeStart;
      final fadeProgress = (fadeElapsed / fadeDuration).clamp(0.0, 1.0);
      final curvedProgress = Curves.easeIn.transform(fadeProgress);
      alpha = (1.0 - curvedProgress).clamp(0.0, 1.0);
    }

    // Update text renderer with new alpha
    textRenderer = TextPaint(
      style: TextStyle(
        fontSize: _fontSize,
        color: _baseColor.withValues(alpha: alpha),
        fontWeight: FontWeight.w500,
        shadows: [
          Shadow(
            color: Color.fromARGB((alpha * 255).toInt(), 0, 0, 0),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }
}
