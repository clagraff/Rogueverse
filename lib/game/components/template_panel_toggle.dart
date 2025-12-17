import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';

/// A Flame component that listens for Ctrl+E to toggle the template panel overlay.
///
/// This allows users to open/close the entity template panel from the game world.
class TemplatePanelToggle extends Component with KeyboardHandler {
  static const String overlayName = 'templatePanel';

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Check for Ctrl+E key combination
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.keyE &&
        keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
        keysPressed.contains(LogicalKeyboardKey.controlRight)) {
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
