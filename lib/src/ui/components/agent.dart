import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:rogueverse/src/engine/ecs.dart' as esc;


class Agent extends SvgTileComponent with esc.Disposer {
  final esc.Chunk chunk;
  final esc.Entity entity;

  Agent({
    required this.chunk,
    required this.entity,
    required super.svgAssetPath,
    super.position,
    super.size,
  });

  @override
  Future<void> onLoad() {
    entity.onSet<esc.DidMove>(updatePosition).asDisposable().disposeLater(this);
    entity
        .onDelete((id) {
          removeFromParent();
        })
        .asDisposable()
        .disposeLater(this);
    return super.onLoad();
  }

  @override
  void onRemove() {
    disposeAll();
    super.onRemove();
  }

  void updatePosition(entityId, comp) {
    add(MoveToEffect(Vector2(comp.to.x * 32.0, comp.to.y * 32.0),
        EffectController(duration: 0.1)));
  }
}
