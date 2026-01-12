import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/app/widgets/overlays/unified_editor_panel.dart';
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

  /// Whether this handler is enabled. Disabled in editing mode.
  bool isEnabled = true;

  GlobalControlHandler({required this.selectedEntityNotifier});

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!isEnabled || event is! KeyDownEvent) return true;

    final game = (parent?.findGame() as GameArea);

    Logger("GlobalControlHandler").info("key event: logicalKey=${event.logicalKey.debugName}");

    // Advance tick action
    if (_keybindings.matches('game.advanceTick', keysPressed)) {
      Logger("GlobalControlHandler").info("advancing tick");
      game.tickEcs();
      return false;
    }

    // Deselect/release control action
    // TODO: Reconsider Esc behavior - should probably open a pause/menu overlay
    // (save game, exit, settings, etc.) rather than releasing control. The current
    // "release control" behavior may not be intuitive. For now, Esc does nothing
    // in gameplay mode unless actively controlling another entity.
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

        // In gameplay mode, don't deselect the player - Esc only releases control
        // Deselection only makes sense in editing mode for stopping entity inspection
        if (game.gameMode.value == GameMode.gameplay) {
          Logger("GlobalControlHandler").info("in gameplay mode, not deselecting");
          return false;
        }

        // Not being controlled and in editing mode - deselect entity
        Logger("GlobalControlHandler").info("deselecting entity");
        selectedEntityNotifier.value = null;
        game.observerEntityId.value = null;
        game.overlays.remove(UnifiedEditorPanel.overlayName);
        return false;
      }
    }

    Logger("GlobalControlHandler").info("not handling event");
    return true;
  }
}
