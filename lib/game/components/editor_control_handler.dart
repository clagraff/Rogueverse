import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/entity.dart';

/// Handles keyboard controls specific to editing mode (DEL to delete, etc.).
///
/// This component is enabled only in editing mode and handles editor-specific
/// actions like deleting selected entities.
class EditorControlHandler extends Component with KeyboardHandler {
  final ValueNotifier<Set<Entity>> selectedEntitiesNotifier;
  final _logger = Logger("EditorControlHandler");

  /// Whether this handler is enabled. Enabled in editing mode only.
  bool isEnabled = false;

  EditorControlHandler({required this.selectedEntitiesNotifier});

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!isEnabled || event is! KeyDownEvent) return true;

    // Delete selected entities
    if (event.logicalKey == LogicalKeyboardKey.delete ||
        event.logicalKey == LogicalKeyboardKey.backspace) {
      final selected = selectedEntitiesNotifier.value;
      if (selected.isNotEmpty) {
        _logger.info("deleting ${selected.length} entities");
        for (final entity in selected.toList()) {
          entity.destroy();
        }
        selectedEntitiesNotifier.value = {};
        return false;
      } else {
        _logger.fine("DEL pressed but no entities selected");
      }
    }

    return true;
  }
}
