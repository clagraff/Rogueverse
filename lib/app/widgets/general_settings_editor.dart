import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/app/services/game_settings_service.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';

/// A setting item for keyboard navigation.
class _SettingItem {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
}

/// Editor widget for general game settings.
///
/// Displays toggle switches for various game-wide settings like health bar visibility.
/// Used by both the main menu settings and the in-game character screen.
/// Supports keyboard navigation with W/S and Enter/Space to toggle.
///
/// Focus-based navigation:
/// - When this widget has focus, W/S navigates items, Enter/Space toggles
/// - W at top or Escape returns focus to parentFocusNode
class GeneralSettingsEditor extends StatefulWidget {
  /// Focus node for this widget. If provided externally, caller controls when
  /// this widget receives focus.
  final FocusNode? focusNode;

  /// Parent's focus node. When user presses W at top or Escape, focus returns here.
  final FocusNode? parentFocusNode;

  const GeneralSettingsEditor({
    super.key,
    this.focusNode,
    this.parentFocusNode,
  });

  @override
  State<GeneralSettingsEditor> createState() => _GeneralSettingsEditorState();
}

class _GeneralSettingsEditorState extends State<GeneralSettingsEditor> {
  int _selectedIndex = 0;
  FocusNode? _ownedFocusNode;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void dispose() {
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  List<_SettingItem> _buildSettingItems() {
    return [
      _SettingItem(
        title: 'Always show health bars',
        subtitle: 'Show health bars even when at full health',
        value: GameSettingsService.instance.alwaysShowHealthBars,
        onChanged: (value) =>
            GameSettingsService.instance.setAlwaysShowHealthBars(value),
      ),
    ];
  }

  void _returnToParent() {
    widget.parentFocusNode?.requestFocus();
  }

  void _handleKeyEvent(KeyEvent event, List<_SettingItem> items) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    final keybindings = KeyBindingService.instance;

    // Escape: return focus to parent (go up one level)
    if (key == LogicalKeyboardKey.escape ||
        keybindings.matches('menu.back', {key})) {
      _returnToParent();
      return;
    }

    // W/Up navigation - if at top, exit to parent
    if (key == LogicalKeyboardKey.arrowUp ||
        keybindings.matches('menu.up', {key})) {
      if (_selectedIndex == 0) {
        _returnToParent();
      } else {
        setState(() => _selectedIndex--);
      }
      return;
    }

    // S/Down navigation - move down in list
    if (key == LogicalKeyboardKey.arrowDown ||
        keybindings.matches('menu.down', {key})) {
      if (_selectedIndex < items.length - 1) {
        setState(() => _selectedIndex++);
      }
      return;
    }

    // Enter/Space toggle
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        keybindings.matches('menu.select', {key})) {
      final item = items[_selectedIndex];
      item.onChanged(!item.value);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<int>(
      valueListenable: GameSettingsService.instance.changeNotifier,
      builder: (context, _, __) {
        final items = _buildSettingItems();

        // Ensure selected index is valid
        if (_selectedIndex >= items.length) {
          _selectedIndex = items.length - 1;
        }

        return ListenableBuilder(
          listenable: _effectiveFocusNode,
          builder: (context, child) {
            final hasFocus = _effectiveFocusNode.hasFocus;

            return KeyboardListener(
              focusNode: _effectiveFocusNode,
              onKeyEvent: (event) => _handleKeyEvent(event, items),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Display section header
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      'Display',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Setting items with keyboard navigation
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _buildSwitchTile(
                      context,
                      title: item.title,
                      subtitle: item.subtitle,
                      value: item.value,
                      onChanged: item.onChanged,
                      // Only show selection highlight when this widget has focus
                      isSelected: hasFocus && index == _selectedIndex,
                      onHover: () => setState(() => _selectedIndex = index),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isSelected,
    required VoidCallback onHover,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    // Use border-based highlight instead of fill to keep switch state visible
    return MouseRegion(
      onEnter: (_) => onHover(),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.surfaceContainerHighest
                : null,
            borderRadius: BorderRadius.circular(4),
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
