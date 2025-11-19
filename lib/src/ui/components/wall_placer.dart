import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../../engine/engine.barrel.dart' as engine;

class WallPlacer extends PositionComponent with TapCallbacks, engine.Disposer {
  final engine.World registry;

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
    var escPosition = engine.LocalPosition(
        x: (screenPosition.x / 32.0).floor(),
        y: (screenPosition.y / 32.0).floor());

    var matches = engine.Query()
        .require<engine.LocalPosition>(
            (lp) => lp.x == escPosition.x && lp.y == escPosition.y)
        .require<engine.BlocksMovement>()
        .find(registry)
        .toList();

    if (matches.isNotEmpty) {
      for (var match in matches) {
        match.destroy();
      }
      return;
    }

    registry.add([
      engine.Renderable('images/wall.svg'),
      escPosition,
      engine.BlocksMovement(),
    ]);
  }
}
