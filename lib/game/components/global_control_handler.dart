import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/app/widgets/overlays/unified_editor_panel.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/game/game_area.dart';

/// Handles global gameplay controls (Space to advance tick, ESC to deselect/release control).
///
/// This component listens to keyboard input for gameplay-level actions.
/// Enabled in gameplay mode, disabled in editing mode.
class GlobalControlHandler extends PositionComponent with KeyboardHandler {
  final ValueNotifier<Set<Entity>> selectedEntityNotifier;
  final _keybindings = KeyBindingService.instance;
  final _logger = Logger("GlobalControlHandler");

  /// Whether this handler is enabled. Disabled in editing mode.
  bool isEnabled = true;

  GlobalControlHandler({required this.selectedEntityNotifier});

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Handle both initial key press and key repeat (for continuous actions while holding)
    if (!isEnabled || (event is! KeyDownEvent && event is! KeyRepeatEvent)) return true;

    final game = (parent?.findGame() as GameArea);

    _logger.fine("key event: logicalKey=${event.logicalKey.debugName}");

    // Wait action (formerly advance tick - now queues a "do nothing" intent)
    if (_keybindings.matches('game.advanceTick', keysPressed)) {
      final selected = selectedEntityNotifier.value;
      if (selected.isNotEmpty) {
        _logger.info("setting wait intent");
        selected.first.setIntent(WaitIntent());
      }
      return false;
    }

    // Deselect/release control action
    // TODO: Reconsider Esc behavior - should probably open a pause/menu overlay
    // (save game, exit, settings, etc.) rather than releasing control. The current
    // "release control" behavior may not be intuitive. For now, Esc does nothing
    // in gameplay mode unless actively controlling another entity.
    if (_keybindings.matches('game.deselect', keysPressed)) {
      _logger.info("deselect pressed");
      final selected = selectedEntityNotifier.value;

      if (selected.isNotEmpty) {
        // Check if any selected entity is being controlled by someone
        final world = game.currentWorld;
        final controllingMap = world.get<Controlling>();
        final firstSelected = selected.first;

        for (final controlling in controllingMap.values) {
          if (controlling.controlledEntityId == firstSelected.id) {
            // This entity is being controlled - release it
            _logger.info("releasing control of entity ${firstSelected.id}");
            firstSelected.setIntent(ReleasesControlIntent());
            return false;
          }
        }

        // In gameplay mode, don't deselect the player - Esc only releases control
        // Deselection only makes sense in editing mode for stopping entity inspection
        if (game.gameMode.value == GameMode.gameplay) {
          _logger.info("in gameplay mode, not deselecting");
          return false;
        }

        // Not being controlled and in editing mode - deselect entities
        _logger.info("deselecting entities");
        selectedEntityNotifier.value = {};
        game.observerEntityId.value = null;
        game.overlays.remove(UnifiedEditorPanel.overlayName);
        return false;
      }
    }

    _logger.info("not handling event");
    return true;
  }
}
