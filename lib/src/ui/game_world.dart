import 'dart:math';

import 'package:flame/components.dart' as flame;
import 'package:flame/debug.dart';
import 'package:rogueverse/main.dart';
import 'package:rogueverse/src/engine/engine.gen.dart';
import 'package:rogueverse/src/ui/components/components.gen.dart';
import 'package:rogueverse/src/ui/hud/health_bar.dart';

class GameWorld extends flame.World with Disposer {
  @override
  Future<void> onLoad() async {
    final game = parent!.findGame() as MyGame;

    add(FpsComponent());
    add(TimeTrackComponent());

    var activeCell = Cell();

    var player = activeCell.add([
      Renderable('images/player.svg'),
      LocalPosition(x: 0, y: 0),
      PlayerControlled(),
      BlocksMovement(),
      Inventory([]),
      InventoryMaxCount(5),
      Health(4, 5),
    ]);
    var snake = activeCell.add([
      Renderable('images/snake.svg'),
      LocalPosition(x: 1, y: 2),
      AiControlled(),
      BlocksMovement(),
    ]);
    var wall = activeCell.add([
      Renderable('images/wall.svg'),
      LocalPosition(x: 1, y: 0),
      BlocksMovement(),
    ]);
    activeCell.add([
      Renderable('images/mineral.svg'),
      LocalPosition(x: 3, y: 2),
      Name(name: 'Iron'),
      BlocksMovement(),
      Health(2, 2),
    ]);



    var r = Random();
    var next = r.nextInt(5) + 3;
    for (var i = 0; i < next; i++) {
      var x = 0;
      var y = 0;

      while (x == 0 && y == 0) {
        x = r.nextInt(18) * (r.nextBool() ? 1 : -1);
        y = r.nextInt(10) * (r.nextBool() ? 1 : -1);
      }

      activeCell.add([
        Renderable('images/item_small.svg'),
        LocalPosition(x: x, y: y),
        Pickupable(),
        Name(name: 'Loot'),
      ]);
    }

    game.ecsWorld.cells.add(activeCell);

    var healthHud = HealthBar();
    EventBus().on<Health>(player).forEach((e) {
      healthHud.onHealthChange(e.id);
    });
    game.camera.viewport.add(healthHud);

    // TODO: handle EventBus() for new Renderables.
    activeCell
        .entities()
        .where((e) => e.has<LocalPosition>() && e.has<Renderable>())
        .forEach((entity) {
      var pos = entity.get<LocalPosition>()!;
      if (entity.has<PlayerControlled>()) {
        add(PlayerControlledAgent(
          cell: activeCell,
          entity: activeCell.getEntity(player),
          svgAssetPath: entity.get<Renderable>()!.svgAssetPath,
          position: flame.Vector2(pos.x * 32, pos.y * 32),
        ));
        return;
      }
      if (entity.has<AiControlled>()) {
        add(Opponent(
          game.ecsWorld,
          cell: activeCell,
          entity: activeCell.getEntity(entity.entityId),
          svgAssetPath: entity.get<Renderable>()!.svgAssetPath,
          position: flame.Vector2(pos.x * 32, pos.y * 32),
        ));
        return;
      }

      add(Agent(
        cell: activeCell,
        entity: activeCell.getEntity(entity.entityId),
        svgAssetPath: entity.get<Renderable>()!.svgAssetPath,
        position: flame.Vector2(pos.x * 32, pos.y * 32),
      ));
    });


    //add(WallPlacer(chunk: chunk));
  }

  @override
  void onRemove() {
    disposeAll();
  }
}
