import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/app/widgets/keyboard/auto_focus_keyboard_listener.dart';
import 'package:rogueverse/app/ui_constants.dart';
import 'package:rogueverse/app/widgets/overlays/character_screen/inventory_tab.dart';
import 'package:rogueverse/app/widgets/overlays/character_screen/settings_tab.dart';
import 'package:rogueverse/ecs/entity.dart';

/// Character screen tabs.
enum CharacterTab {
  inventory,
  settings,
}

/// Tabbed character screen overlay.
///
/// Opens with Tab key and provides access to inventory, settings, and future
/// character-related panels. Follows the same visual style as DialogOverlay.
class CharacterScreenOverlay extends StatefulWidget {
  /// The overlay name used to register and toggle this overlay.
  static const String overlayName = 'characterScreen';

  /// The player's inventory items.
  final List<Entity> inventory;

  /// Callback when the overlay is closed.
  final VoidCallback? onClose;

  const CharacterScreenOverlay({
    super.key,
    required this.inventory,
    this.onClose,
  });

  @override
  State<CharacterScreenOverlay> createState() => _CharacterScreenOverlayState();
}

class _CharacterScreenOverlayState extends State<CharacterScreenOverlay> {
  final _keybindings = KeyBindingService.instance;
  final _focusNode = FocusNode();
  CharacterTab _selectedTab = CharacterTab.inventory;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _close() {
    widget.onClose?.call();
  }

  void _selectTab(CharacterTab tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  void _previousTab() {
    final tabs = CharacterTab.values;
    final currentIndex = tabs.indexOf(_selectedTab);
    final newIndex = (currentIndex - 1 + tabs.length) % tabs.length;
    _selectTab(tabs[newIndex]);
  }

  void _nextTab() {
    final tabs = CharacterTab.values;
    final currentIndex = tabs.indexOf(_selectedTab);
    final newIndex = (currentIndex + 1) % tabs.length;
    _selectTab(tabs[newIndex]);
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;

    // Tab or Escape - close overlay
    if (key == LogicalKeyboardKey.tab || key == LogicalKeyboardKey.escape) {
      _close();
      return;
    }

    if (_keybindings.matches('ui.tab_prev', keysPressed)) {
      _previousTab();
      return;
    }

    if (_keybindings.matches('ui.tab_next', keysPressed)) {
      _nextTab();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: KeyBindingService.instance.changeNotifier,
      builder: (context, _, __) => _buildUI(context),
    );
  }

  Widget _buildUI(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Semi-transparent backdrop
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ),

        // Centered panel
        Center(
          child: AutoFocusKeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: _handleKeyEvent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: kCharacterScreenMaxWidth,
                maxHeight: kCharacterScreenMaxHeight,
              ),
              child: Material(
                elevation: kElevationHigh,
                borderRadius: BorderRadius.circular(kRadiusL),
                color: colorScheme.surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tab bar
                    _buildTabBar(colorScheme),

                    // Divider
                    Divider(height: 1, color: colorScheme.outlineVariant),

                    // Content area
                    Expanded(
                      child: _buildContent(),
                    ),

                    // Divider
                    Divider(height: 1, color: colorScheme.outlineVariant),

                    // Footer with hints
                    _buildFooter(colorScheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingM, vertical: kSpacingM),
      child: Row(
        children: [
          _buildTabButton(
            colorScheme,
            tab: CharacterTab.inventory,
            icon: Icons.inventory_2_outlined,
            label: 'Inventory',
          ),
          const SizedBox(width: kSpacingM),
          _buildTabButton(
            colorScheme,
            tab: CharacterTab.settings,
            icon: Icons.settings_outlined,
            label: 'Settings',
          ),
          const Spacer(),
          // Close button
          IconButton(
            onPressed: _close,
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    ColorScheme colorScheme, {
    required CharacterTab tab,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTab == tab;

    return InkWell(
      onTap: () => _selectTab(tab),
      borderRadius: BorderRadius.circular(kRadiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: kSpacingXL, vertical: kSpacingM),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(kRadiusM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: kSpacingM),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case CharacterTab.inventory:
        return InventoryTabContent(inventory: widget.inventory);
      case CharacterTab.settings:
        return SettingsTabContent(parentFocusNode: _focusNode);
    }
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    final prevKey = _keybindings.getCombo('ui.tab_prev')?.toDisplayString() ?? 'Q';
    final nextKey = _keybindings.getCombo('ui.tab_next')?.toDisplayString() ?? 'E';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingXL, vertical: kSpacingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildHint(colorScheme, prevKey, 'Prev tab'),
          const SizedBox(width: kSpacingXL),
          _buildHint(colorScheme, nextKey, 'Next tab'),
          const SizedBox(width: kSpacingXL),
          _buildHint(colorScheme, 'Tab/Esc', 'Close'),
        ],
      ),
    );
  }

  Widget _buildHint(ColorScheme colorScheme, String key, String action) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          key,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: kSpacingS),
        Text(
          action,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
