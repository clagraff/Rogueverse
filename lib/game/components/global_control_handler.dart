import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/components.dart';
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
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
    final isAltPressed = HardwareKeyboard.instance.isAltPressed;

    Logger("GlobalControlHandler").info("key event: logicalKey=${event.logicalKey.debugName} isCtrl=$isCtrlPressed isAltPRessed=$isAltPressed isShiftPressed=$isShiftPressed");

    // Space - advance tick
    if (event.logicalKey == LogicalKeyboardKey.space && !isCtrlPressed) {
      Logger("GlobalControlHandler").info("advancing tick");
      game.tickEcs();
      return false;
    }

    // Ctrl+E - toggle inspector
    if (event.logicalKey == LogicalKeyboardKey.keyE && isCtrlPressed) {
      Logger("GlobalControlHandler").info("toggling inspector");
      if (selectedEntityNotifier.value != null) {
        if (game.overlays.isActive('inspectorPanel')) {
          game.overlays.remove('inspectorPanel');
        } else {
          game.overlays.add('inspectorPanel');
        }
      }
      return false;
    }

    // Esc - release control or deselect entity
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Logger("GlobalControlHandler").info("escape pressed");
      final selected = selectedEntityNotifier.value;
      
      if (selected != null) {
        // Check if this entity is being controlled by someone
        final world = game.currentWorld;
        final controllingMap = world.get<Controlling>();
        
        for (final controlling in controllingMap.values) {
          if (controlling.controlledEntityId == selected.id) {
            // This entity is being controlled - release it
            Logger("GlobalControlHandler").info("releasing control of entity ${selected.id}");
            selected.upsert(ReleasesControlIntent());
            return false;
          }
        }
        
        // Not being controlled - deselect entity
        Logger("GlobalControlHandler").info("deselecting entity");
        selectedEntityNotifier.value = null;
        game.observerEntityId.value = null;
        game.overlays.remove('inspectorPanel');
        return false;
      }
    }

    // // D - Dock
    // if (event.logicalKey == LogicalKeyboardKey.keyD && !isCtrlPressed) {
    //   Logger("GlobalControlHandler").info("dock pressed");
    //   final selected = selectedEntityNotifier.value;
    //   if (selected != null) {
    //     Logger("GlobalControlHandler").info("docking entity ${selected.id}");
    //     selected.upsert(DockIntent());
    //     return false;
    //   }
    // }
    //
    // // U - Undock
    // if (event.logicalKey == LogicalKeyboardKey.keyU && !isCtrlPressed) {
    //   Logger("GlobalControlHandler").info("undock pressed");
    //   final selected = selectedEntityNotifier.value;
    //   if (selected != null) {
    //     Logger("GlobalControlHandler").info("undocking entity ${selected.id}");
    //     selected.upsert(UndockIntent());
    //     return false;
    //   }
    // }

    Logger("GlobalControlHandler").info("not handling event");
    return true;
  }
}
