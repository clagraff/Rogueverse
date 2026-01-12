import 'dart:io' show exit;

import 'package:flutter/material.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart' show WorldSaves, World;
import 'package:rogueverse/game/game_area.dart' show GameMode;

/// Content for the navigation drawer.
///
/// Displays navigation links for panels and game controls.
/// Clicking a link performs an action and closes the drawer.
class NavigationDrawerContent extends StatelessWidget {
  /// Callback when "Editor" is clicked.
  final VoidCallback onEditorPressed;

  /// Callback when "Hierarchy Navigator" is clicked.
  final VoidCallback onHierarchyNavigatorPressed;

  /// Callback when "Vision Observer" is clicked.
  final VoidCallback onVisionObserverPressed;

  /// Callback when "Toggle Edit Mode" is clicked.
  final VoidCallback onToggleEditModePressed;

  /// Notifier for the current game mode.
  final ValueNotifier<GameMode> gameModeNotifier;

  /// Notifier for the currently selected entity.
  final ValueNotifier<Entity?> selectedEntityNotifier;

  final World world;

  const NavigationDrawerContent({
    super.key,
    required this.onEditorPressed,
    required this.onHierarchyNavigatorPressed,
    required this.onVisionObserverPressed,
    required this.onToggleEditModePressed,
    required this.gameModeNotifier,
    required this.selectedEntityNotifier,
    required this.world,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Text(
              'Navigation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Toggle Edit Mode (with mode indicator)
                ValueListenableBuilder<GameMode>(
                  valueListenable: gameModeNotifier,
                  builder: (context, mode, _) {
                    final isEditing = mode == GameMode.editing;
                    final toggleKeyCombo = KeyBindingService.instance
                            .getCombo('game.toggleMode')
                            ?.toDisplayString() ??
                        'Ctrl+`';
                    return _buildNavItem(
                      context: context,
                      icon: isEditing ? Icons.gamepad : Icons.edit,
                      label: isEditing
                          ? 'Enter Gameplay Mode ($toggleKeyCombo)'
                          : 'Enter Edit Mode ($toggleKeyCombo)',
                      onTap: () {
                        Navigator.pop(context);
                        onToggleEditModePressed();
                      },
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isEditing
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isEditing ? 'EDITING' : 'GAMEPLAY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isEditing
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
                _buildNavItem(
                  context: context,
                  icon: Icons.dashboard_customize,
                  label:
                      'Editor (${KeyBindingService.instance.getCombo('overlay.editor')?.toDisplayString() ?? 'Ctrl+E'})',
                  onTap: () {
                    Navigator.pop(context);
                    onEditorPressed();
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.account_tree,
                  label: 'Hierarchy Navigator',
                  onTap: () {
                    Navigator.pop(context);
                    onHierarchyNavigatorPressed();
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.visibility,
                  label: 'Vision Observer',
                  onTap: () {
                    Navigator.pop(context);
                    onVisionObserverPressed();
                  },
                ),
                const Divider(),
                _buildNavItem(
                  context: context,
                  icon: Icons.save,
                  label: 'Save & Quit',
                  onTap: () async {
                    Navigator.pop(context);
                    await WorldSaves.writeSave(world);
                    exit(0);
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.close,
                  label: 'Quit',
                  onTap: () async {
                    Navigator.pop(context);
                    exit(0);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single navigation item.
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: enabled
                  ? null
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.38),
            ),
      ),
      trailing: trailing,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      hoverColor: enabled
          ? Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: 0.3)
          : null,
    );
  }
}
