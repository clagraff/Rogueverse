import 'package:flutter/widgets.dart';

import 'package:flame/components.dart' as flame;
import 'package:flame/debug.dart';

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'package:rogueverse/ecs/systems.dart';
import 'package:rogueverse/ecs/persistence.dart';
import 'package:rogueverse/game/components/control_handler_coordinator.dart';
import 'package:rogueverse/game/components/entity_drag_mover.dart';
import 'package:rogueverse/game/components/entity_hover_tracker.dart';
import 'package:rogueverse/game/components/focus_on_tap_component.dart';
import 'package:rogueverse/game/components/player_initializer.dart';
import 'package:rogueverse/game/components/portal_follower.dart';
import 'package:rogueverse/game/components/renderable_entity_manager.dart';
import 'package:rogueverse/game/components/selection_manager.dart';
import 'package:rogueverse/game/components/template_entity_spawner.dart';
import 'package:rogueverse/game/components/overlay_toggle.dart';
import 'package:rogueverse/game/components/vision_cone.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/app/widgets/overlays/unified_editor_panel.dart';
import 'package:rogueverse/game/hud/health_bar.dart';

class GameScreen extends flame.World with Disposer {
  late FocusNode gameFocusNode;

  /// The path to the save patch file for this game session.
  /// Used for loading game progress on startup.
  final String? savePatchPath;

  GameScreen(FocusNode focusNode, {this.savePatchPath}) {
    gameFocusNode = focusNode;
  }

  @override
  bool containsLocalPoint(flame.Vector2 point) => true;

  @override
  Future<void> onLoad() async {
    final game = parent!.findGame() as GameArea;

    // Load world state from save file
    await _loadWorld(game);

    // Add template spawner and entity drag mover
    _addEntityManagementComponents(game);

    // Add input and focus components
    _addInputComponents(game);

    // Add overlay toggles and hover tracker
    _addOverlayComponents(game);

    // Add control handler coordinator (manages all control handlers)
    add(ControlHandlerCoordinator(
      selectedEntitiesNotifier: game.selectedEntities,
      selectedEntityNotifier: game.selectedEntity,
      viewedParentIdNotifier: game.viewedParentId,
      gameModeNotifier: game.gameMode,
      world: game.currentWorld,
    ));

    // Add selection manager (handles tap and drag selection)
    add(SelectionManager(
      focusNode: gameFocusNode,
      selectedEntitiesNotifier: game.selectedEntities,
      viewedParentNotifier: game.viewedParentId,
      observerEntityIdNotifier: game.observerEntityId,
      gameModeNotifier: game.gameMode,
      world: game.currentWorld,
    ));

    // Add portal follower (auto-follows selected entity through portals)
    add(PortalFollower(
      selectedEntityNotifier: game.selectedEntity,
      viewedParentIdNotifier: game.viewedParentId,
      world: game.currentWorld,
    ));

    // Force hierarchy service to initialize after loading entities
    game.currentWorld.hierarchyCache.ensureInitialized();

    // Add player initializer (finds player, sets up view/selection/camera)
    add(PlayerInitializer(
      world: game.currentWorld,
      selectedEntitiesNotifier: game.selectedEntities,
      observerEntityIdNotifier: game.observerEntityId,
      viewedParentIdNotifier: game.viewedParentId,
    ));

    // Initialize vision system for all observers
    _initializeVision(game);

    // Add vision cone and HUD components
    _addVisionAndHudComponents(game);

    // Add renderable entity manager (handles entity rendering lifecycle)
    add(RenderableEntityManager(
      world: game.currentWorld,
      viewedParentNotifier: game.viewedParentId,
      observerEntityIdNotifier: game.observerEntityId,
    ));
  }

  /// Loads world state from local save file.
  Future<void> _loadWorld(GameArea game) async {
    var save = await Persistence.loadSaveWithPatch(savePatchPath);
    if (save != null) {
      // Use loadFrom() to properly initialize systems (especially VisionSystem's spatial index)
      game.currentWorld.loadFrom(save.toMap());
      game.tickScheduler.updateWorld(game.currentWorld);
    } else {
      // No initial.json exists - write the current (empty) world as initial state.
      await Persistence.writeInitialState(game.currentWorld);
    }
  }

  /// Adds template entity spawner and drag mover components.
  void _addEntityManagementComponents(GameArea game) {
    add(TemplateEntitySpawner(
      world: game.currentWorld,
      templateIdNotifier: game.selectedTemplateId,
      blankEntityModeNotifier: game.blankEntityMode,
      viewedParentNotifier: game.viewedParentId,
    ));

    add(EntityDragMover(
      world: game.currentWorld,
      templateIdNotifier: game.selectedTemplateId,
      game: game,
      viewedParentNotifier: game.viewedParentId,
      selectedEntitiesNotifier: game.selectedEntities,
      gameModeNotifier: game.gameMode,
    ));
  }

  /// Adds input and focus-related components.
  void _addInputComponents(GameArea game) {
    add(FocusOnTapComponent(gameFocusNode, () {
      // Only hide editor panel in gameplay mode
      if (game.gameMode.value == GameMode.gameplay) {
        game.overlays.remove(UnifiedEditorPanel.overlayName);
      }
    }));

    add(FpsComponent());
    add(TimeTrackComponent());
  }

  /// Adds overlay toggles and entity hover tracker.
  void _addOverlayComponents(GameArea game) {
    add(OverlayToggle(
      overlayName: UnifiedEditorPanel.overlayName,
      action: 'overlay.editor',
      gameFocusNode: gameFocusNode,
    ));
    add(OverlayToggle(
      overlayName: UnifiedEditorPanel.overlayName,
      action: 'overlay.templates',
      gameFocusNode: gameFocusNode,
    ));
    add(EntityHoverTracker(
      world: game.currentWorld,
      titleNotifier: game.title,
      viewedParentNotifier: game.viewedParentId,
    ));
  }

  /// Initializes vision system for all entities with VisionRadius.
  void _initializeVision(GameArea game) {
    var visionSystem = game.currentWorld.systems.whereType<VisionSystem>().firstOrNull;
    final observers = game.currentWorld.entities().where((entity) {
      return entity.get<VisionRadius>() != null;
    });
    for (final observer in observers) {
      visionSystem?.updateVisionForObserver(game.currentWorld, observer.id);
    }
  }

  /// Adds vision cone and HUD components.
  void _addVisionAndHudComponents(GameArea game) {
    add(VisionConeComponent(
      world: game.currentWorld,
      observerIdNotifier: game.observerEntityId,
    ));

    var healthHud = HealthBar();
    game.camera.viewport.add(healthHud);
  }

  @override
  void onRemove() {
    disposeAll();
  }
}
