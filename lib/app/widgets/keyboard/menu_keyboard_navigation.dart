import 'package:flutter/services.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';

/// Helper for keyboard navigation using configurable menu.* keybindings.
///
/// Handles list/grid navigation with WASD/arrows, selection, and back/close.
/// Supports both 1D lists and 2D grids via the [columnCount] parameter.
///
/// Usage:
/// ```dart
/// final nav = MenuKeyboardNavigation(
///   itemCount: items.length,
///   selectedIndex: _selectedIndex,
///   onIndexChanged: (i) => setState(() => _selectedIndex = i),
///   onActivate: () => _activateItem(_selectedIndex),
///   onBack: () => Navigator.pop(context),
/// );
///
/// if (nav.handleKeyEvent(event)) return; // Key was handled
/// ```
class MenuKeyboardNavigation {
  /// Total number of items.
  final int itemCount;

  /// Currently selected index.
  final int selectedIndex;

  /// Callback when the index changes.
  final void Function(int) onIndexChanged;

  /// Callback when the user activates/selects the current item (E/Enter/Space).
  final void Function() onActivate;

  /// Callback when the user presses back/close (Escape).
  final void Function()? onBack;

  /// For grid navigation: number of columns. If null, treats as 1D list.
  final int? columnCount;

  /// Callback when the user presses delete.
  final void Function()? onDelete;

  /// Callback for left navigation (used for tree collapse).
  final void Function()? onLeft;

  /// Callback for right navigation (used for tree expand).
  final void Function()? onRight;

  MenuKeyboardNavigation({
    required this.itemCount,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.onActivate,
    this.onBack,
    this.columnCount,
    this.onDelete,
    this.onLeft,
    this.onRight,
  });

  /// Hard-coded number keys for quick selection (1-9).
  static const _numberKeys = [
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6,
    LogicalKeyboardKey.digit7,
    LogicalKeyboardKey.digit8,
    LogicalKeyboardKey.digit9,
  ];

  /// Returns true if the key event was handled.
  bool handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (itemCount == 0) {
      // Still handle back even with no items
      if (_matchesBack(event.logicalKey)) {
        onBack?.call();
        return true;
      }
      return false;
    }

    final key = event.logicalKey;
    final keybindings = KeyBindingService.instance;

    // Back/Close (Escape or menu.back)
    if (_matchesBack(key)) {
      onBack?.call();
      return true;
    }

    // Delete
    if (key == LogicalKeyboardKey.delete || key == LogicalKeyboardKey.backspace) {
      onDelete?.call();
      return true;
    }

    // Grid navigation
    if (columnCount != null) {
      return _handleGridNavigation(key, keybindings);
    }

    // List navigation
    return _handleListNavigation(key, keybindings);
  }

  bool _matchesBack(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.escape ||
        KeyBindingService.instance.matches('menu.back', {key});
  }

  bool _handleListNavigation(LogicalKeyboardKey key, KeyBindingService keybindings) {
    // Navigate up (W, ArrowUp, or menu.up)
    if (_matchesUp(key, keybindings)) {
      final newIndex = (selectedIndex - 1).clamp(0, itemCount - 1);
      if (newIndex != selectedIndex) {
        onIndexChanged(newIndex);
      }
      return true;
    }

    // Navigate down (S, ArrowDown, or menu.down)
    if (_matchesDown(key, keybindings)) {
      final newIndex = (selectedIndex + 1).clamp(0, itemCount - 1);
      if (newIndex != selectedIndex) {
        onIndexChanged(newIndex);
      }
      return true;
    }

    // Left (for tree collapse)
    if (_matchesLeft(key, keybindings)) {
      onLeft?.call();
      return true;
    }

    // Right (for tree expand)
    if (_matchesRight(key, keybindings)) {
      onRight?.call();
      return true;
    }

    // Activate/Select (E, Enter, Space, or menu.select)
    if (_matchesSelect(key, keybindings)) {
      onActivate();
      return true;
    }

    // Quick select 1-9
    final numberIndex = _numberKeys.indexOf(key);
    if (numberIndex != -1 && numberIndex < itemCount) {
      onIndexChanged(numberIndex);
      onActivate();
      return true;
    }

    return false;
  }

  bool _handleGridNavigation(LogicalKeyboardKey key, KeyBindingService keybindings) {
    final cols = columnCount!;
    final row = selectedIndex ~/ cols;
    final col = selectedIndex % cols;
    final rowCount = (itemCount / cols).ceil();

    // Navigate up
    if (_matchesUp(key, keybindings)) {
      if (row > 0) {
        final newIndex = ((row - 1) * cols + col).clamp(0, itemCount - 1);
        onIndexChanged(newIndex);
      }
      return true;
    }

    // Navigate down
    if (_matchesDown(key, keybindings)) {
      if (row < rowCount - 1) {
        final newIndex = ((row + 1) * cols + col).clamp(0, itemCount - 1);
        onIndexChanged(newIndex);
      }
      return true;
    }

    // Navigate left
    if (_matchesLeft(key, keybindings)) {
      if (col > 0) {
        final newIndex = selectedIndex - 1;
        onIndexChanged(newIndex);
      }
      return true;
    }

    // Navigate right
    if (_matchesRight(key, keybindings)) {
      if (col < cols - 1 && selectedIndex < itemCount - 1) {
        final newIndex = selectedIndex + 1;
        onIndexChanged(newIndex);
      }
      return true;
    }

    // Activate/Select
    if (_matchesSelect(key, keybindings)) {
      onActivate();
      return true;
    }

    // Quick select 1-9
    final numberIndex = _numberKeys.indexOf(key);
    if (numberIndex != -1 && numberIndex < itemCount) {
      onIndexChanged(numberIndex);
      onActivate();
      return true;
    }

    return false;
  }

  bool _matchesUp(LogicalKeyboardKey key, KeyBindingService keybindings) {
    return key == LogicalKeyboardKey.arrowUp ||
        keybindings.matches('menu.up', {key});
  }

  bool _matchesDown(LogicalKeyboardKey key, KeyBindingService keybindings) {
    return key == LogicalKeyboardKey.arrowDown ||
        keybindings.matches('menu.down', {key});
  }

  bool _matchesLeft(LogicalKeyboardKey key, KeyBindingService keybindings) {
    return key == LogicalKeyboardKey.arrowLeft ||
        keybindings.matches('menu.left', {key});
  }

  bool _matchesRight(LogicalKeyboardKey key, KeyBindingService keybindings) {
    return key == LogicalKeyboardKey.arrowRight ||
        keybindings.matches('menu.right', {key});
  }

  bool _matchesSelect(LogicalKeyboardKey key, KeyBindingService keybindings) {
    return key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        keybindings.matches('menu.select', {key});
  }
}
