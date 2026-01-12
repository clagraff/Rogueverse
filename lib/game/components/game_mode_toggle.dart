import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/app/widgets/overlays/unified_editor_panel.dart';
import 'package:rogueverse/ecs/components.dart' show Name, HasParent;
import 'package:rogueverse/game/game_area.dart';

/// A Flame component that toggles between gameplay and editing modes.
///
/// This component listens for the game.toggleMode keybinding (Ctrl+`) and
/// switches the game mode. When entering editing mode, it shows the editor panel.
/// When entering gameplay mode, it hides the editor panel and restores player control.
class GameModeToggle extends Component with KeyboardHandler {
  final _logger = Logger('GameModeToggle');
  final _keybindings = KeyBindingService.instance;

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) {
      return true;
    }

    if (!_keybindings.matches('game.toggleMode', keysPressed)) {
      return true;
    }

    final game = findGame() as GameArea?;
    if (game == null) return true;

    // Toggle the mode
    if (game.gameMode.value == GameMode.gameplay) {
      _logger.info('switching to editing mode');
      game.gameMode.value = GameMode.editing;
      // Show editor panel when entering editing mode
      if (!game.overlays.isActive(UnifiedEditorPanel.overlayName)) {
        game.overlays.add(UnifiedEditorPanel.overlayName);
      }
    } else {
      _logger.info('switching to gameplay mode');
      game.gameMode.value = GameMode.gameplay;
      // Hide editor panel when entering gameplay mode
      game.overlays.remove(UnifiedEditorPanel.overlayName);

      // Restore player control - find Player entity and reset all notifiers
      _restorePlayerControl(game);
    }

    return false;
  }

  /// Finds the Player entity and restores selection, observer, and view to it.
  void _restorePlayerControl(GameArea game) {
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
      _logger.info('Restored player control: entity ${playerEntity.id}');
    } else {
      // No player found, just clear selection
      game.selectedEntities.value = {};
      game.observerEntityId.value = null;
      _logger.warning('No Player entity found to restore control');
    }
  }
}
