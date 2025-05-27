import 'dart:math';

import 'package:flame/components.dart' as flame;
import 'package:flame/debug.dart';
import '../../main.dart';
import '../engine/engine.barrel.dart';
import '../ui/components/components.barrel.dart';
import '../ui/hud/health_bar.dart';

class GameWorld extends flame.World with Disposer {
  @override
  Future<void> onLoad() async {
    final game = parent!.findGame() as MyGame;

    add(FpsComponent());
    add(TimeTrackComponent());

    var reg = game.registry;

    var player = reg.add([
      Renderable('images/player.svg'),
      LocalPosition(x: 0, y: 0),
      PlayerControlled(),
      BlocksMovement(),
      Inventory([]),
      InventoryMaxCount(5),
      Health(4, 5),
    ]);
    reg.add([
      Renderable('images/snake.svg'),
      LocalPosition(x: 1, y: 2),
      AiControlled(),
      BlocksMovement(),
    ]);
    reg.add([
      Renderable('images/wall.svg'),
      LocalPosition(x: 1, y: 0),
      BlocksMovement(),
    ]);
    reg.add([
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

      reg.add([
        Renderable('images/item_small.svg'),
        LocalPosition(x: x, y: y),
        Pickupable(),
        Name(name: 'Loot'),
      ]);
    }

    var healthHud = HealthBar();
    reg.eventBus.on<Health>(player.id).forEach((e) {
      healthHud.onHealthChange(e.id);
    });
    game.camera.viewport.add(healthHud);

    // TODO: handle EventBus() for new Renderables.
    reg
        .entities()
        .where((e) => e.has<LocalPosition>() && e.has<Renderable>())
        .forEach((entity) {
      var pos = entity.get<LocalPosition>()!;
      if (entity.has<PlayerControlled>()) {
        add(PlayerControlledAgent(
          registry: reg,
          entity: reg.getEntity(player.id),
          svgAssetPath: entity.get<Renderable>()!.svgAssetPath,
          position: flame.Vector2(pos.x * 32, pos.y * 32),
        ));
        return;
      }
      if (entity.has<AiControlled>()) {
        add(Opponent(
          game.registry,
          registry: reg,
          entity: reg.getEntity(entity.id),
          svgAssetPath: entity.get<Renderable>()!.svgAssetPath,
          position: flame.Vector2(pos.x * 32, pos.y * 32),
        ));
        return;
      }

      add(Agent(
        registry: reg,
        entity: reg.getEntity(entity.id),
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
