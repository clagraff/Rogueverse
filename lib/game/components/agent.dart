import 'dart:async';

import 'package:flame/components.dart' hide World;
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/events.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/components/agent_health_bar.dart';
import 'package:rogueverse/game/components/visual_component.dart';
import 'package:rogueverse/game/components/svg_visual_component.dart';
import 'package:rogueverse/game/components/png_visual_component.dart';
import 'package:rogueverse/game/components/text_visual_component.dart';
import 'package:rogueverse/game/game_area.dart';

class Agent extends PositionComponent with HasVisibility, Disposer {
  final World world;
  final Entity entity;
  RenderableAsset _currentAsset;
  AgentHealthBar? healthBar;
  VisualComponent? _visual;

  // Vision-based rendering state
  StreamSubscription<Change>? _visionSubscription;
  StreamSubscription<Change>? _renderableSubscription;
  VoidCallback? _observerChangeListener;
  VoidCallback? _gameModeChangeListener;
  int? _currentObserverId;
  Vector2? _lastSeenPosition;

  Agent({
    required this.world,
    required this.entity,
    required RenderableAsset asset,
    Vector2? position,
    Vector2? size,
  }) : _currentAsset = asset {
    this.position = position ?? Vector2.zero();
    this.size = size ?? Vector2.all(32);
  }

  @override
  Future<void> onLoad() async {
    // Create the appropriate visual component based on asset type
    _visual = _createVisualComponent(_currentAsset, size);
    await add(_visual!);

    healthBar = AgentHealthBar(
        entity: entity, position: Vector2(0, -3), size: Vector2(size.x, 3));
    add(healthBar!);

    // Set up vision-based rendering
    _setupVisionTracking();

    // Set up renderable change tracking (for doors, etc.)
    _setupRenderableTracking();

    return super.onLoad();
  }

  /// Creates the appropriate visual component based on asset type.
  VisualComponent _createVisualComponent(RenderableAsset asset, Vector2? size) {
    final tileCenter = (size ?? this.size) / 2; // Center of the tile
    return switch (asset) {
      ImageAsset img => _createImageVisual(img, size),
      TextAsset txt => TextVisualComponent(
        text: txt.text,
        fontSize: txt.fontSize,
        color: Color(txt.color),
        position: tileCenter, // Center text in the tile
      ),
    };
  }

  /// Creates an image-based visual component (SVG or PNG).
  VisualComponent _createImageVisual(ImageAsset img, Vector2? size) {
    final assetPath = img.svgAssetPath;

    if (assetPath.endsWith('.svg')) {
      return SvgVisualComponent(
        svgAssetPath: assetPath,
        size: size,
        flipHorizontal: img.flipHorizontal,
        flipVertical: img.flipVertical,
        rotationDegrees: img.rotationDegrees,
      );
    } else if (assetPath.endsWith('.png')) {
      return PngVisualComponent(
        pngAssetPath: assetPath,
        size: size,
        flipHorizontal: img.flipHorizontal,
        flipVertical: img.flipVertical,
        rotationDegrees: img.rotationDegrees,
      );
    } else {
      // Default to SVG for backwards compatibility
      return SvgVisualComponent(
        svgAssetPath: assetPath,
        size: size,
        flipHorizontal: img.flipHorizontal,
        flipVertical: img.flipVertical,
        rotationDegrees: img.rotationDegrees,
      );
    }
  }

  /// Sets up tracking of Renderable changes to swap visuals (e.g., when doors open/close).
  void _setupRenderableTracking() {
    _renderableSubscription = world.componentChanges
        .onEntityOnComponent<Renderable>(entity.id)
        .listen((change) {
      if (change.kind == ChangeKind.removed) return;

      final renderable = entity.get<Renderable>();
      if (renderable == null) return;

      final newAsset = renderable.asset;
      if (!_assetsEqual(newAsset, _currentAsset)) {
        _swapVisual(newAsset);
      }
    });
  }

  /// Compares two RenderableAssets for equality.
  bool _assetsEqual(RenderableAsset a, RenderableAsset b) {
    if (a.runtimeType != b.runtimeType) return false;

    return switch ((a, b)) {
      (ImageAsset imgA, ImageAsset imgB) =>
        imgA.svgAssetPath == imgB.svgAssetPath &&
        imgA.flipHorizontal == imgB.flipHorizontal &&
        imgA.flipVertical == imgB.flipVertical &&
        imgA.rotationDegrees == imgB.rotationDegrees,
      (TextAsset txtA, TextAsset txtB) =>
        txtA.text == txtB.text &&
        txtA.fontSize == txtB.fontSize &&
        txtA.color == txtB.color,
      _ => false,
    };
  }

  /// Swaps the current visual component for a new one with the given asset.
  Future<void> _swapVisual(RenderableAsset newAsset) async {
    _currentAsset = newAsset;

    // Store current opacity before removing
    final currentOpacity = _visual?.opacity ?? 1.0;

    // Remove old visual
    _visual?.removeFromParent();

    // Create and add new visual
    _visual = _createVisualComponent(newAsset, size);
    _visual!.opacity = currentOpacity;
    await add(_visual!);
  }

