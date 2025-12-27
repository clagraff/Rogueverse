import 'package:flutter/services.dart';

/// Generic key binding map for mapping keyboard input to actions.
/// This will eventually support dynamic/configurable keybindings.
class KeyBindingMap<T> {
  final Map<Set<LogicalKeyboardKey>, T> _bindings = {};

  void bind(T action, List<LogicalKeyboardKey> keys) {
    _bindings[{...keys}] = action;
  }

  /// Tries to resolve the current keypress set to a mapped action.
  T? resolve(
      Set<LogicalKeyboardKey> keysPressed, LogicalKeyboardKey latestKey) {
    for (final entry in _bindings.entries) {
      if (entry.key.length == keysPressed.length &&
          entry.key.containsAll(keysPressed)) {
        return entry.value;
      }
    }
    return null;
  }
}

/// Movement directions for WASD controls
enum Movement { up, right, down, left }

/// Global keybinding for movement controls
final movementControls = KeyBindingMap<Movement>()
  ..bind(Movement.left, [LogicalKeyboardKey.keyA])
  ..bind(Movement.right, [LogicalKeyboardKey.keyD])
  ..bind(Movement.up, [LogicalKeyboardKey.keyW])
  ..bind(Movement.down, [LogicalKeyboardKey.keyS]);

/// Actions that can be performed on entities
enum EntityAction { interact }

/// Global keybinding for entity action controls
final entityActionControls = KeyBindingMap<EntityAction>()
  ..bind(EntityAction.interact, [LogicalKeyboardKey.keyE]);

/// Inventory-related controls
enum InventoryAction { toggleInventory }

/// Global keybinding for inventory controls
final inventoryControls = KeyBindingMap<InventoryAction>()
  ..bind(InventoryAction.toggleInventory, [LogicalKeyboardKey.tab]);

/// Global game controls
enum GameAction { advanceTick, toggleInspector, deselectEntity }

/// Global keybinding for game-level controls
final gameControls = KeyBindingMap<GameAction>()
  ..bind(GameAction.advanceTick, [LogicalKeyboardKey.space])
  ..bind(GameAction.toggleInspector,
      [LogicalKeyboardKey.control, LogicalKeyboardKey.keyE])
  ..bind(GameAction.deselectEntity, [LogicalKeyboardKey.escape]);
