import 'package:flutter/material.dart';

/// Content for the navigation drawer.
///
/// Displays navigation links (like "Entity Templates").
/// Clicking a link performs an action and closes the drawer.
class NavigationDrawerContent extends StatelessWidget {
  /// Callback when "Entity Templates" is clicked.
  final VoidCallback onEntityTemplatesPressed;

  const NavigationDrawerContent({
    super.key,
    required this.onEntityTemplatesPressed,
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
                _buildNavItem(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  label: 'Entity Templates',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    onEntityTemplatesPressed();
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
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onTap: onTap,
      hoverColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
    );
  }
}
