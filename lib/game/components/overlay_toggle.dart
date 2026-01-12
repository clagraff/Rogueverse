import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';

/// A reusable Flame component that toggles an overlay when its keybinding is pressed.
///
/// This component listens for the key combination defined in KeyBindingService
/// and toggles the visibility of the specified overlay. When the overlay is closed,
/// focus is returned to the game area.
///
/// Example usage:
/// ```dart
/// add(OverlayToggle(
///   overlayName: UnifiedEditorPanel.overlayName,
///   action: 'overlay.editor',
///   gameFocusNode: gameFocusNode,
/// ));
/// ```
class OverlayToggle extends Component with KeyboardHandler {
  /// The name of the overlay to toggle (must match the overlay registered in GameWidget).
  final String overlayName;

  /// The action name in KeyBindingService (e.g., 'overlay.editor').
  final String action;

  /// The game area's focus node - focus is returned here when overlay closes.
  final FocusNode gameFocusNode;

  OverlayToggle({
    required this.overlayName,
    required this.action,
    required this.gameFocusNode,
  });

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) {
      return true;
    }

    // Check if current keys match the action's keybinding
    if (!KeyBindingService.instance.matches(action, keysPressed)) {
      return true;
    }

    final game = findGame();
    if (game != null) {
      final wasActive = game.overlays.isActive(overlayName);
      game.overlays.toggle(overlayName);

      // When closing the overlay, return focus to game area
      if (wasActive) {
        gameFocusNode.requestFocus();
      }
    }

    return false;
  }
}