  /// Sets up tracking of the observer entity to determine visibility and opacity.
  void _setupVisionTracking() {
    final game = parent?.findGame() as GameArea?;
    if (game == null) return;

    // Listen for observer changes
    _observerChangeListener = () {
      final newObserverId = game.observerEntityId.value;
      if (newObserverId != _currentObserverId) {
        _currentObserverId = newObserverId;
        _attachToObserver(newObserverId);
      }
    };

    game.observerEntityId.addListener(_observerChangeListener!);

    // Listen for game mode changes to update visibility
    _gameModeChangeListener = () {
      if (game.gameMode.value == GameMode.editing) {
        // In editing mode, all entities are fully visible
        _visual?.opacity = 1.0;
        healthBar?.isVisible = true;
      } else if (_currentObserverId != null) {
        // Re-apply vision filtering when switching back to gameplay
        _updateVisibility(_currentObserverId!);
      }
    };

    game.gameMode.addListener(_gameModeChangeListener!);

    // Initial setup
    if (game.observerEntityId.value != null) {
      _currentObserverId = game.observerEntityId.value;
      _attachToObserver(_currentObserverId);
    }
  }

  /// Attaches to a new observer entity's VisibleEntities component.
  void _attachToObserver(int? observerId) {
    // Cancel previous subscription
    _visionSubscription?.cancel();
    _visionSubscription = null;

    if (observerId == null) {
      // Default to visible if no observer
      _visual?.opacity = 1.0;
      healthBar?.isVisible = true;
      return;
    }

    // Check if observer has VisionRadius - if not, show all entities
    final observer = world.getEntity(observerId);
    if (!observer.has<VisionRadius>()) {
      // Show all entities if observer has no vision system
      _visual?.opacity = 1.0;
      healthBar?.isVisible = true;
      return;
    }

    // Subscribe to the observer's VisibleEntities changes
    _visionSubscription = world.componentChanges
        .onEntityOnComponent<VisibleEntities>(observerId)
        .listen((_) => _updateVisibility(observerId));

    // Initial visibility update
    _updateVisibility(observerId);
  }

  /// Updates this agent's opacity based on visibility from the observer's perspective.
  void _updateVisibility(int observerId) {
    // In editing mode, all entities are fully visible
    final game = parent?.findGame() as GameArea?;
    if (game != null && game.gameMode.value == GameMode.editing) {
      _visual?.opacity = 1.0;
      healthBar?.isVisible = true;
      return;
    }

    final observer = world.getEntity(observerId);
    final visibleEntities = observer.get<VisibleEntities>();
    final visionMemory = observer.get<VisionMemory>();

    double targetOpacity;

    // The observer itself is always fully visible
    if (entity.id == observerId) {
      targetOpacity = 1.0;
      healthBar?.isVisible = true;
    }
    // Check if currently visible
    else if (visibleEntities?.entityIds.contains(entity.id) ?? false) {
      targetOpacity = 1.0;
      healthBar?.isVisible = true;
      // Update last-seen position
      final localPos = entity.get<LocalPosition>();
      if (localPos != null) {
        _lastSeenPosition = Vector2(localPos.x * 32.0, localPos.y * 32.0);
      }
    }
    // Check if in vision memory (seen before but not currently visible)
    else if (visionMemory?.hasSeenEntity(entity.id) ?? false) {
      targetOpacity = 0.3; // Very transparent for remembered entities
      healthBar?.isVisible = false;
    }
    // Not visible and never seen
    else {
      targetOpacity = 0.0; // Invisible
      healthBar?.isVisible = false;
    }

    // Apply opacity to visual component with animation
    if (_visual != null) {
      final currentOpacity = _visual!.opacity;

      // Only animate if opacity is changing significantly
      if ((currentOpacity - targetOpacity).abs() > 0.01) {
        // Remove existing opacity effects to prevent stacking
        _visual!.children
            .whereType<OpacityEffect>()
            .forEach((e) => e.removeFromParent());

        // Animate to target opacity (100ms to match movement animation)
        _visual!.add(OpacityEffect.to(
          targetOpacity,
          EffectController(duration: 0.100),
        ));
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Only update position if the entity is currently visible
    // Entities in memory should remain frozen at their last-seen position
    if (_shouldUpdatePosition()) {
      var localPos = entity.get<LocalPosition>();
      if (localPos != null) {
        var dx = localPos.x * 32.0;
        var dy = localPos.y * 32.0;

        if (position != Vector2(dx, dy) &&
            !children.any((c) => c is MoveToEffect)) {
          add(MoveToEffect(Vector2(localPos.x * 32.0, localPos.y * 32.0),
              EffectController(duration: 0.100)));
        }
      }
    } else if (_lastSeenPosition != null && position != _lastSeenPosition) {
      // Freeze at last-seen position for memory-only entities
      position = _lastSeenPosition!;
    }

    if (!entity.has<Renderable>()) {
      removeFromParent();
    }

    if (entity.has<Dead>()) {
      world.remove(entity.id);
      removeFromParent();
    }
  }

  /// Returns true if this entity's position should be updated from ECS.
  /// Only entities that are currently visible should have their positions updated.
  bool _shouldUpdatePosition() {
    final game = parent?.findGame() as GameArea?;
    if (game == null) return true; // Default to updating if no game context

    // In editing mode, always update positions
    if (game.gameMode.value == GameMode.editing) return true;

    final observerId = game.observerEntityId.value;
    if (observerId == null) return true; // Default to updating if no observer

    // The observer itself always updates
    if (entity.id == observerId) return true;

    // Check if currently visible
    final observer = world.getEntity(observerId);
    final visibleEntities = observer.get<VisibleEntities>();

    return visibleEntities?.entityIds.contains(entity.id) ?? true;
  }

  @override
  void onRemove() {
    // Clean up subscriptions
    _visionSubscription?.cancel();
    _renderableSubscription?.cancel();
    final game = parent?.findGame() as GameArea?;
    if (game != null) {
      if (_observerChangeListener != null) {
        game.observerEntityId.removeListener(_observerChangeListener!);
      }
      if (_gameModeChangeListener != null) {
        game.gameMode.removeListener(_gameModeChangeListener!);
      }
    }

    disposeAll();
    super.onRemove();
  }
}
