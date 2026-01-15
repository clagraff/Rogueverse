import 'dart:ui';

import 'package:flame/components.dart' hide World;
import 'package:flutter/foundation.dart';

import 'package:rogueverse/ecs/components.dart' hide Component;
import 'package:rogueverse/ecs/entity.dart';

/// A visual highlight circle that appears over the currently targeted entity
/// during interaction menu navigation.
///
/// Displays an unfilled white circle over the entity's grid position to help
/// players identify which entity will be affected by the selected interaction.
class InteractionHighlight extends PositionComponent {
  /// The notifier to listen to for highlighted entity changes.
  final ValueNotifier<Entity?> highlightedEntityNotifier;

  /// Size of each grid tile in pixels.
  final double tileSize;

  /// The circle component used for rendering.
  CircleComponent? _circle;

  /// The currently highlighted entity (for change detection).
  Entity? _currentEntity;

  InteractionHighlight({
    required this.highlightedEntityNotifier,
    this.tileSize = 32.0,
  }) {
    // High priority so it renders above other components
    priority = 1000;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Listen to highlight changes
    highlightedEntityNotifier.addListener(_onHighlightChanged);

    // Initialize if there's already a highlighted entity
    _onHighlightChanged();
  }

  @override
  void onRemove() {
    highlightedEntityNotifier.removeListener(_onHighlightChanged);
    super.onRemove();
  }

  void _onHighlightChanged() {
    final entity = highlightedEntityNotifier.value;

    // Skip if same entity
    if (entity == _currentEntity) return;
    _currentEntity = entity;

    // Remove existing circle
    _circle?.removeFromParent();
    _circle = null;

    if (entity == null) return;

    // Get entity position
    final pos = entity.get<LocalPosition>();
    if (pos == null) return;

    // Create circle at entity position
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    _circle = CircleComponent(
      radius: tileSize / 2 - 2,
      position: Vector2(
        pos.x * tileSize + tileSize / 2,
        pos.y * tileSize + tileSize / 2,
      ),
      anchor: Anchor.center,
      paint: paint,
    );

    add(_circle!);
  }
}
