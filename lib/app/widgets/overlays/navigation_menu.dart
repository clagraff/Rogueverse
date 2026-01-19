import 'dart:io' show exit;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart' show World;
import 'package:rogueverse/ecs/persistence.dart' show Persistence;
import 'package:rogueverse/game/game_area.dart' show GameMode;

/// Menu item definition for keyboard navigation.
class _MenuItem {
  final IconData icon;
  final String label;
  final Future<void> Function() onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });
}

/// Content for the navigation drawer with keyboard navigation support.
///
/// Displays navigation links for panels and game controls.
/// Supports arrow key navigation, Enter to select, Escape to close.
class NavigationDrawerContent extends StatefulWidget {
  /// Callback when "Editor" is clicked.
  final VoidCallback onEditorPressed;

  /// Callback when "Vision Observer" is clicked.
  final VoidCallback onVisionObserverPressed;

  /// Callback when "Toggle Edit Mode" is clicked.
  final VoidCallback onToggleEditModePressed;

  /// Callback when "Quit to Menu" is clicked.
  final VoidCallback onQuitToMenu;

  /// Notifier for the current game mode.
  final ValueNotifier<GameMode> gameModeNotifier;

  /// Notifier for the currently selected entity.
  final ValueNotifier<Entity?> selectedEntityNotifier;

  /// Getter for the current world (called at action time, not build time).
  /// This ensures we always get the current world, even if it was replaced after build.
  final World Function() worldGetter;

  const NavigationDrawerContent({
    super.key,
    required this.onEditorPressed,
    required this.onVisionObserverPressed,
    required this.onToggleEditModePressed,
    required this.onQuitToMenu,
    required this.gameModeNotifier,
    required this.selectedEntityNotifier,
    required this.worldGetter,
  });

  @override
  State<NavigationDrawerContent> createState() => _NavigationDrawerContentState();
}

class _NavigationDrawerContentState extends State<NavigationDrawerContent> {
  final FocusNode _focusNode = FocusNode();
  int _selectedIndex = 0;

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

  List<_MenuItem> _buildMenuItems(BuildContext context) {
    final isEditing = widget.gameModeNotifier.value == GameMode.editing;
    final toggleKeyCombo =
        KeyBindingService.instance.getCombo('game.toggleMode')?.toDisplayString() ?? 'Ctrl+`';

    return [
      _MenuItem(
        icon: isEditing ? Icons.gamepad : Icons.edit,
        label: isEditing
            ? 'Enter Gameplay Mode ($toggleKeyCombo)'
            : 'Enter Edit Mode ($toggleKeyCombo)',
        onTap: () async {
          Navigator.pop(context);
          widget.onToggleEditModePressed();
        },
        trailing: _buildModeIndicator(context, isEditing),
      ),
      _MenuItem(
        icon: Icons.dashboard_customize,
        label:
            'Editor (${KeyBindingService.instance.getCombo('overlay.editor')?.toDisplayString() ?? 'Ctrl+E'})',
        onTap: () async {
          Navigator.pop(context);
          widget.onEditorPressed();
        },
      ),
      _MenuItem(
        icon: Icons.visibility,
        label: 'Vision Observer',
        onTap: () async {
          Navigator.pop(context);
          widget.onVisionObserverPressed();
        },
      ),
      _MenuItem(
        icon: Icons.home,
        label: 'Quit to Menu',
        onTap: () async {
          Navigator.pop(context);
          await Persistence.writeSavePatch(widget.worldGetter());
          widget.onQuitToMenu();
        },
      ),
      _MenuItem(
        icon: Icons.exit_to_app,
        label: 'Quit to Desktop',
        onTap: () async {
          Navigator.pop(context);
          await Persistence.writeSavePatch(widget.worldGetter());
          exit(0);
        },
      ),
    ];
  }

  Widget _buildModeIndicator(BuildContext context, bool isEditing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isEditing
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isEditing ? 'EDITING' : 'GAMEPLAY',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isEditing
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    final items = _buildMenuItems(context);

    // Navigation
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1).clamp(0, items.length - 1);
      });
    } else if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1).clamp(0, items.length - 1);
      });
    }
    // Selection (Enter, Space, or interact key)
    else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        KeyBindingService.instance.matches('entity.interact', {key})) {
      items[_selectedIndex].onTap();
    }
    // Close drawer
    else if (key == LogicalKeyboardKey.escape) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: ValueListenableBuilder<GameMode>(
        valueListenable: widget.gameModeNotifier,
        builder: (context, mode, _) {
          final items = _buildMenuItems(context);
          final colorScheme = Theme.of(context).colorScheme;

          return Drawer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        'Arrow keys to navigate, Enter to select',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Navigation items
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = index == _selectedIndex;

                      // Add divider before quit options
                      final needsDivider = index == 3;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (needsDivider) const Divider(),
                          if (index == 1) const Divider(),
                          MouseRegion(
                            onEnter: (_) => setState(() => _selectedIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              color: isSelected ? colorScheme.primaryContainer : null,
                              child: ListTile(
                                leading: Icon(
                                  item.icon,
                                  color: isSelected
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.primary,
                                ),
                                title: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: isSelected ? colorScheme.onPrimaryContainer : null,
                                    fontWeight: isSelected ? FontWeight.w600 : null,
                                  ),
                                ),
                                trailing: item.trailing,
                                onTap: () => item.onTap(),
                                hoverColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
