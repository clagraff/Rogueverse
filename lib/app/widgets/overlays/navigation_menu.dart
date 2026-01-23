import 'dart:io' show exit;

import 'package:flutter/material.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/app/ui_constants.dart';
import 'package:rogueverse/app/widgets/keyboard/auto_focus_keyboard_listener.dart';
import 'package:rogueverse/app/widgets/keyboard/menu_keyboard_navigation.dart';
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

  /// Callback when "Template Variables" is clicked.
  final VoidCallback onTemplateVariablesPressed;

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
    required this.onTemplateVariablesPressed,
    required this.gameModeNotifier,
    required this.selectedEntityNotifier,
    required this.worldGetter,
  });

  @override
  State<NavigationDrawerContent> createState() => _NavigationDrawerContentState();
}

class _NavigationDrawerContentState extends State<NavigationDrawerContent> {
  int _selectedIndex = 0;

  List<_MenuItem> _buildMenuItems(BuildContext context, ColorScheme colorScheme) {
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
        trailing: _buildModeIndicator(colorScheme, isEditing),
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
        icon: Icons.code,
        label: 'Template Variables',
        onTap: () async {
          Navigator.pop(context);
          widget.onTemplateVariablesPressed();
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

  Widget _buildModeIndicator(ColorScheme colorScheme, bool isEditing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingM, vertical: kSpacingXS),
      decoration: BoxDecoration(
        color: isEditing
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(kRadiusS),
      ),
      child: Text(
        isEditing ? 'EDITING' : 'GAMEPLAY',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isEditing
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event, List<_MenuItem> items) {
    final nav = MenuKeyboardNavigation(
      itemCount: items.length,
      selectedIndex: _selectedIndex,
      onIndexChanged: (index) => setState(() => _selectedIndex = index),
      onActivate: () => items[_selectedIndex].onTap(),
      onBack: () => Navigator.pop(context),
    );
    nav.handleKeyEvent(event);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<GameMode>(
      valueListenable: widget.gameModeNotifier,
      builder: (context, mode, _) {
        final items = _buildMenuItems(context, colorScheme);

        return AutoFocusKeyboardListener(
          onKeyEvent: (event) => _handleKeyEvent(event, items),
          child: Drawer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(kSpacingXL, kSpacingXL, kSpacingXL, kSpacingL),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Menu',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: kSpacingS),
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
                      final needsDivider = index == 4;

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
                                  '${index + 1}. ${item.label}',
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
          ),
        );
      },
    );
  }
}
