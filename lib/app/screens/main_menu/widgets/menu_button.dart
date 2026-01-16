import 'package:flutter/material.dart';

/// A styled button for the main menu with keyboard selection support.
class MenuButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool enabled;
  final bool isSelected;
  final void Function(bool)? onHover;

  const MenuButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.enabled = true,
    this.isSelected = false,
    this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: onHover != null ? (_) => onHover!(true) : null,
      onExit: onHover != null ? (_) => onHover!(false) : null,
      child: SizedBox(
        width: 220,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
          ),
          child: FilledButton.tonal(
            onPressed: enabled ? onPressed : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              backgroundColor: isSelected
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              foregroundColor: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 12),
                ],
                Text(label, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
