import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';

/// Dialog for capturing a key combination.
///
/// Creates an isolated focus scope, solving the parent KeyboardListener
/// focus conflict issue.
class _KeyCaptureDialog extends StatefulWidget {
  final String actionLabel;
  const _KeyCaptureDialog({required this.actionLabel});

  @override
  State<_KeyCaptureDialog> createState() => _KeyCaptureDialogState();
}

class _KeyCaptureDialogState extends State<_KeyCaptureDialog> {
  final FocusNode _focusNode = FocusNode();
  List<LogicalKeyboardKey> _heldKeys = [];

  static final _modifierKeys = {
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop(null);
      return;
    }

    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed
        .where((k) => k != LogicalKeyboardKey.escape && k != LogicalKeyboardKey.tab)
        .toList();

    setState(() => _heldKeys = keysPressed);

    if (event is KeyDownEvent && !_modifierKeys.contains(event.logicalKey)) {
      if (keysPressed.isNotEmpty) {
        Navigator.of(context).pop(KeyCombo.fromKeys(keysPressed));
      }
    }
  }

  String _getDisplayText() {
    if (_heldKeys.isEmpty) return 'Press a key...';
    final combo = KeyCombo.fromKeys(_heldKeys);
    final display = combo.toDisplayString();
    final hasOnlyModifiers = _heldKeys.every(_modifierKeys.contains);
    return hasOnlyModifiers ? '$display+...' : display;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text('Rebind: ${widget.actionLabel}'),
      content: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKey,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getDisplayText(),
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'monospace',
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Reusable keybindings editor widget.
///
/// Displays keybindings organized by category with the ability to rebind keys.
/// Used by both the main menu settings and the in-game character screen.
class KeybindingsEditor extends StatefulWidget {
  const KeybindingsEditor({super.key});

  @override
  State<KeybindingsEditor> createState() => _KeybindingsEditorState();
}

class _KeybindingsEditorState extends State<KeybindingsEditor> {
  final _keybindings = KeyBindingService.instance;

  /// Categories and their action prefixes.
  static const _categories = [
    ('Movement', 'movement.'),
    ('Direction', 'direction.'),
    ('Strafe', 'strafe.'),
    ('Actions', 'entity.'),
    ('UI', ['inventory.toggle', 'ui.tab_prev', 'ui.tab_next']),
    ('Game', 'game.'),
    ('Camera', 'camera.'),
    ('Overlays', 'overlay.'),
    ('Menu', 'menu.'),
  ];

  /// Human-readable names for actions.
  static const _actionLabels = {
    'movement.up': 'Move Up',
    'movement.down': 'Move Down',
    'movement.left': 'Move Left',
    'movement.right': 'Move Right',
    'direction.up': 'Face Up',
    'direction.down': 'Face Down',
    'direction.left': 'Face Left',
    'direction.right': 'Face Right',
    'strafe.up': 'Strafe Up',
    'strafe.down': 'Strafe Down',
    'strafe.left': 'Strafe Left',
    'strafe.right': 'Strafe Right',
    'entity.interact': 'Interact',
    'inventory.toggle': 'Character Screen',
    'ui.tab_prev': 'Previous Tab',
    'ui.tab_next': 'Next Tab',
    'game.advanceTick': 'Wait/Advance',
    'game.deselect': 'Deselect/Close',
    'game.toggleMode': 'Toggle Edit Mode',
    'camera.toggleFollow': 'Toggle Camera Follow',
    'overlay.editor': 'Open Editor',
    'overlay.templates': 'Open Templates',
    'menu.up': 'Navigate Up',
    'menu.down': 'Navigate Down',
    'menu.left': 'Navigate Left',
    'menu.right': 'Navigate Right',
    'menu.select': 'Select',
    'menu.back': 'Back/Close',
  };

  Future<void> _startRebind(String action) async {
    final result = await showDialog<KeyCombo?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _KeyCaptureDialog(
        actionLabel: _actionLabels[action] ?? action,
      ),
    );

    if (result != null) {
      await _keybindings.rebind(action, result);
      setState(() {});
    }
  }

  Future<void> _resetBinding(String action) async {
    await _keybindings.resetToDefault(action);
    setState(() {});
  }

  Future<void> _resetAllBindings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Keybindings'),
        content: const Text('Are you sure you want to reset all keybindings to their defaults?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _keybindings.resetAllToDefaults();
      setState(() {});
    }
  }

  List<String> _getActionsForCategory(dynamic filter) {
    final allBindings = _keybindings.getAll();

    if (filter is String) {
      // Prefix filter
      return allBindings
          .where((b) => b.action.startsWith(filter))
          .map((b) => b.action)
          .toList();
    } else if (filter is List<String>) {
      // Explicit action list
      return filter.where((action) => _keybindings.getBinding(action) != null).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Reset all button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _resetAllBindings,
                icon: const Icon(Icons.restore, size: 16),
                label: const Text('Reset All'),
              ),
            ],
          ),
        ),

        // Keybindings list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, categoryIndex) {
              final (categoryName, filter) = _categories[categoryIndex];
              final actions = _getActionsForCategory(filter);

              if (actions.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category header
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Action rows
                  ...actions.map((action) => _buildBindingRow(context, action)),

                  // Divider after category (except last)
                  if (categoryIndex < _categories.length - 1)
                    Divider(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      height: 16,
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBindingRow(BuildContext context, String action) {
    final colorScheme = Theme.of(context).colorScheme;
    final binding = _keybindings.getBinding(action);
    final label = _actionLabels[action] ?? action;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Action name
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 13,
              ),
            ),
          ),

          // Key display / rebind button
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => _startRebind(action),
              canRequestFocus: false,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  binding?.combo.toDisplayString() ?? '—',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Reset button
          IconButton(
            onPressed: () => _resetBinding(action),
            icon: const Icon(Icons.restore, size: 16),
            tooltip: 'Reset to default',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
