import 'package:flame/components.dart' hide World;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/components.dart' hide Component;
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/game_area.dart';

/// Handles dialog interactions with NPCs.
///
/// Uses intent-based flow:
/// - TalkIntent: Start dialog (adds ActiveDialog to player)
/// - DialogAdvanceIntent: Select a choice (advances to next node)
/// - DialogExitIntent: Exit dialog early
///
/// Local UI state (selectedIndex) is kept here for navigation.
/// Actual dialog state is stored in the player's ActiveDialog component.
class DialogControlHandler extends PositionComponent with KeyboardHandler {
  final ValueNotifier<Entity?> selectedEntityNotifier;
  final World world;
  final _logger = Logger('DialogControlHandler');

  /// Whether this handler is enabled. Disabled in editing mode.
  bool isEnabled = true;

  /// Selected choice index for UI highlight (local state, not ECS).
  /// Uses a ValueNotifier so the UI can rebuild when selection changes.
  final ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);

  /// Set of choice IDs that have been selected during this dialog session.
  /// Used to show visited choices in the UI.
  /// Choice IDs are formatted as "${nodeId}_${choiceIndex}".
  final Set<String> selectedChoiceIds = {};

  DialogControlHandler({
    required this.selectedEntityNotifier,
    required this.world,
  });

  /// Starts a dialog with an NPC entity.
  ///
  /// The NPC must have a DialogRef component pointing to a valid dialog node.
  void startDialog(Entity npcEntity) {
    final playerEntity = selectedEntityNotifier.value;
    if (playerEntity == null) {
      _logger.warning('No player entity selected');
      return;
    }

    final dialogRef = npcEntity.get<DialogRef>();
    if (dialogRef == null) {
      _logger.warning('NPC has no DialogRef component');
      return;
    }

    // Use TalkIntent to start dialog (will be processed by DialogSystem)
    playerEntity.upsert(TalkIntent(targetEntityId: npcEntity.id));
    selectedIndexNotifier.value = 0;
    selectedChoiceIds.clear();

    // Show the overlay
    final game = findGame() as GameArea?;
    if (game != null) {
      game.overlays.add('dialogOverlay');
    }
  }

  /// Selects a choice by index.
  void selectChoice(int choiceIndex) {
    final playerEntity = selectedEntityNotifier.value;
    if (playerEntity == null) return;

    final active = playerEntity.get<ActiveDialog>();
    if (active == null) return;

    final nodeEntity = world.getEntity(active.currentNodeId);
    final dialogNode = nodeEntity.get<DialogNode>();
    if (dialogNode == null) return;

    // Validate choice index
    if (choiceIndex < 0 || choiceIndex >= dialogNode.choices.length) return;

    final choice = dialogNode.choices[choiceIndex];

    // Track that this choice was selected (for UI indication)
    final choiceId = '${active.currentNodeId}_$choiceIndex';
    selectedChoiceIds.add(choiceId);

    // Use DialogAdvanceIntent (will be processed by DialogSystem)
    playerEntity.upsert(DialogAdvanceIntent(choiceIndex: choiceIndex));
    selectedIndexNotifier.value = 0;

    // Close overlay if dialog will end
    if (choice.targetNodeId == null) {
      _closeOverlay();
    }
  }

  /// Ends the dialog and closes the overlay.
  void endDialog() {
    final playerEntity = selectedEntityNotifier.value;
    if (playerEntity == null) return;

    // Use DialogExitIntent (will be processed by DialogSystem)
    playerEntity.upsert(DialogExitIntent());
    selectedChoiceIds.clear();

    _closeOverlay();
  }

  void _closeOverlay() {
    final game = findGame() as GameArea?;
    if (game != null) {
      game.overlays.remove('dialogOverlay');
    }
  }

  /// Moves selection up.
  void moveSelectionUp() {
    final playerEntity = selectedEntityNotifier.value;
    if (playerEntity == null) return;

    final active = playerEntity.get<ActiveDialog>();
    if (active == null) return;

    final nodeEntity = world.getEntity(active.currentNodeId);
    final dialogNode = nodeEntity.get<DialogNode>();
    if (dialogNode == null) return;

    final newIndex = (selectedIndexNotifier.value - 1).clamp(0, dialogNode.choices.length - 1);
    selectedIndexNotifier.value = newIndex;
  }

  /// Moves selection down.
  void moveSelectionDown() {
    final playerEntity = selectedEntityNotifier.value;
    if (playerEntity == null) return;

    final active = playerEntity.get<ActiveDialog>();
    if (active == null) return;

    final nodeEntity = world.getEntity(active.currentNodeId);
    final dialogNode = nodeEntity.get<DialogNode>();
    if (dialogNode == null) return;

    final newIndex = (selectedIndexNotifier.value + 1).clamp(0, dialogNode.choices.length - 1);
    selectedIndexNotifier.value = newIndex;
  }

  /// Confirms the current selection.
  void confirmSelection() {
    selectChoice(selectedIndexNotifier.value);
  }

  /// Whether a dialog is currently active.
  bool get isDialogActive {
    final playerEntity = selectedEntityNotifier.value;
    return playerEntity?.get<ActiveDialog>() != null;
  }

  /// Checks if a choice has been previously selected at the given node.
  bool isChoiceVisited(int nodeId, int choiceIndex) {
    return selectedChoiceIds.contains('${nodeId}_$choiceIndex');
  }

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
