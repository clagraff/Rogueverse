import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import 'package:flame/components.dart' as flame;
import 'package:flame/debug.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/ecs/ai/behaviors/behaviors.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/systems.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/main.dart';
import 'package:rogueverse/game/components/agent.dart';
import 'package:rogueverse/game/components/entity_tap_component.dart';
import 'package:rogueverse/game/components/focus_on_tap_component.dart';
import 'package:rogueverse/game/components/grid_tap.dart';
import 'package:rogueverse/game/components/opponent.dart';
import 'package:rogueverse/game/components/entity_hover_tracker.dart';
import 'package:rogueverse/game/components/player.dart';
import 'package:rogueverse/game/components/template_panel_toggle.dart';
import 'package:rogueverse/game/components/template_entity_spawner.dart';
import 'package:rogueverse/game/hud/health_bar.dart';

class GameScreen extends flame.World with Disposer {
  late FocusNode gameFocusNode;
  final Set<int> _renderedEntities = {};
  StreamSubscription<Change>? _spawnListener;

  GameScreen(FocusNode focusNode) {
    gameFocusNode = focusNode;
  }

  @override
  bool containsLocalPoint(flame.Vector2 point) => true;

  @override
  Future<void> onLoad() async {
    final game = parent!.findGame() as GameArea;

    // Attempt to load world-state from local save file.
    // TODO this can only work when running on Desktop, not web!
    var save = await WorldSaves.loadSave();
    if (save != null) {
      game.currentWorld = save;
    } else {
      _initializeEntities(game);
    }

    // Create template entity spawner (listens to template selection)
    add(TemplateEntitySpawner(
      world: game.currentWorld,
      templateNotifier: game.selectedTemplate,
    ));

    var gridNotifier = ValueNotifier<XY>(XY(0, 0));
    var entityNotifier = game.selectedEntity;
    add(FocusOnTapComponent(gameFocusNode, () {
      Logger("game_screen").info("taking focus");
      game.overlays.remove("inspectorPanel");
    }));

    add(GridTapComponent(32, gridNotifier));
    add(EntityTapComponent(32, entityNotifier, game.currentWorld));
    add(EntityTapVisualizerComponent(entityNotifier));
    add(GridTapVisualizerComponent(gridNotifier));

    add(FpsComponent());
    add(TimeTrackComponent());

    add(TemplatePanelToggle());
    add(EntityHoverTracker(
      world: game.currentWorld,
      titleNotifier: game.title,
    ));

    // Setup a listener for when Renderable or LocalPosition are being added
    // to an entity for the first time and _both_ are present on the entity,
    // so we can spawn a new Flame component for it.
    _spawnListener = game.currentWorld.componentChanges.listen((change) {
      if (change.kind != ChangeKind.added) return;
      // Only react to renderable/position changes; order doesn't matter.
      if (change.componentType == Renderable('').componentType ||
          change.componentType == LocalPosition(x: 0, y: 0).componentType) {
        Logger("game_screen").info("Entity(${change.entityId}) was given Renderable or LocalPosition");
        _spawnRenderableEntity(
          game,
          game.currentWorld.getEntity(change.entityId),
        );
      }
    });

    gridNotifier.addListener(() {
      var entities = game.currentWorld.get<LocalPosition>();
      entities.forEach((id, comp) {
        if (comp.x == gridNotifier.value.x && comp.y == gridNotifier.value.y) {
          var overlayName = "inspectorPanel";
          game.overlays.remove(overlayName);
          entityNotifier.value = game.currentWorld.getEntity(id);
          game.overlays.add(overlayName);
        }
      });
    });

    var playerId = game.currentWorld.get<PlayerControlled>().entries.first.key;

    var healthHud = HealthBar();
    // TODO change to component notification.
    // game.currentWorld.eventBus.on<Health>(playerId).forEach((e) {
    //   healthHud.onHealthChange(e.id);
    // });
    game.camera.viewport.add(healthHud);

    // TODO: handle EventBus() for new Renderables.
    game.currentWorld
        .entities()
        .where((e) => e.has<LocalPosition>() && e.has<Renderable>())
        .forEach((entity) {
      var pos = entity.get<LocalPosition>()!;
      if (entity.has<PlayerControlled>()) {
        _spawnRenderableEntity(game, game.currentWorld.getEntity(playerId));
        game.selectedEntity.value = entity;
        return;
      }
      if (entity.has<AiControlled>()) {
        _spawnRenderableEntity(game, game.currentWorld.getEntity(entity.id));
        return;
      }

      _spawnRenderableEntity(game, game.currentWorld.getEntity(entity.id));
    });
  }

  void _initializeEntities(GameArea game) {
    var reg = game.currentWorld;

    reg.add([
      Name(name: "Player"),
      Renderable('images/player.svg'),
      LocalPosition(x: 0, y: 0),
      PlayerControlled(),
      BlocksMovement(),
      Inventory([]),
      InventoryMaxCount(5),
      Health(4, 5),
    ]);
    reg.add([
      Name(name: "Snake"),
      Renderable('images/snake.svg'),
      LocalPosition(x: 1, y: 2),
      AiControlled(),
      BlocksMovement(),
      Behavior(MoveRandomlyNode())
    ]);
    reg.add([
      Name(name: "Wall"),
      Renderable('images/wall.svg'),
      LocalPosition(x: 1, y: 0),
      BlocksMovement(),
    ]);
    reg.add([
      Name(name: "Mineral"),
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

  @override
  void onRemove() {
    _spawnListener?.cancel();
    disposeAll();
  }

  void _spawnRenderableEntity(GameArea game, Entity entity) {
    if (_renderedEntities.contains(entity.id)) return;
    final renderable = entity.get<Renderable>();
    final lp = entity.get<LocalPosition>();
    if (renderable == null || lp == null) return;

    final position = flame.Vector2(lp.x * 32, lp.y * 32);
    flame.Component component;

    if (entity.has<PlayerControlled>()) {
      component = PlayerControlledAgent(
        world: game.currentWorld,
        entity: game.currentWorld.getEntity(entity.id),
        svgAssetPath: renderable.svgAssetPath,
        position: position,
      );
    } else if (entity.has<AiControlled>()) {
      component = Opponent(
        world: game.currentWorld,
        entity: game.currentWorld.getEntity(entity.id),
        svgAssetPath: renderable.svgAssetPath,
        position: position,
      );
    } else {
      component = Agent(
        world: game.currentWorld,
        entity: game.currentWorld.getEntity(entity.id),
        svgAssetPath: renderable.svgAssetPath,
        position: position,
      );
    }

    add(component);
    _renderedEntities.add(entity.id);
  }
}
