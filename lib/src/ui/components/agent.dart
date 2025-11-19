import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import '../../engine/engine.barrel.dart' as engine;
import '../../ui/components/components.barrel.dart';

class Agent extends SvgTileComponent with HasVisibility, engine.Disposer {
  final engine.World registry;
  final engine.Entity entity;

  Agent({
    required this.registry,
    required this.entity,
    required super.svgAssetPath,
    super.position,
    super.size,
  });

  @override
  Future<void> onLoad() {
    registry.eventBus.on<engine.Dead>(entity.id).forEach((e) {
      // isVisible = false;
      // TODO figure out a better way to handle corpses.
      add(ColorEffect(const Color(0xFF00FF00),   EffectController(duration: 1.5),
        opacityFrom: 0.2,
        opacityTo: 0.8,));
    });

    registry.eventBus.on<engine.DidMove>(entity.id).forEach((e) {
      var didMove = e.value;

      add(MoveToEffect(Vector2(didMove.to.x * 32.0, didMove.to.y * 32.0),
          EffectController(duration: 0.1)));
    });

    registry.eventBus.on<engine.LocalPosition>(entity.id, [engine.EventType.removed]).forEach((e) {
      removeFromParent();
    });

    registry.eventBus.on<engine.Renderable>(entity.id, [engine.EventType.removed]).forEach((e) {
      removeFromParent();
    });

    registry.eventBus.on<int>(entity.id, [engine.EventType.removed]).forEach((e) {
      removeFromParent();
    });

    registry.eventBus.on<engine.Dead>(entity.id).first.then((e) {
      registry.remove(entity.id);
    });


    add(AgentHealthBar(entity: entity, position: Vector2(0, -3), size: Vector2(size.x, 3)));

    return super.onLoad();
  }

  @override
  void onRemove() {
    disposeAll();
    super.onRemove();
  }
}
