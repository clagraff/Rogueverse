import 'package:flame/components.dart';
import 'package:flutter/services.dart';

/// A Flame component that listens for Ctrl+T to toggle the template panel overlay.
///
/// This allows users to open/close the entity template panel from the game world.
class TemplatePanelToggle extends Component with KeyboardHandler {
  static const String overlayName = 'templatePanel';

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is !KeyDownEvent) {
      return true;
    }

    // Check for Ctrl+T key combination
    var ctrlTPressed = event.logicalKey == LogicalKeyboardKey.keyT &&
        (keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
            keysPressed.contains(LogicalKeyboardKey.controlRight));

    if (!ctrlTPressed) {
      return true;
    }


    final game = findGame();
    if (game != null) {
      game.overlays.toggle(overlayName);
    }

    return false;
  }
}
