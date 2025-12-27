import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/game/game_area.dart';

/// Handles global game controls (Space to advance tick, Ctrl+E for inspector) that work regardless of entity selection.
///
/// This component listens to keyboard input for game-level actions that should always be
/// available, such as advancing the game tick and toggling the inspector panel.
class GlobalControlHandler extends PositionComponent with KeyboardHandler {
  final ValueNotifier<Entity?> selectedEntityNotifier;

  GlobalControlHandler({required this.selectedEntityNotifier});

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) return true;

    final game = (parent?.findGame() as GameArea);
    final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;

    Logger("GlobalControlHandler")
        .info("Key event: ${event.logicalKey}, isCtrl: $isCtrlPressed");

    // Space - advance tick
    if (event.logicalKey == LogicalKeyboardKey.space && !isCtrlPressed) {
      Logger("GlobalControlHandler").info("Advancing tick");
      game.tickEcs();
      return false;
    }

    // Ctrl+E - toggle inspector
    if (event.logicalKey == LogicalKeyboardKey.keyE && isCtrlPressed) {
      Logger("GlobalControlHandler").info("Toggling inspector");
      if (selectedEntityNotifier.value != null) {
        if (game.overlays.isActive('inspectorPanel')) {
          game.overlays.remove('inspectorPanel');
        } else {
          game.overlays.add('inspectorPanel');
        }
      }
      return false;
    }

    // Esc - deselect entity
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Logger("GlobalControlHandler").info("Deselecting entity");
      if (selectedEntityNotifier.value != null) {
        selectedEntityNotifier.value = null;
        game.observerEntityId.value = null;
        game.overlays.remove('inspectorPanel');
        return false;
      }
    }

    return true;
  }
}
