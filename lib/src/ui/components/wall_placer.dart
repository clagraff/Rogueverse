import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:rogueverse/src/engine/engine.gen.dart';

class WallPlacer extends PositionComponent with TapCallbacks, Disposer {
  final Cell cell;

  WallPlacer({required this.cell});

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
        .find(cell)
        .toList();

    if (matches.isNotEmpty) {
      for (var match in matches) {
        match.destroy();
      }
      return;
    }

    cell.add([
      Renderable('images/wall.svg'),
      escPosition,
      BlocksMovement(),
    ]);
  }
}
