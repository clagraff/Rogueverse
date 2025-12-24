import 'package:flame/components.dart' hide World;
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/components/agent_health_bar.dart';
import 'package:rogueverse/game/components/svg_component.dart';
import 'package:rogueverse/game/components/vision_cone_overlay.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/game/vision_camera.dart';

class Agent extends SvgTileComponent with HasVisibility, Disposer {
  final World world;
  final Entity entity;
  
  VoidCallback? _visionListener;

  Agent({
    required this.world,
    required this.entity,
    required super.svgAssetPath,
    super.position,
    super.size,
  });

  @override
  Future<void> onLoad() async {
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

    add(AgentHealthBar(entity: entity, position: Vector2(0, -3), size: Vector2(size.x, 3)));

    // Set up vision camera listener
    final gameArea = findParent<GameArea>();
    if (gameArea != null) {
      _visionListener = () {
        _updateVisibilityFromCamera(gameArea.visionCamera);
      };
      
      gameArea.visionCamera.visibleEntities.addListener(_visionListener!);
      gameArea.visionCamera.rememberedEntities.addListener(_visionListener!);
      
      // Initial visibility update
      _updateVisibilityFromCamera(gameArea.visionCamera);
    }

    return super.onLoad();
  }
  
  void _updateVisibilityFromCamera(VisionCamera camera) {
    if (camera.mode == VisionMode.showAll) {
      // Show everything mode - all entities visible
      isVisible = true;
      paint.colorFilter = null;
      return;
    }
    
    final entityId = entity.id;
    
    if (camera.visibleEntities.value.contains(entityId)) {
      // Currently visible
      isVisible = true;
      paint.colorFilter = null;
    } else if (camera.rememberedEntities.value.contains(entityId)) {
      // Previously seen but not currently visible
      isVisible = true;
      paint.colorFilter = ColorFilter.mode(
        Colors.grey.withOpacity(0.6),
        BlendMode.modulate,
      );
    } else {
      // Never seen
      isVisible = false;
    }
  }


  @override void update(double dt) {
    super.update(dt);

    var localPos = entity.get<LocalPosition>();
    if (localPos != null) {
      var dx = localPos.x * 32.0;
      var dy = localPos.y * 32.0;

      if (position != Vector2(dx, dy) && !children.any((c) => c is MoveToEffect)) {
        add(MoveToEffect(Vector2(localPos.x * 32.0, localPos.y * 32.0),
            EffectController(duration: 0.1)));
      }
    }

    // Auto-attach vision cone overlay when entity gains VisionRadius
    if (entity.has<VisionRadius>() && !children.any((c) => c is VisionConeOverlay)) {
      add(VisionConeOverlay(entity));
    }

    // Remove vision cone overlay when entity loses VisionRadius
    if (!entity.has<VisionRadius>() && children.any((c) => c is VisionConeOverlay)) {
      children.whereType<VisionConeOverlay>().first.removeFromParent();
    }

    if (!entity.has<Renderable>()) {
      removeFromParent();
    }

    if (entity.has<Dead>()) {
      world.remove(entity.id);
      removeFromParent();
    }
  }

  @override
  void onRemove() {
    // Clean up vision listener
    if (_visionListener != null) {
      final gameArea = findParent<GameArea>();
      if (gameArea != null) {
        gameArea.visionCamera.visibleEntities.removeListener(_visionListener!);
        gameArea.visionCamera.rememberedEntities.removeListener(_visionListener!);
      }
    }
    
    disposeAll();
    super.onRemove();
  }
}
