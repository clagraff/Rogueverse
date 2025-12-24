import 'package:flame/components.dart' hide World;
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/components/agent_health_bar.dart';
import 'package:rogueverse/game/components/svg_component.dart';
import 'package:rogueverse/game/game_area.dart';

class Agent extends SvgTileComponent with HasVisibility, Disposer {
  final World world;
  final Entity entity;

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

    return super.onLoad();
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
    disposeAll();
    super.onRemove();
  }
}
