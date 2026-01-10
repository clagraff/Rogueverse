import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/game/game_area.dart';

/// Handles global game controls (Space to advance tick, ESC to deselect) that work regardless of entity selection.
///
/// This component listens to keyboard input for game-level actions that should always be
/// available, such as advancing the game tick and deselecting entities.
class GlobalControlHandler extends PositionComponent with KeyboardHandler {
  final ValueNotifier<Entity?> selectedEntityNotifier;
  final _keybindings = KeyBindingService.instance;

  GlobalControlHandler({required this.selectedEntityNotifier});

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) return true;

    final game = (parent?.findGame() as GameArea);

    Logger("GlobalControlHandler").info("key event: logicalKey=${event.logicalKey.debugName}");

    // Advance tick action
    if (_keybindings.matches('game.advanceTick', keysPressed)) {
      Logger("GlobalControlHandler").info("advancing tick");
      game.tickEcs();
      return false;
    }

    // Deselect/release control action
    if (_keybindings.matches('game.deselect', keysPressed)) {
      Logger("GlobalControlHandler").info("deselect pressed");
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
        game.overlays.remove('editorPanel');
        return false;
      }
    }

    Logger("GlobalControlHandler").info("not handling event");
    return true;
  }
}
