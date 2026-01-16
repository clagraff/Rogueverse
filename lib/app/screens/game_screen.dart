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
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/ecs/systems.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/components/agent.dart';
import 'package:rogueverse/game/components/dialog_control_handler.dart';
import 'package:rogueverse/game/components/drag_select_component.dart';
import 'package:rogueverse/game/components/editor_control_handler.dart';
import 'package:rogueverse/game/components/entity_drag_mover.dart';
import 'package:rogueverse/game/components/entity_hover_tracker.dart';
import 'package:rogueverse/game/components/entity_tap_component.dart';
import 'package:rogueverse/game/components/focus_on_tap_component.dart';
import 'package:rogueverse/game/components/game_mode_toggle.dart';
import 'package:rogueverse/game/components/global_control_handler.dart';
import 'package:rogueverse/game/components/grid_tap.dart';
import 'package:rogueverse/game/components/interaction_control_handler.dart';
import 'package:rogueverse/game/components/interaction_highlight.dart';
import 'package:rogueverse/game/components/inventory_control_handler.dart';
import 'package:rogueverse/game/components/opponent.dart';
import 'package:rogueverse/game/components/positional_control_handler.dart';
import 'package:rogueverse/game/components/template_entity_spawner.dart';
import 'package:rogueverse/game/components/overlay_toggle.dart';
import 'package:rogueverse/game/components/vision_cone.dart';
// DEBUG: Uncomment to enable camera center crosshair
// import 'package:rogueverse/game/components/camera_center_debug.dart';
import 'package:rogueverse/game/components/camera_controller.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/game/utils/grid_coordinates.dart';
import 'package:rogueverse/app/widgets/overlays/unified_editor_panel.dart';
import 'package:rogueverse/game/hud/health_bar.dart';

class GameScreen extends flame.World with Disposer {
  late FocusNode gameFocusNode;
  final Set<int> _renderedEntities = {};
  static final _logger = Logger('GameScreen');

  StreamSubscription<Change>? _spawnListener;
  StreamSubscription<int?>? _viewedParentListener;

  // Control handler references for mode switching
  late PositionalControlHandler _positionalControlHandler;
  late GlobalControlHandler _globalControlHandler;
  late InventoryControlHandler _inventoryControlHandler;
  late InteractionControlHandler _interactionControlHandler;
  late DialogControlHandler _dialogControlHandler;
  late EditorControlHandler _editorControlHandler;
  late EntityTapComponent _entityTapComponent;
  late DragSelectComponent _dragSelectComponent;

  GameScreen(FocusNode focusNode) {
    gameFocusNode = focusNode;
  }

  @override
  bool containsLocalPoint(flame.Vector2 point) => true;

  @override
  Future<void> onLoad() async {
    final game = parent!.findGame() as GameArea;

    // Attempt to load world-state from local save file (initial + patch).
    // TODO this can only work when running on Desktop, not web!
    var save = await WorldSaves.loadSaveWithPatch();
    if (save != null) {
      game.currentWorld = save;
      // Update tick scheduler to use the loaded world
      game.tickScheduler.updateWorld(save);
    } else {
      // No initial.json exists - write the current (empty) world as initial state.
      // This ensures _cachedInitialState is set for the editor to function.
      await WorldSaves.writeInitialState(game.currentWorld);
    }

    // Create template entity spawner (listens to template selection and blank entity mode)
    add(TemplateEntitySpawner(
      world: game.currentWorld,
      templateNotifier: game.selectedTemplate,
      blankEntityModeNotifier: game.blankEntityMode,
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
      // Only hide editor panel in gameplay mode - in editing mode, clicking selects entities
      if (game.gameMode.value == GameMode.gameplay) {
        game.overlays.remove(UnifiedEditorPanel.overlayName);
      }
    }));

    add(GridTapComponent(32, gridNotifier));
    _entityTapComponent = EntityTapComponent(32, game.selectedEntities, game.currentWorld,
        observerEntityIdNotifier: game.observerEntityId, viewedParentNotifier: game.viewedParentId);
    add(_entityTapComponent);
    add(EntityTapVisualizerComponent(game.selectedEntities));
    add(GridTapVisualizerComponent(gridNotifier));

