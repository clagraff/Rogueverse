import 'dart:io';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import 'package:flame/components.dart' as flame;
import 'package:flame/debug.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rogueverse/ecs/ai/behaviors/behaviors.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/systems.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/main.dart';
import 'package:rogueverse/ui/components/agent.dart';
import 'package:rogueverse/ui/components/grid_tap.dart';
import 'package:rogueverse/ui/components/opponent.dart';
import 'package:rogueverse/ui/components/player.dart';
import 'package:rogueverse/ui/hud/health_bar.dart';

import '../ecs/ai/leaf_nodes.dart';
import '../ecs/ai/nodes.dart';

class GameWorld extends flame.World with Disposer {
  @override
  Future<void> onLoad() async {
    final game = parent!.findGame() as MyGame;

    var xy = ValueNotifier<XY>(XY(0, 0));
    add(GridTapComponent(32, xy));
    add(GridTapVisualizerComponent(xy));
    add(FpsComponent());
    add(TimeTrackComponent());

    var save = await WorldSaves.loadSave();

    if (save != null) {
      game.currentWorld = save;
    } else {
      var reg = game.currentWorld;

      reg.add([
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
        Behavior(MoveRandomlyNode())
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
        LootTable([
          Loot(components: [
            Renderable('images/item_small.svg'),
            Pickupable(),
            Name(name: 'Loot'),
          ])
        ]),
      ]);

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
          Renderable('images/item_small.svg'),
          LocalPosition(x: x, y: y),
          Pickupable(),
          Name(name: names[r.nextInt(names.length)]),
        ]);
      }
    }

    var playerId = game.currentWorld.get<PlayerControlled>().entries.first.key;

    var healthHud = HealthBar();
    game.currentWorld.eventBus.on<Health>(playerId).forEach((e) {
      healthHud.onHealthChange(e.id);
    });
    game.camera.viewport.add(healthHud);

    // TODO: handle EventBus() for new Renderables.
    game.currentWorld
        .entities()
        .where((e) => e.has<LocalPosition>() && e.has<Renderable>())
        .forEach((entity) {
      var pos = entity.get<LocalPosition>()!;
      if (entity.has<PlayerControlled>()) {
        add(PlayerControlledAgent(
          world: game.currentWorld,
          entity: game.currentWorld.getEntity(playerId),
          svgAssetPath: entity.get<Renderable>()!.svgAssetPath,
          position: flame.Vector2(pos.x * 32, pos.y * 32),
        ));

        game.selectedEntity.value = entity;
        return;
      }
      if (entity.has<AiControlled>()) {
        add(Opponent(
          world: game.currentWorld,
          entity: game.currentWorld.getEntity(entity.id),
          svgAssetPath: entity.get<Renderable>()!.svgAssetPath,
          position: flame.Vector2(pos.x * 32, pos.y * 32),
        ));
        return;
      }

      add(Agent(
        world: game.currentWorld,
        entity: game.currentWorld.getEntity(entity.id),
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
