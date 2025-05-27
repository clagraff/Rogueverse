import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import '../../engine/engine.barrel.dart';
import '../../ui/components/components.barrel.dart';

class Agent extends SvgTileComponent with HasVisibility, Disposer {
  final Registry registry;
  final Entity entity;

  Agent({
    required this.registry,
    required this.entity,
    required super.svgAssetPath,
    super.position,
    super.size,
  });

  @override
  Future<void> onLoad() {
    EventBus().on<Dead>(entity.id).forEach((e) {
      isVisible = false;
    });

    EventBus().on<DidMove>(entity.id).forEach((e) {
      var didMove = e.value;

      add(MoveToEffect(Vector2(didMove.to.x * 32.0, didMove.to.y * 32.0),
          EffectController(duration: 0.1)));
    });

    EventBus().on<LocalPosition>(entity.id, [EventType.removed]).forEach((e) {
      removeFromParent();
    });

    EventBus().on<Renderable>(entity.id, [EventType.removed]).forEach((e) {
      removeFromParent();
    });

    EventBus().on<int>(entity.id, [EventType.removed]).forEach((e) {
      removeFromParent();
    });

    EventBus().on<Dead>(entity.id).first.then((e) {
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
