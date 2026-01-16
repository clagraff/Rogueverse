import 'package:flame/components.dart' hide World;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/components.dart' hide Component;
import 'package:rogueverse/ecs/dialog/dialog.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/game_area.dart';

/// State for the dialog overlay.
class DialogState {
  /// The player entity.
  final Entity player;

  /// The NPC entity being talked to.
  final Entity npc;

  /// The NPC's name (from Name component or fallback).
  final String npcName;

  /// Current position in the dialog tree.
  final DialogNode currentNode;

  /// The current result (what to display).
  final DialogResult result;

  /// Selected choice index in the UI.
  int selectedIndex;

  DialogState({
    required this.player,
    required this.npc,
    required this.npcName,
    required this.currentNode,
    required this.result,
    this.selectedIndex = 0,
  });

  /// Creates a copy with updated fields.
  DialogState copyWith({
    DialogNode? currentNode,
    DialogResult? result,
    int? selectedIndex,
  }) {
    return DialogState(
      player: player,
      npc: npc,
      npcName: npcName,
      currentNode: currentNode ?? this.currentNode,
      result: result ?? this.result,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

/// Handles dialog interactions with NPCs.
///
/// When a dialog is started, this component:
/// 1. Shows the dialog overlay
/// 2. Handles keyboard navigation through choices
/// 3. Executes effects when choices are made
/// 4. Closes the dialog when ended or dismissed
class DialogControlHandler extends PositionComponent with KeyboardHandler {
  final ValueNotifier<Entity?> selectedEntityNotifier;
  final World world;
  final _logger = Logger('DialogControlHandler');

  /// Whether this handler is enabled. Disabled in editing mode.
  bool isEnabled = true;

  /// Current dialog state for the overlay.
  final ValueNotifier<DialogState?> dialogState = ValueNotifier(null);

  DialogControlHandler({
    required this.selectedEntityNotifier,
    required this.world,
  });

  /// Starts a dialog with an NPC entity.
  ///
  /// The NPC must have a Dialog component.
  void startDialog(Entity npcEntity) {
    final playerEntity = selectedEntityNotifier.value;
    if (playerEntity == null) {
      _logger.warning('No player entity selected');
      return;
    }

    final dialogComponent = npcEntity.get<Dialog>();
    if (dialogComponent == null) {
      _logger.warning('NPC has no Dialog component');
      return;
    }

    // Reset the dialog tree to start fresh
    dialogComponent.root.reset();

    // Get NPC name
    final npcName = npcEntity.get<Name>()?.name ?? 'Unknown';

    // Advance to get the first result
    final result = dialogComponent.root.advance(playerEntity, npcEntity);

    // Check if dialog ended immediately
    if (result is DialogEnded) {
      _logger.info('Dialog ended immediately');
      return;
    }

    // Set up dialog state
    dialogState.value = DialogState(
      player: playerEntity,
      npc: npcEntity,
      npcName: npcName,
      currentNode: dialogComponent.root,
      result: result,
    );

    // Show the overlay
    final game = findGame() as GameArea?;
    if (game != null) {
      game.overlays.add('dialogOverlay');
    }
  }

  /// Selects a choice by index.
  void selectChoice(int choiceIndex) {
    final state = dialogState.value;
    if (state == null) return;

    final result = state.result;
    if (result is! DialogAwaitingChoice) return;

    // Find the choice in the result
    if (choiceIndex < 0 || choiceIndex >= result.choices.length) return;
    final choice = result.choices[choiceIndex];

    // Skip unavailable choices
    if (!choice.isAvailable) return;

    // Handle "(done)" option
    if (choice.choiceIndex == -1) {
      endDialog();
      return;
    }

    // Get the next node
    final nextNode = state.currentNode.selectChoice(choice.choiceIndex);
    if (nextNode == null) {
      endDialog();
      return;
    }

    // Advance the dialog
    final nextResult = nextNode.advance(state.player, state.npc);

    // Check if dialog ended
    if (nextResult is DialogEnded) {
      endDialog();
      return;
    }

    // Update state
    dialogState.value = state.copyWith(
      currentNode: nextNode,
      result: nextResult,
      selectedIndex: 0,
    );
  }

  /// Ends the dialog and closes the overlay.
  void endDialog() {
    dialogState.value = null;

    final game = findGame() as GameArea?;
    if (game != null) {
      game.overlays.remove('dialogOverlay');
    }
  }

  /// Moves selection up.
  void moveSelectionUp() {
    final state = dialogState.value;
    if (state == null) return;

    final result = state.result;
    if (result is! DialogAwaitingChoice) return;

    final newIndex = (state.selectedIndex - 1).clamp(0, result.choices.length - 1);
    dialogState.value = state.copyWith(selectedIndex: newIndex);
  }

  /// Moves selection down.
  void moveSelectionDown() {
    final state = dialogState.value;
    if (state == null) return;

    final result = state.result;
    if (result is! DialogAwaitingChoice) return;

    final newIndex = (state.selectedIndex + 1).clamp(0, result.choices.length - 1);
    dialogState.value = state.copyWith(selectedIndex: newIndex);
  }

  /// Confirms the current selection.
  void confirmSelection() {
    final state = dialogState.value;
    if (state == null) return;

    selectChoice(state.selectedIndex);
  }

  /// Whether a dialog is currently active.
  bool get isDialogActive => dialogState.value != null;

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!isEnabled || event is! KeyDownEvent) return true;

    // Only handle keys when dialog is active
    if (!isDialogActive) return true;

    final key = event.logicalKey;

    // Escape - close dialog
    if (key == LogicalKeyboardKey.escape) {
      endDialog();
      return false;
    }

    // Navigation
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
      moveSelectionUp();
      return false;
    }

    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS) {
      moveSelectionDown();
      return false;
    }

    // Selection
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.keyE) {
      confirmSelection();
      return false;
    }

    // Number keys for quick selection (1-9)
    final numberKeys = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.digit6,
      LogicalKeyboardKey.digit7,
      LogicalKeyboardKey.digit8,
      LogicalKeyboardKey.digit9,
    ];

    final keyIndex = numberKeys.indexOf(key);
    if (keyIndex != -1) {
      selectChoice(keyIndex);
      return false;
    }

    return true;
  }
}
