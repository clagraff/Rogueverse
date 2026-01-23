import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/app/widgets/keyboard/auto_focus_keyboard_listener.dart';

/// A confirmation dialog with keyboard navigation support.
///
/// Supports arrow keys/WASD navigation between actions, Enter/E to confirm,
/// and Escape to cancel.
///
/// Usage:
/// ```dart
/// final confirmed = await ConfirmationDialog.show(
///   context: context,
///   title: 'Delete Item',
///   message: 'Are you sure?',
///   confirmLabel: 'Delete',
///   isDestructive: true,
/// );
/// ```
class ConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
  });

  /// Shows the dialog and returns true if confirmed, false otherwise.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  bool _confirmSelected = false;

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    final keybindings = KeyBindingService.instance;

    // Navigate between buttons (any direction key toggles)
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown ||
        keybindings.matches('menu.left', {key}) ||
        keybindings.matches('menu.right', {key}) ||
        keybindings.matches('menu.up', {key}) ||
        keybindings.matches('menu.down', {key})) {
      setState(() => _confirmSelected = !_confirmSelected);
    }
    // Confirm selection
    else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        keybindings.matches('menu.select', {key})) {
      Navigator.of(context).pop(_confirmSelected);
    }
    // Cancel
    else if (key == LogicalKeyboardKey.escape ||
        keybindings.matches('menu.back', {key})) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final destructiveColor = colorScheme.error;

    return AutoFocusKeyboardListener(
      onKeyEvent: _handleKeyEvent,
      child: AlertDialog(
        title: Text(widget.title),
        content: Text(widget.message),
        actions: [
          _DialogButton(
            label: widget.cancelLabel,
            isSelected: !_confirmSelected,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          _DialogButton(
            label: widget.confirmLabel,
            isSelected: _confirmSelected,
            color: widget.isDestructive ? destructiveColor : null,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onPressed;

  const _DialogButton({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonColor = color ?? colorScheme.primary;

    if (isSelected) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(backgroundColor: buttonColor),
        child: Text(label),
      );
    } else {
      return TextButton(
        onPressed: onPressed,
        style: color != null
            ? TextButton.styleFrom(foregroundColor: color)
            : null,
        child: Text(label),
      );
    }
  }
}