    // Add drag-select component for multi-select in editing mode
    _dragSelectComponent = DragSelectComponent(
      isEnabled: false, // Starts disabled, enabled in editing mode
      focusNode: gameFocusNode, // Ensure focus stays on game area after drag
      onSelectionComplete: (rect) {
        // Query all entities with LocalPosition in the viewed parent
        var query = Query().require<LocalPosition>();
        final viewedParentId = game.viewedParentId.value;
        if (viewedParentId != null) {
          query = query.require<HasParent>((hp) => hp.parentEntityId == viewedParentId);
        } else {
          query = query.exclude<HasParent>();
        }

        final selected = <Entity>{};
        for (final entity in query.find(game.currentWorld)) {
          final lp = entity.get<LocalPosition>()!;
          final screenPos = GridCoordinates.gridToScreen(lp);
          // Check if entity center is within selection rectangle
          final entityCenter = screenPos + flame.Vector2.all(16); // Half of 32px tile
          if (rect.contains(Offset(entityCenter.x, entityCenter.y))) {
            selected.add(entity);
          }
        }

        if (selected.isNotEmpty) {
          game.selectedEntities.value = selected;
          _logger.fine('drag-selected entities', {'count': selected.length});
        }
      },
    );
    add(_dragSelectComponent);

    add(FpsComponent());
    add(TimeTrackComponent());

    // Add overlay toggles for keyboard shortcuts
    // Both Ctrl+E and Ctrl+T toggle the unified editor panel
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

    // Add debug overlay
    // add(DebugInfoOverlay(
    //   selectedEntityNotifier: game.selectedEntity,
    //   observerEntityIdNotifier: game.observerEntityId,
    //   game: game,
    // ));

    // Add control handlers (store references for mode switching)
    _positionalControlHandler = PositionalControlHandler(
      selectedEntityNotifier: game.selectedEntity,
      world: game.currentWorld,
    );
    add(_positionalControlHandler);

    _inventoryControlHandler = InventoryControlHandler(
      selectedEntityNotifier: game.selectedEntity,
      world: game.currentWorld,
    );
    add(_inventoryControlHandler);

    _interactionControlHandler = InteractionControlHandler(
      selectedEntityNotifier: game.selectedEntity,
      world: game.currentWorld,
    );
    add(_interactionControlHandler);
    // Store reference in GameArea for overlay access
    game.interactionHandler = _interactionControlHandler;

    // Add interaction highlight circle (shows target during menu navigation)
    add(InteractionHighlight(
      highlightedEntityNotifier: _interactionControlHandler.highlightedEntity,
    ));

    // Add dialog control handler
    _dialogControlHandler = DialogControlHandler(
      selectedEntityNotifier: game.selectedEntity,
      world: game.currentWorld,
    );
    add(_dialogControlHandler);
    // Store reference in GameArea for overlay access
    game.dialogHandler = _dialogControlHandler;

    _globalControlHandler = GlobalControlHandler(selectedEntityNotifier: game.selectedEntities);
    add(_globalControlHandler);

    // Add editor control handler (DEL to delete, etc.) - enabled in editing mode
    _editorControlHandler = EditorControlHandler(
      selectedEntitiesNotifier: game.selectedEntities,
      viewedParentIdNotifier: game.viewedParentId,
    );
    add(_editorControlHandler);

    // Add game mode toggle (Ctrl+` to switch between gameplay and editing)
    add(GameModeToggle());

    // Listen to game mode changes and update handler enabled states
    game.gameMode.addListener(() {
      final isGameplay = game.gameMode.value == GameMode.gameplay;
      // Gameplay mode handlers
      _positionalControlHandler.isEnabled = isGameplay;
      _globalControlHandler.isEnabled = isGameplay;
      _inventoryControlHandler.isEnabled = isGameplay;
      _interactionControlHandler.isEnabled = isGameplay;
      _dialogControlHandler.isEnabled = isGameplay;
      // Editing mode handlers
      _entityTapComponent.isEnabled = !isGameplay;
      _dragSelectComponent.isEnabled = !isGameplay;
      _editorControlHandler.isEnabled = !isGameplay;
      _logger.info('game mode changed', {'mode': game.gameMode.value.name});
    });

