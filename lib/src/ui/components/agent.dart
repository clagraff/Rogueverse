import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import '../../ui/components/agent_health_bar.dart';
import '../../engine/engine.gen.dart';
import '../../ui/components/components.gen.dart';

class Agent extends SvgTileComponent with HasVisibility, Disposer {
  final Cell cell;
  final Entity2 entity;

  Agent({
    required this.cell,
    required this.entity,
    required super.svgAssetPath,
    super.position,
    super.size,
  });

  @override
  Future<void> onLoad() {
    EventBus().on<Dead>(entity.entityId).forEach((e) {
      print("shouldnt be visible222!!");
      isVisible = false;
    });

    EventBus().on<DidMove>(entity.entityId).forEach((e) {
      var didMove = e.value;

      add(MoveToEffect(Vector2(didMove.to.x * 32.0, didMove.to.y * 32.0),
          EffectController(duration: 0.1)));
    });

    EventBus().on<LocalPosition>(entity.entityId, [EventType.removed]).forEach((e) {
      removeFromParent();
    });

    EventBus().on<Renderable>(entity.entityId, [EventType.removed]).forEach((e) {
      removeFromParent();
    });

    EventBus().on<int>(entity.entityId, [EventType.removed]).forEach((e) {
      removeFromParent();
    });

    EventBus().on<Dead>(entity.entityId).first.then((e) {
      cell.remove(entity.entityId);
    });


    add(AgentHealthBar(entity2: entity, position: Vector2(0, -3), size: Vector2(size.x, 3)));

    return super.onLoad();
  }

  @override
  void onRemove() {
    disposeAll();
    super.onRemove();
  }
}
