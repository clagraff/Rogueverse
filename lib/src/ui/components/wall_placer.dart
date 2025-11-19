import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../../ecs/ecs.barrel.dart' as ecs;

class WallPlacer extends PositionComponent with TapCallbacks, ecs.Disposer {
  final ecs.World registry;

  WallPlacer({required this.registry});

  @override
  void onRemove() {
    disposeAll();
    super.onRemove();
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onTapUp(TapUpEvent event) {
    var screenPosition = event.localPosition;
    var escPosition = ecs.LocalPosition(
        x: (screenPosition.x / 32.0).floor(),
        y: (screenPosition.y / 32.0).floor());

    var matches = ecs.Query()
        .require<ecs.LocalPosition>(
            (lp) => lp.x == escPosition.x && lp.y == escPosition.y)
        .require<ecs.BlocksMovement>()
        .find(registry)
        .toList();

    if (matches.isNotEmpty) {
      for (var match in matches) {
        match.destroy();
      }
      return;
    }

    registry.add([
      ecs.Renderable('images/wall.svg'),
      escPosition,
      ecs.BlocksMovement(),
    ]);
  }
}