    // Setup a listener for when Renderable or LocalPosition are being added
    // to an entity for the first time and _both_ are present on the entity,
    // so we can spawn a new Flame component for it.
    _spawnListener = game.currentWorld.componentChanges.listen((change) {
      if (change.kind != ChangeKind.added) return;
      // Only react to renderable/position changes; order doesn't matter.

      // TODO: need to tweak this so we only spawn renderable entities if they belong to the same
      // parent we are currently watching.
      if (change.componentType == Renderable(ImageAsset('')).componentType ||
          change.componentType == LocalPosition(x: 0, y: 0).componentType) {
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
            _logger.info('following selected entity to new parent', {'parentId': newParent.parentEntityId});
          }
        }
      }
    });

    // TODO: why do we have this? Is this necessary? Dont we have a component that already does this?
    gridNotifier.addListener(() {
      // var entities = game.currentWorld.get<LocalPosition>();
      // entities.forEach((id, comp) {
      //   if (comp.x == gridNotifier.value.x && comp.y == gridNotifier.value.y) {
      //     game.selectedEntity.value = game.currentWorld.getEntity(id);
      //   }
      // });
    });

    // Rebuild hierarchy cache after loading entities (HierarchySystem normally does this during tick)
    game.currentWorld.hierarchyCache.rebuild(game.currentWorld);

    // Find an entity named "Player" to set default selection and view.
    // TODO: In the future, consider checking if the player has a Controlling component
    // and select the controlled entity instead (e.g., when piloting a ship). Could also
    // persist the "currently controlled entity ID" in the save file.
    final playerEntity = game.currentWorld.entities().firstWhereOrNull(
          (e) => e.get<Name>()?.name == "Player",
        );
    if (playerEntity != null) {
      // Set the player as the selected/controlled entity
      game.selectedEntities.value = {playerEntity};
      // Set the player as the vision observer
      game.observerEntityId.value = playerEntity.id;
      // Set the view to the player's parent (room/location)
      final playerParent = playerEntity.get<HasParent>();
      if (playerParent != null) {
        game.viewedParentId.value = playerParent.parentEntityId;
      }
      // Add camera controller that follows the selected entity (defaults to follow mode)
      final cameraController = CameraController(
        followedEntityNotifier: game.selectedEntity,
      );
      add(cameraController);
      game.cameraController = cameraController;
      _logger.info('auto-selected player entity', {'id': playerEntity.id});
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

    // Listen to viewedParentId changes to filter rendered entities AND clear selection
    game.viewedParentId.addListener(() {
      _logger.fine('viewed parent changed', {'id': game.viewedParentId.value});
      _updateRenderedEntities(game);

      // Clear observer selection when changing viewed parent
      // game.observerEntityId.value = null; // TODO: why were we clearing out the observer entity? Maybe only do so if the entity does not exist within the new parnent?
    });

    // Listen to observerEntityId changes to immediately recalculate vision
    game.observerEntityId.addListener(() {
      final observerId = game.observerEntityId.value;
      _logger.fine('observer entity changed', {'id': observerId});
      if (observerId != null) {
        // Find the VisionSystem and trigger immediate vision update
        final visionSystem =
            game.currentWorld.systems.whereType<VisionSystem>().firstOrNull;
        if (visionSystem != null) {
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

    // DEBUG: Uncomment to show crosshair where camera thinks the center is
    // add(CameraCenterDebug()..priority = 1000);

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

  @override
  void onRemove() {
    _spawnListener?.cancel();
    _viewedParentListener?.cancel();
    disposeAll();
  }

  /// Determines if an entity should be rendered based on the viewed parent filter.
  ///
  /// Returns true if:
  /// - viewedParentId is null: show only root-level entities (no HasParent)
  /// - viewedParentId is set: show only entities with HasParent matching that ID
  bool _shouldRenderEntity(Entity entity, int? viewedParentId) {
    // Check HasParent directly from component map for reliable lookup
    final hasParentMap = entity.parentCell.get<HasParent>();
    final hasParent = hasParentMap[entity.id];

    if (viewedParentId == null) {
      // At root level, only show entities WITHOUT HasParent
      return hasParent == null;
    }

    if (hasParent == null) {
      return false; // Entity has no parent, don't show when filtering by parent
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
        asset: renderable.asset,
        position: position,
      );
    } else {
      component = Agent(
        world: game.currentWorld,
        entity: game.currentWorld.getEntity(entity.id),
        asset: renderable.asset,
        position: position,
      );
    }

    add(component);
    _renderedEntities.add(entity.id);
  }
}
