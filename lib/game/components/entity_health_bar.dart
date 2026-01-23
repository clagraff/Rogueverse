import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:rogueverse/app/services/game_settings_service.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'dart:ui';

import 'package:rogueverse/ecs/entity.dart';

/// A component that displays and updates a health bar for game entities.
/// The health bar consists of a background bar, foreground bar showing current health,
/// and numerical health value display.
class EntityHealthBar extends PositionComponent with HasVisibility, Disposer {
  final Entity entity;
  late RectangleComponent background;
  late RectangleComponent foreground;
  late TextComponent text;
  int lastUpdate = 0;

  /// Tracks whether the entity is currently in the player's field of view.
  /// Health bars should ONLY be visible when the entity is in FOV.
  bool _entityInFOV = false;

  /// Creates a health bar component for the specified entity.
  ///
  /// Parameters:
  /// - [entity]: The entity whose health this bar will display
  /// - [position]: Position offset for the health bar
  /// - [size]: Dimensions of the health bar
  EntityHealthBar({
    required this.entity,
    super.position,
    super.size,
  }) {
    // Start hidden - visibility controlled by FOV and health state
    isVisible = false;
  }

  /// Called by EntitySprite when entity's FOV visibility changes.
  /// Health bars should only be visible when entity is in FOV.
  void setEntityInFOV(bool inFOV) {
    _entityInFOV = inFOV;
    _updateVisibility();
  }

  @override
  FutureOr<void> onLoad() {
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xff550000),
    );
    add(background);

    foreground = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xff00ff00),
    );
    add(foreground);

    text = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 8.0,
          color: Color(0xffffffff),
          shadows: [
            Shadow(color: Color(0xff000000), offset: Offset(1, 1), blurRadius: 1),
          ],
        ),
      ),
      position: Vector2(size.x / 2, 0),
      anchor: Anchor.topCenter,
    );
    add(text);

    // Listen for settings changes
    GameSettingsService.instance.changeNotifier.addListener(_onSettingsChanged);

    // Set initial visibility based on whether entity has health
    updateBar();

    return super.onLoad();
  }

  @override
  void onRemove() {
    GameSettingsService.instance.changeNotifier.removeListener(_onSettingsChanged);
    super.onRemove();
  }

  void _onSettingsChanged() {
    // Re-evaluate visibility when settings change
    _updateVisibility();
  }

  void _updateVisibility() {
    // Never show health bar if entity is not in FOV
    if (!_entityInFOV) {
      isVisible = false;
      return;
    }

    var health = entity.get<Health>();
    if (health == null) {
      isVisible = false;
      return;
    }

    // Within FOV, show health bar based on settings and health state
    final alwaysShow = GameSettingsService.instance.alwaysShowHealthBars;
    isVisible = alwaysShow || health.current < health.max;
  }

  /// Updates the health bar to reflect current health values.
  /// Animates the bar width change if health has changed since last update.
  void updateBar() {
    var health = entity.get<Health>();
    if (health == null) {
      isVisible = false;
      return;
    }

    // Update visibility based on FOV and health state
    _updateVisibility();

    // Early return if health value unchanged (skip animation/text update)
    if (health.current == lastUpdate) return;

    var fraction = health.current / health.max;

    // Remove any previous animation
    foreground.children.whereType<SizeEffect>().forEach((e) => e.removeFromParent());

    // Animate to new size
    foreground.add(SizeEffect.to(
      Vector2(size.x * fraction, size.y),
      EffectController(duration: 0.3),
    ));

    text.text = "${health.current}/${health.max}";
    lastUpdate = health.current;
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateBar();
  }
}
