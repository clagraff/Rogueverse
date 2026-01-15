import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flame/components.dart' hide World;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart' show Logger;

import 'package:rogueverse/app/screens/game_screen.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/game/components/interaction_control_handler.dart';
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

  /// The currently selected entity template in the template panel.
  final ValueNotifier<EntityTemplate?> selectedTemplate = ValueNotifier(null);

  /// Whether blank entity placement mode is active.
  /// When true, clicking in the game area places a default entity without a template.
  /// Mutually exclusive with selectedTemplate.
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

  /// Reference to the interaction control handler for overlay access.
  /// Set by GameScreen during initialization.
  InteractionControlHandler? interactionHandler;

  /// Temporary world used for editing templates in the inspector.
  World? _templateEditingWorld;

  /// Temporary entity being edited for template creation/editing.
  Entity? _templateEditingEntity;

  /// ID of the template currently being edited.
  int? _editingTemplateId;

  @override
  get debugMode => false;

  /// The current <code>ECS</code> world instance being processed.
  late World currentWorld;

  /// Used for dispatching scroll-related events, before otherwise controlling the camera.
  late final ScrollDispatcher scrollDispatcher;

  /// Creates a new game area with the specified focus node for keyboard input.
  ///
  /// Initializes the game world, ECS systems, and sets up the core game state.
  ///
  /// [gameFocusNode] - The focus node used to capture keyboard input for the game.
  GameArea(FocusNode gameFocusNode) {
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

    world = GameScreen(gameFocusNode);
    var systems = [
      HierarchySystem(), // Rebuild hierarchy cache FIRST (other systems may use it)
      BehaviorSystem(), // AI decides what to do
      ControlSystem(), // Process control intents (before movement/combat)
      CollisionSystem(), // Check for blocked movement
      MovementSystem(), // Execute movement and update Direction
      PortalSystem(), // Execute portaling (after movement)
      VisionSystem(), // Calculate vision AFTER movement/portaling (sees new position/direction)
      InventorySystem(),
      CombatSystem(),
      OpenableSystem(),
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

    // Pause tick scheduler when entering editing mode, resume when in gameplay
    // This listener handles the layered save system:
    // - On entering editor: save progress as patch, reload pure initial state
    // - On exiting editor: save initial state, reload with patch applied
    gameMode.addListener(() {
      if (gameMode.value == GameMode.editing) {
        _onEnterEditorMode();
      } else {
        _onExitEditorMode();
      }
    });

    // Handle switching edit targets while already in edit mode
    editTarget.addListener(() {
      if (gameMode.value == GameMode.editing) {
        _onEditTargetChanged();
      }
    });

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
    selectedTemplate.addListener(() {
      if (selectedTemplate.value != null) {
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
        selectedTemplate.value = null;
      }
    });
  }

  /// Handles entering editor mode: saves progress and loads appropriate state.
  Future<void> _onEnterEditorMode() async {
    tickScheduler.pause();

    if (editTarget.value == EditTarget.initial) {
      // Editing initial state: save current progress as patch, reload pure initial
      await WorldSaves.writeSavePatch(currentWorld);
      currentWorld.loadFrom(WorldSaves.initialState);
    } else {
      // Editing save state: save patch to preserve progress, keep current state
      await WorldSaves.writeSavePatch(currentWorld);
      // World already contains initial + patch, so no reload needed
    }

    // Clear selections since we may have reloaded the world
    selectedEntities.value = {};
    selectedEntity.value = null;
    observerEntityId.value = null;
  }

  /// Handles exiting editor mode: saves to appropriate target, restores gameplay.
  Future<void> _onExitEditorMode() async {
    if (editTarget.value == EditTarget.initial) {
      // Save the edited world as the new initial state
      await WorldSaves.writeInitialState(currentWorld);

      // Reload initial state + apply save patch to restore player progress
      try {
        var worldWithPatch = await WorldSaves.loadSaveWithPatch();
        if (worldWithPatch != null) {
          currentWorld.loadFrom(worldWithPatch.toMap());
        }
      } catch (e) {
        _logger.severe("save patch could not be applied after editor changes", e);
        await WorldSaves.clearSavePatch();
      }
    } else {
      // Save the edited world as a patch (diff from initial)
      await WorldSaves.writeSavePatch(currentWorld);
      // World is already in the correct state, no reload needed
    }

    // Restore player control after potential world reload
    _restorePlayerControl();

    tickScheduler.resume();
  }

  /// Handles switching edit targets while already in edit mode.
  /// Always saves current state to the old target before loading the new one.
  Future<void> _onEditTargetChanged() async {
    if (editTarget.value == EditTarget.initial) {
      // Switched TO initial editing (from save)
      // Save current state as patch (we were editing the save state)
      await WorldSaves.writeSavePatch(currentWorld);
      // Load pure initial state for editing
      currentWorld.loadFrom(WorldSaves.initialState);
    } else {
      // Switched TO save editing (from initial)
      // Save current state as initial (we were editing the initial state)
      await WorldSaves.writeInitialState(currentWorld);
      // Load initial + patch for editing (creates empty patch if none exists)
      var worldWithPatch = await WorldSaves.loadSaveWithPatch();
      if (worldWithPatch != null) {
        currentWorld.loadFrom(worldWithPatch.toMap());
      }
      // If no patch existed, worldWithPatch returns the initial state anyway
    }

    // Clear selections since we've reloaded the world
    selectedEntities.value = {};
    selectedEntity.value = null;
    observerEntityId.value = null;
  }

  /// Finds the Player entity and restores selection, observer, and view to it.
  void _restorePlayerControl() {
    final playerEntity = currentWorld.entities().firstWhereOrNull(
          (e) => e.has<Player>(),
        );

    if (playerEntity != null) {
      // Set the player as the selected/controlled entity
      selectedEntities.value = {playerEntity};
      // Set the player as the vision observer
      observerEntityId.value = playerEntity.id;
      // Set the view to the player's parent (room/location)
      final playerParent = playerEntity.get<HasParent>();
      if (playerParent != null) {
        viewedParentId.value = playerParent.parentEntityId;
      }
      _logger.info('Restored player control: entity ${playerEntity.id}');
    } else {
      // No player found, just clear selection
      selectedEntities.value = {};
      observerEntityId.value = null;
      _logger.warning('No Player entity found to restore control');
    }
  }

  /// Initializes the game area by setting up the camera anchor, camera controls,
  /// and scroll dispatcher for handling scroll events.
  @override
  FutureOr<void> onLoad() {
    camera.viewfinder.anchor = Anchor.topLeft;

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

      // Get world position under the cursor BEFORE zoom
      final worldBefore = camera.globalToLocal(info.eventPosition.global);

      // Zoom in or out
      final zoomChange = info.scrollDelta.global.y.sign * 0.1 * -1;
      viewfinder.zoom = (viewfinder.zoom + zoomChange).clamp(0.1, 4.0);

      // Get world position under the cursor AFTER zoom
      final worldAfter = camera.globalToLocal(info.eventPosition.global);

      // Compute the change and shift the camera to preserve cursor focus
      final shift = worldBefore - worldAfter;
      viewfinder.position += shift;
    }
  }

  /// Manually triggers a single ECS tick.
  ///
  /// Note: With periodic ticks enabled, this is mainly useful for debugging.
  /// Saving is handled by SaveSystem on a periodic basis.
  void tickEcs() {
    currentWorld.tick();
  }

  /// Starts creating a new template by showing a name dialog and setting up temp world.
  Future<void> startTemplateCreation(BuildContext context) async {
    // Show dialog to get template name
    final name = await _showTemplateNameDialog(context);
    if (name == null || name.trim().isEmpty) return;

    // Generate new ID
    final id = TemplateRegistry.instance.generateId();

    // Create temporary world and entity for editing
    _templateEditingWorld = World([], {});
    _templateEditingEntity = _templateEditingWorld!.add([]);
    _editingTemplateId = id;

    // Create empty template
    final template = EntityTemplate(
      id: id,
      displayName: name.trim(),
      components: [],
    );
    await TemplateRegistry.instance.save(template);

    // Set up auto-save listener
    _setupTemplateAutoSave();

    // Select entity for editing (Properties panel is already visible in editing mode)
    selectedEntities.value = {_templateEditingEntity!};
  }

  /// Sets up a listener to auto-save template changes.
  void _setupTemplateAutoSave() {
    if (_templateEditingWorld == null ||
        _templateEditingEntity == null ||
        _editingTemplateId == null) {
      return;
    }

    // Listen to all component changes on the temp entity
    _templateEditingWorld!
        .componentChanges
        .onEntityChange(_templateEditingEntity!.id)
        .listen((change) async {
      // Extract current components and save to template
      final template = EntityTemplate.fromEntity(
        id: _editingTemplateId!,
        displayName:
            TemplateRegistry.instance.getById(_editingTemplateId!)!.displayName,
        entity: _templateEditingEntity!,
      );

      await TemplateRegistry.instance.save(template);
    });
  }

  /// Starts editing an existing template by loading it into a temp world and opening the inspector.
  Future<void> startTemplateEditing(
      BuildContext context, EntityTemplate template) async {
    // Create temporary world and entity for editing
    _templateEditingWorld = World([], {});
    _templateEditingEntity = _templateEditingWorld!.add([]);
    _editingTemplateId = template.id;

    // Load template components into the temporary entity
    for (final component in template.components) {
      _templateEditingEntity!.upsertByName(component);
    }

    // Set up auto-save listener (reuse existing method)
    _setupTemplateAutoSave();

    // Select entity for editing (Properties panel is already visible in editing mode)
    selectedEntities.value = {_templateEditingEntity!};
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
