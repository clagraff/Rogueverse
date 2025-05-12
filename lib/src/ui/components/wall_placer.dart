import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:rogueverse/src/engine/ecs.dart' as esc;

class WallPlacer extends PositionComponent with  TapCallbacks, esc.Disposer {
  final esc.Chunk chunk;

  WallPlacer({
    required this.chunk
  });


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
    var escPosition = esc.LocalPosition(
        x: (screenPosition.x / 32.0).floor(),
        y: (screenPosition.y / 32.0).floor());

    var matches = esc.Query()
      .require<esc.LocalPosition>((lp) => lp.x == escPosition.x && lp.y == escPosition.y)
      .require<esc.BlocksMovement>()
    .find(chunk).toList();

    if (matches.isNotEmpty) {
      for(var match in matches) {
        match.destroy();
      }
      return;
    }

    final wall = chunk.create();

    esc.Transaction(chunk, wall)
      ..set<esc.Renderable>(esc.Renderable('images/wall.svg'))
      ..set<esc.LocalPosition>(escPosition)
      ..set(esc.BlocksMovement())
      ..commit();
  }
}