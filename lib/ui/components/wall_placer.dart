import 'package:flame/components.dart' hide World;
import 'package:flame/events.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/ecs/world.dart';

class WallPlacer extends PositionComponent with TapCallbacks, Disposer {
  final World registry;

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
    var escPosition = LocalPosition(
        x: (screenPosition.x / 32.0).floor(),
        y: (screenPosition.y / 32.0).floor());

    var matches = Query()
        .require<LocalPosition>(
            (lp) => lp.x == escPosition.x && lp.y == escPosition.y)
        .require<BlocksMovement>()
        .find(registry)
        .toList();

    if (matches.isNotEmpty) {
      for (var match in matches) {
        match.destroy();
      }
      return;
    }

    registry.add([
      Renderable('images/wall.svg'),
      escPosition,
      BlocksMovement(),
    ]);
  }
}
