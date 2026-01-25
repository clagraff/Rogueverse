import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/app/services/game_settings_service.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';

/// Base class for setting items supporting keyboard navigation.
sealed class _SettingItem {
  String get title;
  String get subtitle;
}

/// A boolean setting item displayed with a switch.
class _BoolSettingItem extends _SettingItem {
  @override
  final String title;
  @override
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  _BoolSettingItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
}

/// An enum setting item displayed with left/right navigation.
class _EnumSettingItem<T extends Enum> extends _SettingItem {
  @override
  final String title;
  @override
  final String subtitle;
  final T value;
  final List<T> options;
  final String Function(T) labelBuilder;
  final String Function(T)? descriptionBuilder;
  final ValueChanged<T> onChanged;

  _EnumSettingItem({
    required this.title,
    this.subtitle = '',
    required this.value,
    required this.options,
    required this.labelBuilder,
    this.descriptionBuilder,
    required this.onChanged,
  });

  /// Gets the display label for the current value.
  String get currentLabel => labelBuilder(value);

  /// Gets the description for the current value.
  /// Uses descriptionBuilder if provided, otherwise falls back to subtitle.
  String get currentDescription => descriptionBuilder?.call(value) ?? subtitle;

  /// Gets the display label for an option at the given index.
  String labelForIndex(int index) => labelBuilder(options[index]);

  /// Selects the option at the given index.
  void selectIndex(int index) => onChanged(options[index]);

  /// Cycles to the next option (wraps around).
  void cycleNext() {
    final currentIndex = options.indexOf(value);
    final nextIndex = (currentIndex + 1) % options.length;
    onChanged(options[nextIndex]);
  }

  /// Cycles to the previous option (wraps around).
  void cyclePrevious() {
    final currentIndex = options.indexOf(value);
    final prevIndex = (currentIndex - 1 + options.length) % options.length;
    onChanged(options[prevIndex]);
  }
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
    final settings = GameSettingsService.instance;
    return [
      _BoolSettingItem(
        title: 'Always show health bars',
        subtitle: 'Show health bars even when at full health',
        value: settings.alwaysShowHealthBars,
        onChanged: (value) => settings.setAlwaysShowHealthBars(value),
      ),
      _EnumSettingItem<InteractionMacroMode>(
        title: 'Interaction macro',
        value: settings.interactionMacroMode,
        options: InteractionMacroMode.values,
        labelBuilder: (mode) => switch (mode) {
          InteractionMacroMode.disabled => 'Disabled',
          InteractionMacroMode.lookBack => 'Look-back',
          InteractionMacroMode.remainFacing => 'Remain facing',
        },
        descriptionBuilder: (mode) => switch (mode) {
          InteractionMacroMode.disabled => 'Only interact with visible entities',
          InteractionMacroMode.lookBack => 'Turn to face, interact, then turn back',
          InteractionMacroMode.remainFacing =>
            'Turn to face and interact (stay facing)',
        },
        onChanged: (value) => settings.setInteractionMacroMode(value),
      ),
    ];
  }

  /// Index where the "Gameplay" section starts.
  int get _gameplaySectionStart => 1;

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

    final item = items[_selectedIndex];

    // A/Left: cycle enum previous
    if (key == LogicalKeyboardKey.arrowLeft ||
        keybindings.matches('menu.left', {key})) {
      if (item is _EnumSettingItem) {
        item.cyclePrevious();
      }
      return;
    }

    // D/Right: cycle enum next
    if (key == LogicalKeyboardKey.arrowRight ||
        keybindings.matches('menu.right', {key})) {
      if (item is _EnumSettingItem) {
        item.cycleNext();
      }
      return;
    }

    // Enter/Space: toggle bool or cycle enum
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        keybindings.matches('menu.select', {key})) {
      switch (item) {
        case _BoolSettingItem():
          item.onChanged(!item.value);
        case _EnumSettingItem():
          item.cycleNext();
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildSectionHeader(context, 'Display'),

                  // Display settings (before gameplay section)
                  ...items
                      .asMap()
                      .entries
                      .where((e) => e.key < _gameplaySectionStart)
                      .map((entry) => _buildSettingTile(
                            context,
                            item: entry.value,
                            isSelected: hasFocus && entry.key == _selectedIndex,
                            onHover: () =>
                                setState(() => _selectedIndex = entry.key),
                          )),

                  // Gameplay section header
                  _buildSectionHeader(context, 'Gameplay'),

                  // Gameplay settings
                  ...items
                      .asMap()
                      .entries
                      .where((e) => e.key >= _gameplaySectionStart)
                      .map((entry) => _buildSettingTile(
                            context,
                            item: entry.value,
                            isSelected: hasFocus && entry.key == _selectedIndex,
                            onHover: () =>
                                setState(() => _selectedIndex = entry.key),
                          )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required _SettingItem item,
    required bool isSelected,
    required VoidCallback onHover,
  }) {
    return switch (item) {
      _BoolSettingItem() => _buildSwitchTile(
          context,
          title: item.title,
          subtitle: item.subtitle,
          value: item.value,
          onChanged: item.onChanged,
          isSelected: isSelected,
          onHover: onHover,
        ),
      _EnumSettingItem() => _buildEnumTile(
          context,
          item: item,
          isSelected: isSelected,
          onHover: onHover,
        ),
    };
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
            color: isSelected ? colorScheme.surfaceContainerHighest : null,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
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

  Widget _buildEnumTile(
    BuildContext context, {
    required _EnumSettingItem item,
    required bool isSelected,
    required VoidCallback onHover,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => onHover(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surfaceContainerHighest : null,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.currentDescription,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Dropdown for enum selection
            DropdownButton<int>(
              value: item.options.indexOf(item.value),
              underline: const SizedBox.shrink(),
              isDense: true,
              borderRadius: BorderRadius.circular(4),
              items: item.options.asMap().entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(
                    item.labelForIndex(entry.key),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (index) {
                if (index != null) {
                  item.selectIndex(index);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
