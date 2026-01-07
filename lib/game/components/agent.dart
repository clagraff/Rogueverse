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
import 'package:rogueverse/game/game_area.dart';

class Agent extends PositionComponent with HasVisibility, Disposer {
  final World world;
  final Entity entity;
  final String assetPath;
  AgentHealthBar? healthBar;
  VisualComponent? _visual;

  // Vision-based rendering state
  StreamSubscription<Change>? _visionSubscription;
  VoidCallback? _observerChangeListener;
  int? _currentObserverId;
  Vector2? _lastSeenPosition;

  Agent({
    required this.world,
    required this.entity,
    required this.assetPath,
    Vector2? position,
    Vector2? size,
  }) {
    this.position = position ?? Vector2.zero();
    this.size = size ?? Vector2.all(32);
  }

  @override
  Future<void> onLoad() async {
    // Create the appropriate visual component based on file extension
    _visual = _createVisualComponent(assetPath, size);
    await add(_visual!);

    // TODO convert this to something that can run in `update(dt)`
    // world.eventBus.on<Dead>(entity.id).forEach((e) {
    //   // isVisible = false;
    //   // TODO figure out a better way to handle corpses.
    //   add(ColorEffect(const Color(0xFF00FF00),   EffectController(duration: 1.5),
    //     opacityFrom: 0.2,
    //     opacityTo: 0.8,));
    // });

    // world.eventBus.on<DidMove>(entity.id).forEach((e) {
    //   var didMove = e.value;
    //
    //   add(MoveToEffect(Vector2(didMove.to.x * 32.0, didMove.to.y * 32.0),
    //       EffectController(duration: 0.1)));
    // });

    // world.eventBus.on<LocalPosition>(entity.id, [EventType.removed]).forEach((e) {
    //   removeFromParent();
    // });

    // world.eventBus.on<Renderable>(entity.id, [EventType.removed]).forEach((e) {
    //   removeFromParent();
    // });

    // world.eventBus.on<int>(entity.id, [EventType.removed]).forEach((e) {
    //   removeFromParent();
    // });

    // world.eventBus.on<Dead>(entity.id).first.then((e) {
    //   world.remove(entity.id);
    // });

    healthBar = AgentHealthBar(
        entity: entity, position: Vector2(0, -3), size: Vector2(size.x, 3));
    add(healthBar!);


    // Set up vision-based rendering
    _setupVisionTracking();

    return super.onLoad();
  }

  /// Creates the appropriate visual component based on file extension.
  VisualComponent _createVisualComponent(String assetPath, Vector2? size) {
    if (assetPath.endsWith('.svg')) {
      return SvgVisualComponent(svgAssetPath: assetPath, size: size);
    } else if (assetPath.endsWith('.png')) {
      return PngVisualComponent(pngAssetPath: assetPath, size: size);
    } else {
      // Default to SVG for backwards compatibility
      return SvgVisualComponent(svgAssetPath: assetPath, size: size);
    }
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

    // Apply opacity to visual component
    if (_visual != null) {
      _visual!.opacity = targetOpacity;
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
              EffectController(duration: 0.1)));
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
    // Clean up vision tracking subscriptions
    _visionSubscription?.cancel();
    final game = parent?.findGame() as GameArea?;
    if (game != null && _observerChangeListener != null) {
      game.observerEntityId.removeListener(_observerChangeListener!);
    }

    disposeAll();
    super.onRemove();
  }
}
