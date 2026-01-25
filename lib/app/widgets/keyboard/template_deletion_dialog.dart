import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/app/widgets/keyboard/auto_focus_keyboard_listener.dart';

/// Options for handling dependent entities when deleting a template.
enum TemplateDeletionOption {
  /// Copy the template's components to each dependent entity, then unlink.
  copyComponents,

  /// Cascade delete all dependent entities (destructive).
  deleteChildren,

  /// Just remove FromTemplate from children, leaving them as orphans.
  acceptOrphans,
}

/// A dialog that presents options for handling dependent entities when
/// deleting a template.
///
/// Shows the count of affected entities and provides three options:
/// - Copy Template Components: Copy template's own components to each child
/// - Delete Children: Cascade delete all dependent entities (destructive)
/// - Accept Orphans: Just remove FromTemplate from children
///
/// Supports keyboard navigation (up/down, enter to confirm, escape to cancel).
///
/// Usage:
/// ```dart
/// final option = await TemplateDeletionDialog.show(
///   context: context,
///   templateName: 'MyTemplate',
///   dependentCount: 5,
/// );
/// if (option != null) {
///   // Execute chosen option
/// }
/// ```
class TemplateDeletionDialog extends StatefulWidget {
  final String templateName;
  final int dependentCount;

  const TemplateDeletionDialog({
    super.key,
    required this.templateName,
    required this.dependentCount,
  });

  /// Shows the dialog and returns the selected option, or null if cancelled.
  static Future<TemplateDeletionOption?> show({
    required BuildContext context,
    required String templateName,
    required int dependentCount,
  }) async {
    return showDialog<TemplateDeletionOption>(
      context: context,
      builder: (context) => TemplateDeletionDialog(
        templateName: templateName,
        dependentCount: dependentCount,
      ),
    );
  }

  @override
  State<TemplateDeletionDialog> createState() => _TemplateDeletionDialogState();
}

class _TemplateDeletionDialogState extends State<TemplateDeletionDialog> {
  int _selectedIndex = 0;

  static const _options = [
    (
      option: TemplateDeletionOption.copyComponents,
      icon: Icons.content_copy,
      label: 'Copy Template Components',
      description: 'Copy template\'s own components to each child, then unlink',
      isDestructive: false,
    ),
    (
      option: TemplateDeletionOption.deleteChildren,
      icon: Icons.delete_forever,
      label: 'Delete Children',
      description: 'Cascade delete all dependent entities',
      isDestructive: true,
    ),
    (
      option: TemplateDeletionOption.acceptOrphans,
      icon: Icons.link_off,
      label: 'Accept Orphans',
      description: 'Just remove template link from children',
      isDestructive: false,
    ),
  ];

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    final keybindings = KeyBindingService.instance;

    // Navigate up
    if (key == LogicalKeyboardKey.arrowUp ||
        keybindings.matches('menu.up', {key})) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1).clamp(0, _options.length - 1);
      });
    }
    // Navigate down
    else if (key == LogicalKeyboardKey.arrowDown ||
        keybindings.matches('menu.down', {key})) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1).clamp(0, _options.length - 1);
      });
    }
    // Confirm selection
    else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        keybindings.matches('menu.select', {key})) {
      Navigator.of(context).pop(_options[_selectedIndex].option);
    }
    // Cancel
    else if (key == LogicalKeyboardKey.escape ||
        keybindings.matches('menu.back', {key})) {
      Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entityLabel = widget.dependentCount == 1 ? 'entity' : 'entities';

    return AutoFocusKeyboardListener(
      onKeyEvent: _handleKeyEvent,
      child: AlertDialog(
        title: const Text('Delete Template'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Deleting "${widget.templateName}" will affect '
                        '${widget.dependentCount} $entityLabel.',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'How would you like to handle dependent entities?',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 12),
              // Options list
              ...List.generate(_options.length, (index) {
                final opt = _options[index];
                final isSelected = index == _selectedIndex;

                return _OptionTile(
                  icon: opt.icon,
                  label: opt.label,
                  description: opt.description,
                  isSelected: isSelected,
                  isDestructive: opt.isDestructive,
                  onTap: () {
                    setState(() => _selectedIndex = index);
                  },
                  onDoubleTap: () {
                    Navigator.of(context).pop(opt.option);
                  },
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          _options[_selectedIndex].isDestructive
              ? FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_options[_selectedIndex].option),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                  ),
                  child: const Text('Confirm'),
                )
              : FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_options[_selectedIndex].option),
                  child: const Text('Confirm'),
                ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final bool isDestructive;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.isDestructive,
    required this.onTap,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = isDestructive ? colorScheme.error : colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? accentColor : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? accentColor : colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? accentColor
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: accentColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
