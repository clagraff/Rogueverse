import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import 'package:flame/components.dart' as flame;
import 'package:flame/debug.dart';

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/events.dart';
import 'package:rogueverse/ecs/systems.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/components/agent.dart';
import 'package:rogueverse/game/components/entity_drag_mover.dart';
import 'package:rogueverse/game/components/entity_hover_tracker.dart';
import 'package:rogueverse/game/components/entity_tap_component.dart';
import 'package:rogueverse/game/components/focus_on_tap_component.dart';
import 'package:rogueverse/game/components/global_control_handler.dart';
import 'package:rogueverse/game/components/grid_tap.dart';
import 'package:rogueverse/game/components/inventory_control_handler.dart';
import 'package:rogueverse/game/components/opponent.dart';
import 'package:rogueverse/game/components/positional_control_handler.dart';
import 'package:rogueverse/game/components/template_entity_spawner.dart';
import 'package:rogueverse/game/components/overlay_toggle.dart';
import 'package:rogueverse/game/components/vision_cone.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/game/hud/health_bar.dart';

class GameScreen extends flame.World with Disposer {
  late FocusNode gameFocusNode;
  final Set<int> _renderedEntities = {};
  final Logger _logger = Logger("GameScreen");

  StreamSubscription<Change>? _spawnListener;
  StreamSubscription<int?>? _viewedParentListener;

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
      //_initializeControlExample(game);
      game.currentWorld = save;
    } else {
      //_initializeControlExample(game);
    }

    // Create template entity spawner (listens to template selection)
    add(TemplateEntitySpawner(
      world: game.currentWorld,
      templateNotifier: game.selectedTemplate,
      viewedParentNotifier: game.viewedParentId,
    ));

    // Create entity drag mover (allows dragging entities when no template selected)
    add(EntityDragMover(
      world: game.currentWorld,
      templateNotifier: game.selectedTemplate,
      game: game,
      viewedParentNotifier: game.viewedParentId,
    ));

    var gridNotifier = ValueNotifier<XY>(XY(0, 0));
    add(FocusOnTapComponent(gameFocusNode, () {
      Logger("game_screen").info("taking focus");
      game.overlays.remove("editorPanel");
    }));

    add(GridTapComponent(32, gridNotifier));
    add(EntityTapComponent(32, game.selectedEntity, game.currentWorld,
        observerEntityIdNotifier: game.observerEntityId, viewedParentNotifier: game.viewedParentId));
    add(EntityTapVisualizerComponent(game.selectedEntity));
    add(GridTapVisualizerComponent(gridNotifier));

    add(FpsComponent());
    add(TimeTrackComponent());

    // Add overlay toggles for keyboard shortcuts
    add(OverlayToggle(
      overlayName: 'templatePanel',
      action: 'overlay.templates',
      gameFocusNode: gameFocusNode,
    ));
    add(OverlayToggle(
      overlayName: 'editorPanel',
      action: 'overlay.editor',
      gameFocusNode: gameFocusNode,
    ));
    add(EntityHoverTracker(
      world: game.currentWorld,
      titleNotifier: game.title,
      viewedParentNotifier: game.viewedParentId,
    ));

    // Add debug overlay
    // add(DebugInfoOverlay(
    //   selectedEntityNotifier: game.selectedEntity,
    //   observerEntityIdNotifier: game.observerEntityId,
    //   game: game,
    // ));

    // Add control handlers
    add(PositionalControlHandler(
      selectedEntityNotifier: game.selectedEntity,
      world: game.currentWorld,
    ));
    add(InventoryControlHandler(
      selectedEntityNotifier: game.selectedEntity,
      world: game.currentWorld,
    ));
    add(GlobalControlHandler(selectedEntityNotifier: game.selectedEntity));

    // Setup a listener for when Renderable or LocalPosition are being added
    // to an entity for the first time and _both_ are present on the entity,
    // so we can spawn a new Flame component for it.
    _spawnListener = game.currentWorld.componentChanges.listen((change) {
      if (change.kind != ChangeKind.added) return;
      // Only react to renderable/position changes; order doesn't matter.

      // TODO: need to tweak this so we only spawn renderable entities if they belong to the same
      // parent we are currently watching.
      if (change.componentType == Renderable('').componentType ||
          change.componentType == LocalPosition(x: 0, y: 0).componentType) {
        Logger("game_screen").info(
            "Entity(${change.entityId}) was given Renderable or LocalPosition");
        _spawnRenderableEntity(
          game,
          game.currentWorld.getEntity(change.entityId),
        );
      }
    });

    // Listen for HasParent changes on selected entity to auto-follow through portals
    game.currentWorld.componentChanges.listen((change) {
      if (change.kind == ChangeKind.updated &&
          change.componentType == 'HasParent') {
        final changedEntity = game.currentWorld.getEntity(change.entityId);

        // If selected entity's parent changed, follow them to new parent
        if (game.selectedEntity.value?.id == change.entityId) {
          final newParent = changedEntity.get<HasParent>();
          if (newParent != null) {
            game.viewedParentId.value = newParent.parentEntityId;
            Logger("game_screen").info(
                "Selected entity parent changed - following to parent ${newParent.parentEntityId}");
          }
        }
      }
    });

    // TODO: why do we have this? Is this necessary? Dont we have a component that already does this?
    gridNotifier.addListener(() {
      _logger.info("gridNotifier triggered", {"xy": gridNotifier.value});

      // var entities = game.currentWorld.get<LocalPosition>();
      // entities.forEach((id, comp) {
      //   if (comp.x == gridNotifier.value.x && comp.y == gridNotifier.value.y) {
      //     game.selectedEntity.value = game.currentWorld.getEntity(id);
      //   }
      // });
    });

    // Rebuild hierarchy cache after loading entities (HierarchySystem normally does this during tick)
    game.currentWorld.hierarchyCache.rebuild(game.currentWorld);

    // Find an entity named "Player" to set default viewedParentId
    final playerEntity = game.currentWorld.entities().firstWhereOrNull(
          (e) => e.get<Name>()?.name == "Player",
        );
    final playerParent = playerEntity?.get<HasParent>();
    if (playerParent != null) {
      game.viewedParentId.value = playerParent.parentEntityId;
    }

    // Update the vision system on game-load for all observers.
    var visionSystem = game.currentWorld.systems.whereType<VisionSystem>().firstOrNull;
    // Find all entities with VisionRadius
    final observers = game.currentWorld.entities().where((entity) {
      return entity.get<VisionRadius>() != null;
    });
    // Calculate vision for each observer
    for (final observer in observers) {
      visionSystem?.updateVisionForObserver(game.currentWorld, observer.id);
    }

    // Don't set observerEntityId by default - let user click to select
    // game.observerEntityId.value = null; (already null by default)

    // Listen to viewedParentId changes to filter rendered entities AND clear selection
    game.viewedParentId.addListener(() {
      Logger("game_screen").info("viewedParentId changed to ${game.viewedParentId}");
      _updateRenderedEntities(game);

      // Clear observer selection when changing viewed parent
      // game.observerEntityId.value = null; // TODO: why were we clearing out the observer entity? Maybe only do so if the entity does not exist within the new parnent?
    });

    // Listen to observerEntityId changes to immediately recalculate vision
    game.observerEntityId.addListener(() {
      final observerId = game.observerEntityId.value;
      Logger("game_screen").info("Observer entity ID changed to: $observerId");
      if (observerId != null) {
        // Find the VisionSystem and trigger immediate vision update
        final visionSystem =
            game.currentWorld.systems.whereType<VisionSystem>().firstOrNull;
        Logger("game_screen")
            .info("Vision system found: ${visionSystem != null}");
        if (visionSystem != null) {
          Logger("game_screen")
              .info("Updating vision for observer $observerId");

          // TODO: have to comment out the below line. Otherwise we can get into a ValueListener controller error when
          // we move Controls to a new entity, since would change our game.observerEntityId immediately and end up in here
          // before we are done processing, which somehow causes an issue.
          //visionSystem.updateVisionForObserver(game.currentWorld, observerId);
        }
      }
    });

    // Add dynamic vision cone (renders first = below everything)
    // Only shows when an entity with VisionRadius is selected
    add(VisionConeComponent(
      world: game.currentWorld,
      observerIdNotifier: game.observerEntityId,
    )..priority = -1000);

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
      _spawnRenderableEntity(game, game.currentWorld.getEntity(entity.id));
    });
  }

  void _initializeControlExample(GameArea game) {
    var reg = game.currentWorld;

    // Create hierarchical structure:
    // Galaxy (abstract container)
    //   └─ Spaceship Alpha
    //       └─ Player
    //   └─ Spaceship beta

    final galaxy = reg.add([
      Name(name: "Milky Way Galaxy"),
    ]);

    // Level 2: Star Systems (abstract parents - no position/renderable)
    final spaceShipAlpha = reg.add([
      Name(name: "Spaceship Alpha"),
      HasParent(galaxy.id),

      Renderable("images/ship.svg"),
      Direction(CompassDirection.north),
      LocalPosition(x: 0, y: 0),
      Controllable(),
      VisionRadius(radius: 7, fieldOfViewDegrees: 360),
      VisionMemory(),
    ]);

    reg.add([
      Name(name: "Spaceship Beta"),
      HasParent(galaxy.id),

      Renderable("images/ship.svg"),
      Direction(CompassDirection.north),
      LocalPosition(x: 3, y: 4),
      Controllable(), // TODO: lol this isnt a ship though but whatever.
      VisionRadius(radius: 7, fieldOfViewDegrees: 360),
      VisionMemory(),
    ]);

    // Level 4: Entities on Planet Surface
    reg.add([
      Name(name: "Player"),
      Renderable('images/player.svg'),
      LocalPosition(x: 0, y: 0),
      BlocksMovement(),
      Inventory([]),
      InventoryMaxCount(5),
      Health(4, 5),
      VisionRadius(radius: 7, fieldOfViewDegrees: 90),
      Direction(CompassDirection.north),
      HasParent(spaceShipAlpha.id),
    ]);


    reg.add([
      Name(name: "Spaceship controls"),
      Renderable('images/control.svg'),
      LocalPosition(x: 2, y: 3),
      HasParent(spaceShipAlpha.id),
      EnablesControl(controlledEntityId: spaceShipAlpha.id),
    ]);
  }

  @override
  void onRemove() {
    _spawnListener?.cancel();
    _viewedParentListener?.cancel();
    disposeAll();
  }

  /// Determines if an entity should be rendered based on the viewed parent filter.
  ///
  /// Returns true if:
  /// - viewedParentId is null (show all entities)
  /// - Entity has HasParent component with parentEntityId matching viewedParentId
  bool _shouldRenderEntity(Entity entity, int? viewedParentId) {
    if (viewedParentId == null) {
      return true; // Show all entities
    }

    final hasParent = entity.get<HasParent>();
    if (hasParent == null) {
      return false; // Entity has no parent, don't show when filtering
    }

    return hasParent.parentEntityId == viewedParentId;
  }

  /// Updates which entities are rendered based on the current viewedParentId filter.
  void _updateRenderedEntities(GameArea game) {
    final viewedParentId = game.viewedParentId.value;

    // Get all entities that should be rendered
    final entitiesToRender = game.currentWorld
        .entities()
        .where((e) => e.has<LocalPosition>() && e.has<Renderable>())
        .where((e) => _shouldRenderEntity(e, viewedParentId))
        .toSet();

    // Find Flame components that correspond to rendered entities
    final componentsToKeep = <int>{};
    final componentsToRemove = <flame.Component>[];

    // Check all child components
    for (final component in children) {
      if (component is Agent) {
        final entityId = component.entity.id;
        if (entitiesToRender.any((e) => e.id == entityId)) {
          componentsToKeep.add(entityId);
        } else {
          componentsToRemove.add(component);
        }
      }
    }

    // Remove components that shouldn't be visible
    for (final component in componentsToRemove) {
      if (component is Agent) {
        _renderedEntities.remove(component.entity.id);
      }
      component.removeFromParent();
    }

    // Add components for entities that should be visible but aren't rendered yet
    for (final entity in entitiesToRender) {
      if (!componentsToKeep.contains(entity.id) &&
          !_renderedEntities.contains(entity.id)) {
        _spawnRenderableEntity(game, entity);
      }
    }
  }

  void _spawnRenderableEntity(GameArea game, Entity entity) {
    if (_renderedEntities.contains(entity.id)) return;
    final renderable = entity.get<Renderable>();
    final lp = entity.get<LocalPosition>();
    if (renderable == null || lp == null) return;

    // Check if entity should be rendered based on viewedParentId filter
    if (!_shouldRenderEntity(entity, game.viewedParentId.value)) {
      return;
    }

    final position = flame.Vector2(lp.x * 32, lp.y * 32);
    flame.Component component;

    if (entity.has<AiControlled>()) {
      component = Opponent(
        world: game.currentWorld,
        entity: game.currentWorld.getEntity(entity.id),
        assetPath: renderable.svgAssetPath,
        position: position,
      );
    } else {
      component = Agent(
        world: game.currentWorld,
        entity: game.currentWorld.getEntity(entity.id),
        assetPath: renderable.svgAssetPath,
        position: position,
      );
    }

    add(component);
    _renderedEntities.add(entity.id);
  }
}
