import 'dart:io';
import 'dart:math';
import 'package:logging/logging.dart';

import 'package:flame/components.dart' as flame;
import 'package:flame/debug.dart';
import 'package:path_provider/path_provider.dart';
import '../../main.dart';
import '../ecs/ecs.barrel.dart' as ecs;
import '../ui/components/components.barrel.dart';
import '../ui/hud/health_bar.dart';

class GameWorld extends flame.World with ecs.Disposer {
  @override
  Future<void> onLoad() async {

    final game = parent!.findGame() as MyGame;

    add(FpsComponent());
    add(TimeTrackComponent());


    var save = await ecs.WorldSaves.loadSave();

    if (save != null) {
      game.registry = save;
    } else {
      var reg = game.registry;

      reg.add([
        ecs.Renderable('images/player.svg'),
        ecs.LocalPosition(x: 0, y: 0),
        ecs.PlayerControlled(),
        ecs.BlocksMovement(),
        ecs.Inventory([]),
        ecs.InventoryMaxCount(5),
        ecs.Health(4, 5),
      ]);
      reg.add([
        ecs.Renderable('images/snake.svg'),
        ecs.LocalPosition(x: 1, y: 2),
        ecs.AiControlled(),
        ecs.BlocksMovement(),
      ]);
      reg.add([
        ecs.Renderable('images/wall.svg'),
        ecs.LocalPosition(x: 1, y: 0),
        ecs.BlocksMovement(),
      ]);
      reg.add([
        ecs.Renderable('images/mineral.svg'),
        ecs.LocalPosition(x: 3, y: 2),
        ecs.Name(name: 'Iron'),
        ecs.BlocksMovement(),
        ecs.Health(2, 2),
        ecs.LootTable([
          ecs.Loot(components: [
            ecs.Renderable('images/item_small.svg'),
            ecs.Pickupable(),
            ecs.Name(name: 'Loot'),
          ])
        ]),
      ]);

      var c = ecs.CollisionSystem();
      var i = ecs.InventorySystem();
      List<ecs.System> s = List.from([c, i]);
      Map<String, ecs.System> m = {
        "Inventory": ecs.InventorySystem(),
        "Collision": ecs.CollisionSystem(),
      };


      var names = [
        'Iron short sword',
        'Recurve bow',
        'Copper helm',
        'Gold',
        'Gold',
        'Gold',
        'Leather gloves',
        'Health potion',
        'Stamina potion',
      ];

      var r = Random();
      var next = r.nextInt(5) + 5;
      for (var i = 0; i < next; i++) {
        var x = 0;
        var y = 0;

        while (x == 0 && y == 0) {
          x = r.nextInt(8) * (r.nextBool() ? 1 : -1);
          y = r.nextInt(8) * (r.nextBool() ? 1 : -1);
        }

        reg.add([
          ecs.Renderable('images/item_small.svg'),
          ecs.LocalPosition(x: x, y: y),
          ecs.Pickupable(),
          ecs.Name(name: names[r.nextInt(names.length)]),
        ]);
      }
    }

    var playerId = game.registry.get<ecs.PlayerControlled>().entries.first.key;


    var healthHud = HealthBar();
    game.registry.eventBus.on<ecs.Health>(playerId).forEach((e) {
      healthHud.onHealthChange(e.id);
    });
    game.camera.viewport.add(healthHud);


    // TODO: handle EventBus() for new Renderables.
    game.registry
        .entities()
        .where((e) => e.has<ecs.LocalPosition>() && e.has<ecs.Renderable>())
        .forEach((entity) {
      var pos = entity.get<ecs.LocalPosition>()!;
      if (entity.has<ecs.PlayerControlled>()) {
        add(PlayerControlledAgent(
          registry: game.registry,
          entity: game.registry.getEntity(playerId),
          svgAssetPath: entity.get<ecs.Renderable>()!.svgAssetPath,
          position: flame.Vector2(pos.x * 32, pos.y * 32),
        ));
        return;
      }
      if (entity.has<ecs.AiControlled>()) {
        add(Opponent(
          game.registry,
          registry: game.registry,
          entity: game.registry.getEntity(entity.id),
          svgAssetPath: entity.get<ecs.Renderable>()!.svgAssetPath,
          position: flame.Vector2(pos.x * 32, pos.y * 32),
        ));
        return;
      }

      add(Agent(
        registry: game.registry,
        entity: game.registry.getEntity(entity.id),
        svgAssetPath: entity.get<ecs.Renderable>()!.svgAssetPath,
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
