import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flame/components.dart' hide World;
import 'package:flame/text.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart' show Logger;

import 'package:rogueverse/app/screens/game_screen.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/ecs/systems/death_system.dart';
import 'package:rogueverse/game/components/camera_controller.dart';
import 'package:rogueverse/game/components/dialog_control_handler.dart';
import 'package:rogueverse/game/components/interaction_control_handler.dart';
import 'package:rogueverse/game/components/editor_mode_manager.dart';
import 'package:rogueverse/game/mixins/scroll_callback.dart';
import 'package:rogueverse/game/tick_scheduler.dart';

/// The two main modes of the game: gameplay (playing) and editing (world building).
enum GameMode {
  /// Normal gameplay mode - controls active, vision restricted to observer.
  gameplay,

  /// Editing mode - controls disabled, full visibility, entity selection allowed.
  editing,
}

/// The target for edits when in editing mode.
enum EditTarget {
  /// Edit the initial world state (saved to initial.json).
  initial,

  /// Edit the save/patch state (saved to save.patch.json).
  save,
}

/// The main game area component that manages the ECS world, camera controls,
/// and entity/template selection for the game editor.
class GameArea extends FlameGame
    with HasKeyboardHandlerComponents, ScrollDetector {

  final Logger _logger = Logger("GameArea");

  /// The currently selected entities for inspection/editing in the inspector panel.
  /// Supports multi-select for batch operations (delete, move, etc.).
  final ValueNotifier<Set<Entity>> selectedEntities = ValueNotifier({});

  /// The currently selected entity for inspection/editing in the inspector panel.
  /// This is a convenience notifier that stays in sync with selectedEntities.
  /// Returns the first selected entity, or null if none selected.
  final ValueNotifier<Entity?> selectedEntity = ValueNotifier(null);

  /// The currently selected template entity ID in the template panel.
  /// When set, clicking places entities with FromTemplate pointing to this template.
  final ValueNotifier<int?> selectedTemplateId = ValueNotifier(null);

  /// Whether blank entity placement mode is active.
  /// When true, clicking in the game area places a default entity without a template.
  /// Mutually exclusive with selectedTemplateId.
  final ValueNotifier<bool> blankEntityMode = ValueNotifier(false);

  /// The current title displayed in the app bar.
  final ValueNotifier<String> title = ValueNotifier('');

  /// The entity ID whose perspective we're viewing from (for vision-based rendering).
  /// Defaults to the player's entity ID. Used to determine which entities are visible.
  final ValueNotifier<int?> observerEntityId = ValueNotifier(null);

  /// The parent entity ID whose children should be rendered in the game area.
  /// null = render all entities (no filtering, default behavior)
  /// Non-null = render only entities with HasParent(viewedParentId)
  final ValueNotifier<int?> viewedParentId = ValueNotifier(null);

  /// The current game mode - gameplay (playing) or editing (world building).
  /// In gameplay mode: controls active, vision restricted to observer.
  /// In editing mode: controls disabled, full visibility, entity selection allowed.
  final ValueNotifier<GameMode> gameMode = ValueNotifier(GameMode.gameplay);

  /// The target for edits when in editing mode.
  /// Initial = edit initial.json (authored content).
  /// Save = edit save.patch.json (player progress).
  final ValueNotifier<EditTarget> editTarget = ValueNotifier(EditTarget.initial);

  /// Manages periodic game ticks (OSRS-style 0.6s intervals).
  late final TickScheduler tickScheduler;

  /// Manages transitions between gameplay and editing modes.
  late final EditorModeManager editorModeManager;

  /// Reference to the interaction control handler for overlay access.
  /// Set by GameScreen during initialization.
  InteractionControlHandler? interactionHandler;

  /// Reference to the dialog control handler for overlay access.
  /// Set by GameScreen during initialization.
  DialogControlHandler? dialogHandler;

  /// Reference to the camera controller for notifying manual camera movements.
  /// Set by GameScreen during initialization.
  CameraController? cameraController;

  /// Notifier for toast messages. Application listens to this to show snackbars.
  final ValueNotifier<String?> toastMessage = ValueNotifier(null);

  /// Shows a toast message by updating the toastMessage notifier.
  void showToast(String message) {
    toastMessage.value = message;
  }

  /// Notifier that signals when the menu should be opened (e.g., Escape pressed).
  /// GameScreenWrapper listens to this to open the navigation drawer.
  final ValueNotifier<bool> menuRequested = ValueNotifier(false);

  /// Requests the menu to be opened.
  void requestMenu() {
    menuRequested.value = true;
  }

  @override
  get debugMode => false;

  /// The current <code>ECS</code> world instance being processed.
  late World currentWorld;

  /// Used for dispatching scroll-related events, before otherwise controlling the camera.
  late final ScrollDispatcher scrollDispatcher;

  /// The path to the save patch file for this game session.
  /// Used for loading and saving game progress.
  final String? savePatchPath;

  /// Creates a new game area with the specified focus node for keyboard input.
  ///
  /// Initializes the game world, ECS systems, and sets up the core game state.
  ///
  /// [gameFocusNode] - The focus node used to capture keyboard input for the game.
  /// [savePatchPath] - Optional path to the save patch file. If null, a new game is started.
  GameArea(FocusNode gameFocusNode, {this.savePatchPath}) {
    // Sync selectedEntities → selectedEntity for backwards compatibility
    selectedEntities.addListener(() {
      selectedEntity.value = selectedEntities.value.firstOrNull;
    });

    // Sync selectedEntities → observerEntityId for TickScheduler
    // This ensures the tick scheduler watches the correct entity for intents
    selectedEntities.addListener(() {
      final firstSelected = selectedEntities.value.firstOrNull;
      _logger.info("selectedEntities changed: firstSelected=$firstSelected, setting observerEntityId to ${firstSelected?.id}");
      observerEntityId.value = firstSelected?.id;
    });

    world = GameScreen(gameFocusNode, savePatchPath: savePatchPath);
    var systems = [
      BehaviorSystem(), // AI decides what to do
      ControlSystem(), // Process control intents (before movement/combat)
      CollisionSystem(), // Check for blocked movement
      MovementSystem(), // Execute movement
      DirectionSystem(), // Process DirectionIntent from movement + face-in-place
      PortalSystem(), // Execute portaling (after movement)
      VisionSystem(), // Calculate vision AFTER movement/portaling (sees new position/direction)
      InventorySystem(),
      CombatSystem(),
      DeathSystem(), // Process deaths and spawn loot (after CombatSystem)
      OpenableSystem(),
      DialogSystem(), // Process dialog intents (TalkIntent, DialogAdvanceIntent, DialogExitIntent)
      SaveSystem(), // Periodic saves (runs last, priority 200)
    ];

    currentWorld = World(systems, {});

    // Initialize tick scheduler (defaults to onPlayerIntent mode)
    _logger.info("Creating TickScheduler with observerEntityId=${observerEntityId.value}");
    tickScheduler = TickScheduler(
      world: currentWorld,
      playerEntityIdNotifier: observerEntityId,
      onTick: () {
        currentWorld.tick();
      },
    );

    // Initialize editor mode manager (handles mode transitions and persistence)
    editorModeManager = EditorModeManager(
      world: currentWorld,
      tickScheduler: tickScheduler,
      gameModeNotifier: gameMode,
      editTargetNotifier: editTarget,
      selectedEntitiesNotifier: selectedEntities,
      selectedEntityNotifier: selectedEntity,
      observerEntityIdNotifier: observerEntityId,
      viewedParentIdNotifier: viewedParentId,
      savePatchPath: savePatchPath,
    );

    // Listen for Controlling component changes to update selectedEntity
    currentWorld.componentChanges
        .onComponentAdded<Controlling>()
        .listen((change) {
      final actor = currentWorld.getEntity(change.entityId);
      final controlling = actor.get<Controlling>()!;
      final controlledEntity = currentWorld.getEntity(controlling.controlledEntityId);

      _logger.info("entity control triggered", {"controllerEntityId": change.entityId, "controlledId": controlling.controlledEntityId});

      // TODO: need to check the JSON state AFTER we take control, to see if the planet has visible entities, a vision radius, etc.
      // Update which entity we are controlling and viewing based on which has just gained control.
      selectedEntities.value = {controlledEntity};
      observerEntityId.value = controlledEntity.id;
      viewedParentId.value = controlledEntity.get<HasParent>()?.parentEntityId;

      _logger.finest("controlled entity visibility",{"vision": controlledEntity.get<VisionRadius>(), "memory": controlledEntity.get<VisionMemory>()});
    });

    currentWorld.componentChanges
        .onComponentRemoved<Controlling>()
        .listen((change) {
      // Switch selectedEntity back to the actor
      selectedEntities.value = {currentWorld.getEntity(change.entityId)};
    });

    // Clear selected entity and observer when switching to a different parent view
    viewedParentId.addListener(() {
      selectedEntities.value = {};
      observerEntityId.value = null;
    });

    // Clear selected entity and observer when entering template placement mode
    selectedTemplateId.addListener(() {
      if (selectedTemplateId.value != null) {
        selectedEntities.value = {};
        observerEntityId.value = null;
        // Mutually exclusive with blank entity mode
        blankEntityMode.value = false;
      }
    });

    // Clear selected entity and observer when entering blank entity mode
    blankEntityMode.addListener(() {
      if (blankEntityMode.value) {
        selectedEntities.value = {};
        observerEntityId.value = null;
        // Mutually exclusive with template selection
        selectedTemplateId.value = null;
      }
    });
  }

  /// Initializes the game area by setting up the camera anchor, camera controls,
  /// and scroll dispatcher for handling scroll events.
  @override
  FutureOr<void> onLoad() {
    camera.viewfinder.anchor = Anchor.topLeft;

    // Add FPS counter to the viewport (fixed position on screen)
    camera.viewport.add(
      FpsTextComponent(
        position: Vector2(10, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            shadows: [
              Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2),
            ],
          ),
        ),
      ),
    );

    // CameraControls could potentially conflict with other in-game controls. To
    // help alleviate this, we'll add CameraControls to the world, not the viewfinder, so it's in the same
    // component hierarchy and can be more easily worked around.
    //world.add(CameraControls());

    // Setup the ScrollDispatcher so other components can use `ScrollCallback`.
    scrollDispatcher = ScrollDispatcher();
    add(scrollDispatcher);

    return super.onLoad();
  }

  final Duration systemBudget = Duration(milliseconds: 2);

  @override
  void update(double dt) {
    // TODO: move this logic into the World class, next to tick().

    Timeline.timeSync("GameArea: update", () {
      Timeline.timeSync("GameArea: super.update", () {
        super.update(dt);
      });

      // Update tick scheduler (triggers periodic ticks in gameplay mode)
      if (gameMode.value == GameMode.gameplay) {
        tickScheduler.updateSeconds(dt);
      }

      // TODO: probably need to move this out from here for performance reasons.
      var budgetedSystems = Timeline.timeSync("GameArea: fetch systems", () {
        return currentWorld
            .systems
            .whereType<BudgetedSystem>();
      });

      Timeline.timeSync("GameArea: systems", () {
        for (var system in budgetedSystems) {
          system.budget(currentWorld, systemBudget);
        }
      });
    });
  }

  /// Handles scroll events by delegating to the scroll dispatcher first,
  /// then zooming the camera if the event is not handled.
  ///
  /// The zoom level is clamped between 0.1 and 3.0.
  @override
  void onScroll(PointerScrollInfo info) {
    final handled = scrollDispatcher.dispatch(info);

    // If not handled (eg, by a component or something), then assume we are trying
    // to zoom in/out the camera.
    if (!handled) {
      final camera = this.camera;
      final viewfinder = camera.viewfinder;
      final isFollowing = cameraController?.mode == CameraMode.follow;
      final followCenter = cameraController?.getFollowedEntityWorldCenter();

      if (isFollowing && followCenter != null) {
        // In follow mode, zoom and keep the followed entity centered
        final zoomChange = info.scrollDelta.global.y.sign * 0.1 * -1;
        viewfinder.zoom = (viewfinder.zoom + zoomChange).clamp(0.1, 4.0);
        // Convert viewport size from screen pixels to world units
        final viewportWorldSize = camera.viewport.size / viewfinder.zoom;
        viewfinder.position = followCenter - viewportWorldSize / 2;
      } else {
        // In free mode, zoom centered on cursor position
        final worldBefore = camera.globalToLocal(info.eventPosition.global);
        final zoomChange = info.scrollDelta.global.y.sign * 0.1 * -1;
        viewfinder.zoom = (viewfinder.zoom + zoomChange).clamp(0.1, 4.0);
        final worldAfter = camera.globalToLocal(info.eventPosition.global);
        final shift = worldBefore - worldAfter;
        viewfinder.position += shift;
      }
    }
  }

  /// Manually triggers a single ECS tick.
  ///
  /// Note: With periodic ticks enabled, this is mainly useful for debugging.
  /// Saving is handled by SaveSystem on a periodic basis.
  void tickEcs() {
    currentWorld.tick();
  }

  /// Starts creating a new template by showing a name dialog and creating a template entity.
  ///
  /// Templates are now first-class entities with an [IsTemplate] marker component.
  /// The new template entity is created in the main world and selected for editing.
  Future<void> startTemplateCreation(BuildContext context) async {
    // Show dialog to get template name
    final name = await _showTemplateNameDialog(context);
    if (name == null || name.trim().isEmpty) return;

    // Create template entity in the main world
    final trimmedName = name.trim();
    final templateEntity = currentWorld.add([
      IsTemplate(displayName: trimmedName),
      Name(name: trimmedName),
    ]);

    // Save the world state
    await Persistence.writeInitialState(currentWorld);

    // Select template entity for editing
    selectedEntities.value = {templateEntity};
  }

  /// Starts editing an existing template entity.
  ///
  /// Since templates are now entities in the main world, we simply select
  /// the template entity for editing in the inspector.
  void startTemplateEditing(Entity templateEntity) {
    // Just select the template entity for editing
    selectedEntities.value = {templateEntity};
  }

  /// Shows a dialog to input a template name.
  Future<String?> _showTemplateNameDialog(BuildContext context) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Template'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Template Name',
            hintText: 'Enter a name for this template',
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
