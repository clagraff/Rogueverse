import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

/// A Flame component that listens for Ctrl+T to toggle the template panel overlay.
///
/// This allows users to open/close the entity template panel from the game world.
class TemplatePanelToggle extends Component with KeyboardHandler {
  static const String overlayName = 'templatePanel';

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      Logger("TemplatePanelToggle")
          .info("Key event: ${event.logicalKey}, pressed: $keysPressed");
    }

    // Check for Ctrl+T key combination
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.keyT &&
        (keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
            keysPressed.contains(LogicalKeyboardKey.controlRight))) {
      Logger("TemplatePanelToggle").info("Handling Ctrl+T");
      final game = findGame();
      if (game != null) {
        // Toggle the template panel overlay
        if (game.overlays.isActive(overlayName)) {
          game.overlays.remove(overlayName);
        } else {
          game.overlays.add(overlayName);
        }
      }
      return false; // Event handled
    }

    return true; // Event not handled, pass to other handlers
  }
}
