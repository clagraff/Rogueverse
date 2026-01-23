import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/components.dart' hide Component;
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/persistence.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/game/tick_scheduler.dart';

/// Manages transitions between gameplay and editing modes.
///
/// Responsibilities:
/// - Pauses/resumes the tick scheduler when entering/exiting edit mode
/// - Saves and loads world state appropriately for each mode transition
/// - Handles switching between initial and save edit targets
/// - Restores player control when exiting edit mode
class EditorModeManager {
  static final _logger = Logger('EditorModeManager');

  final World world;
  final TickScheduler tickScheduler;
  final ValueNotifier<GameMode> gameModeNotifier;
  final ValueNotifier<EditTarget> editTargetNotifier;
  final ValueNotifier<Set<Entity>> selectedEntitiesNotifier;
  final ValueNotifier<Entity?> selectedEntityNotifier;
  final ValueNotifier<int?> observerEntityIdNotifier;
  final ValueNotifier<int?> viewedParentIdNotifier;
  final String? savePatchPath;

  EditorModeManager({
    required this.world,
    required this.tickScheduler,
    required this.gameModeNotifier,
    required this.editTargetNotifier,
    required this.selectedEntitiesNotifier,
    required this.selectedEntityNotifier,
    required this.observerEntityIdNotifier,
    required this.viewedParentIdNotifier,
    this.savePatchPath,
  }) {
    // Listen to game mode changes
    gameModeNotifier.addListener(_onGameModeChanged);

    // Listen to edit target changes (only relevant when already in edit mode)
    editTargetNotifier.addListener(_onEditTargetChanged);
  }

  void _onGameModeChanged() {
    if (gameModeNotifier.value == GameMode.editing) {
      _onEnterEditorMode();
    } else {
      _onExitEditorMode();
    }
  }

  /// Handles entering editor mode: saves progress and loads appropriate state.
  Future<void> _onEnterEditorMode() async {
    tickScheduler.pause();

    if (editTargetNotifier.value == EditTarget.initial) {
      // Editing initial state: save current progress as patch, reload pure initial
      await Persistence.writeSavePatch(world);
      world.loadFrom(Persistence.initialState);
    } else {
      // Editing save state: save patch to preserve progress, keep current state
      await Persistence.writeSavePatch(world);
      // World already contains initial + patch, so no reload needed
    }

    // Clear selections since we may have reloaded the world
    _clearSelections();
  }

  /// Handles exiting editor mode: saves to appropriate target, restores gameplay.
  Future<void> _onExitEditorMode() async {
    if (editTargetNotifier.value == EditTarget.initial) {
      // Save the edited world as the new initial state
      await Persistence.writeInitialState(world);

      // Reload initial state + apply save patch to restore player progress
      try {
        var worldWithPatch = await Persistence.loadSaveWithPatch(savePatchPath);
        if (worldWithPatch != null) {
          world.loadFrom(worldWithPatch.toMap());
        }
      } catch (e) {
        _logger.severe('save patch could not be applied after editor changes', e);
        await Persistence.clearSavePatch();
      }
    } else {
      // Save the edited world as a patch (diff from initial)
      await Persistence.writeSavePatch(world);
      // World is already in the correct state, no reload needed
    }

    // Restore player control after potential world reload
    _restorePlayerControl();

    tickScheduler.resume();
  }

  /// Handles switching edit targets while already in edit mode.
  void _onEditTargetChanged() {
    if (gameModeNotifier.value != GameMode.editing) return;
    _handleEditTargetSwitch();
  }

  /// Switches between initial and save editing targets.
  Future<void> _handleEditTargetSwitch() async {
    if (editTargetNotifier.value == EditTarget.initial) {
      // Switched TO initial editing (from save)
      // Save current state as patch (we were editing the save state)
      await Persistence.writeSavePatch(world);
      // Load pure initial state for editing
      world.loadFrom(Persistence.initialState);
    } else {
      // Switched TO save editing (from initial)
      // Save current state as initial (we were editing the initial state)
      await Persistence.writeInitialState(world);
      // Load initial + patch for editing
      var worldWithPatch = await Persistence.loadSaveWithPatch(savePatchPath);
      if (worldWithPatch != null) {
        world.loadFrom(worldWithPatch.toMap());
      }
    }

    // Clear selections since we've reloaded the world
    _clearSelections();
  }

  /// Clears all entity selections and observer.
  void _clearSelections() {
    selectedEntitiesNotifier.value = {};
    selectedEntityNotifier.value = null;
    observerEntityIdNotifier.value = null;
  }

  /// Finds the Player entity and restores selection, observer, and view to it.
  void _restorePlayerControl() {
    final playerEntity = world.entities().firstWhereOrNull(
          (e) => e.has<Player>(),
        );

    if (playerEntity != null) {
      // Set the view to the player's parent FIRST (room/location)
      // This must be done before setting selectedEntities/observerEntityId because
      // the viewedParentId listener clears those values when the view changes
      final playerParent = playerEntity.get<HasParent>();
      if (playerParent != null) {
        viewedParentIdNotifier.value = playerParent.parentEntityId;
      }
      // Now set the player as the selected/controlled entity
      selectedEntitiesNotifier.value = {playerEntity};
      // Set the player as the vision observer
      observerEntityIdNotifier.value = playerEntity.id;
      _logger.info('restored player control', {'entityId': playerEntity.id});
    } else {
      // No player found, just clear selection
      _clearSelections();
      _logger.warning('no Player entity found to restore control');
    }
  }

  /// Disposes of listeners. Call when the manager is no longer needed.
  void dispose() {
    gameModeNotifier.removeListener(_onGameModeChanged);
    editTargetNotifier.removeListener(_onEditTargetChanged);
  }
}
