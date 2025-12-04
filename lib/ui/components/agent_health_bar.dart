import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'dart:ui';

import 'package:rogueverse/ecs/entity.dart';

/// A component that displays and updates a health bar for game entities.
/// The health bar consists of a background bar, foreground bar showing current health,
/// and numerical health value display.
class AgentHealthBar extends PositionComponent with Disposer {
  final Entity entity;
  late RectangleComponent background;
  late RectangleComponent foreground;
  late TextComponent text;
  int lastUpdate = 0;

  /// Creates a health bar component for the specified entity.
  ///
  /// Parameters:
  /// - [entity]: The entity whose health this bar will display
  /// - [position]: Position offset for the health bar
  /// - [size]: Dimensions of the health bar
  AgentHealthBar({
    required this.entity,
    super.position,
    super.size,
  });

  /// Initializes the health bar components and sets up entity health listeners.
  /// Creates the background bar, foreground health bar, and health text display.
  @override
  FutureOr<void> onLoad() {
    entity.parentCell.eventBus.on<Health>(entity.id).forEach((e) {
      updateBar();
    });

    // Always spans the whole width.
    background = RectangleComponent(
      position: Vector2(0, -5),
      size: Vector2(size.x, 3),
      paint: Paint()..color = const Color(0xFF970000),
    );
    add(background);

    // Only spans based on relative health remaining.
    foreground = RectangleComponent(
      position: Vector2(0, -5),
      size: Vector2(size.x, 3),
      paint: Paint()..color = const Color(0xFFFF0000),
    );
    add(foreground);

    final regular = TextPaint(
      style: TextStyle(
        fontSize: 14.0,
        color: const Color(0xFFFF0000),
      ),
    );

    text = TextComponent(
        text: "", position: Vector2(size.x + 5, -15), textRenderer: regular);
    add(text);

    updateBar(); // Reset bar based on current Health comp.
    return super.onLoad();
  }

  /// Cleans up resources when the component is removed.
  /// Disposes of all registered disposables.
  @override
  void onRemove() {
    disposeAll();
    super.onRemove();
  }

  /// Updates the health bar's appearance based on the entity's current health.
  /// Animates the foreground bar size and updates the numerical health display.
  /// Hides the bars if the entity has no health component.
  void updateBar() {
    var health = entity.get<Health>();
    if (health != null) {
      // If we have a health component, set the background to full-size.
      background.size.x = size.x;

      // Calculate expected foreground size. If different, size-to using effect.
      var desiredX = size.x * (health.current / health.max);
      if (foreground.size.x != desiredX) {
        foreground.add(
            SizeEffect.to(
              Vector2(desiredX, foreground.size.y),
              EffectController(duration: 0.5),
            )
        );
      }

      // Update text to reflect actual health amount.
      text.text = health.current.toString();
    } else {
      // No health component? No bars then. Hide them both and hide the text.
      background.size.x = 0;
      foreground.size.x = 0;
      text.text = "";
    }
  }
}
