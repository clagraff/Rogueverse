import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';
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
  final FocusNode _focusNode = FocusNode();
  final _keybindings = KeyBindingService.instance;
  CharacterTab _selectedTab = CharacterTab.inventory;

  @override
  void initState() {
    super.initState();
    _requestFocusAfterBuild();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _requestFocusAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          child: KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: _handleKeyEvent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 700,
                maxHeight: 500,
              ),
              child: Material(
                elevation: 16,
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tab bar
                    _buildTabBar(context),

                    // Divider
                    Divider(height: 1, color: colorScheme.outlineVariant),

                    // Content area
                    Expanded(
                      child: _buildContent(context),
                    ),

                    // Divider
                    Divider(height: 1, color: colorScheme.outlineVariant),

                    // Footer with hints
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          _buildTabButton(
            context,
            tab: CharacterTab.inventory,
            icon: Icons.inventory_2_outlined,
            label: 'Inventory',
          ),
          const SizedBox(width: 8),
          _buildTabButton(
            context,
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
    BuildContext context, {
    required CharacterTab tab,
    required IconData icon,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedTab == tab;

    return InkWell(
      onTap: () => _selectTab(tab),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(6),
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
            const SizedBox(width: 8),
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

  Widget _buildContent(BuildContext context) {
    switch (_selectedTab) {
      case CharacterTab.inventory:
        return InventoryTabContent(inventory: widget.inventory);
      case CharacterTab.settings:
        return const SettingsTabContent();
    }
  }

  Widget _buildFooter(BuildContext context) {
    final prevKey = _keybindings.getCombo('ui.tab_prev')?.toDisplayString() ?? 'Q';
    final nextKey = _keybindings.getCombo('ui.tab_next')?.toDisplayString() ?? 'E';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildHint(context, prevKey, 'Prev tab'),
          const SizedBox(width: 16),
          _buildHint(context, nextKey, 'Next tab'),
          const SizedBox(width: 16),
          _buildHint(context, 'Tab/Esc', 'Close'),
        ],
      ),
    );
  }

  Widget _buildHint(BuildContext context, String key, String action) {
    final colorScheme = Theme.of(context).colorScheme;

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
        const SizedBox(width: 4),
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
