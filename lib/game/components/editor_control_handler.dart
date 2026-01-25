import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/app/services/keybinding_service.dart' show KeyBindingService;
import 'package:rogueverse/ecs/components.dart' show Direction, CompassDirection;
import 'package:rogueverse/ecs/entity.dart';

/// Handles keyboard controls specific to editing mode (DEL to delete, Enter to navigate, etc.).
///
/// This component is enabled only in editing mode and handles editor-specific
/// actions like deleting selected entities and navigating into entities.
class EditorControlHandler extends Component with KeyboardHandler {
  final ValueNotifier<Set<Entity>> selectedEntitiesNotifier;
  final ValueNotifier<int?> viewedParentIdNotifier;
  final _logger = Logger("EditorControlHandler");

  /// Whether this handler is enabled. Enabled in editing mode only.
  bool isEnabled = false;

  EditorControlHandler({
    required this.selectedEntitiesNotifier,
    required this.viewedParentIdNotifier,
  });

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

    // Enter to navigate into selected entity (set as viewed parent)
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      final selected = selectedEntitiesNotifier.value.firstOrNull;
      if (selected != null) {
        _logger.info("entering entity ${selected.id}");
        viewedParentIdNotifier.value = selected.id;
        return false;
      }
    }

    // SHIFT+WASD to change direction of selected entities
    final keybindings = KeyBindingService.instance;
    CompassDirection? newDirection;
    if (keybindings.matches('direction.up', keysPressed)) {
      newDirection = CompassDirection.north;
    } else if (keybindings.matches('direction.down', keysPressed)) {
      newDirection = CompassDirection.south;
    } else if (keybindings.matches('direction.left', keysPressed)) {
      newDirection = CompassDirection.west;
    } else if (keybindings.matches('direction.right', keysPressed)) {
      newDirection = CompassDirection.east;
    }

    if (newDirection != null) {
      final selected = selectedEntitiesNotifier.value;
      if (selected.isNotEmpty) {
        for (final entity in selected) {
          final current = entity.get<Direction>();
          entity.upsert(Direction(newDirection, allowDiagonal: current?.allowDiagonal ?? false));
        }
        _logger.info('set direction to $newDirection for ${selected.length} entities');
        return false; // Consumed
      }
    }

    return true;
  }
}
