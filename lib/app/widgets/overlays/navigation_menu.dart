import 'dart:io' show exit;

import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart' show WorldSaves, World;

/// Content for the navigation drawer.
///
/// Displays navigation links (like "Entity Templates").
/// Clicking a link performs an action and closes the drawer.
class NavigationDrawerContent extends StatelessWidget {
  /// Callback when "Entity Templates" is clicked.
  final VoidCallback onEntityTemplatesPressed;

  /// Callback when "Hierarchy Navigator" is clicked.
  final VoidCallback onHierarchyNavigatorPressed;

  /// Callback when "Vision Observer" is clicked.
  final VoidCallback onVisionObserverPressed;

  /// Callback when "Entity Inspector" is clicked.
  final VoidCallback onEntityInspectorPressed;

  /// Notifier for the currently selected entity (to enable/disable inspector).
  final ValueNotifier<Entity?> selectedEntityNotifier;

  final World world;

  const NavigationDrawerContent(
      {super.key,
      required this.onEntityTemplatesPressed,
      required this.onHierarchyNavigatorPressed,
      required this.onVisionObserverPressed,
      required this.onEntityInspectorPressed,
      required this.selectedEntityNotifier,
      required this.world});

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
                _buildNavItem(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  label: 'Entity Templates (Ctrl+T)',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    onEntityTemplatesPressed();
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.account_tree,
                  label: 'Hierarchy Navigator',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    onHierarchyNavigatorPressed();
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.visibility,
                  label: 'Vision Observer',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    onVisionObserverPressed();
                  },
                ),
                ValueListenableBuilder<Entity?>(
                  valueListenable: selectedEntityNotifier,
                  builder: (context, selectedEntity, _) {
                    return _buildNavItem(
                      context: context,
                      icon: Icons.edit,
                      label: 'Entity Inspector (Ctrl+E)',
                      enabled: selectedEntity != null,
                      onTap: selectedEntity != null
                          ? () {
                              Navigator.pop(context); // Close drawer
                              onEntityInspectorPressed();
                            }
                          : () {}, // No-op when disabled
                    );
                  },
                ),
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
                // Future navigation items can be added here
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
