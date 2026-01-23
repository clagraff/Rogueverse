import 'package:flutter/material.dart';

/// Section header for grouping components (e.g., "Direct Components").
class ComponentSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const ComponentSectionHeader({
    super.key,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: color,
            width: 3,
          ),
        ),
        color: colorScheme.surfaceContainerLow,
      ),
      child: Row(
        children: [
          Text(
            '$title ($count)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header for template components with "Edit Template" button.
class TemplateSectionHeader extends StatelessWidget {
  final String templateName;
  final int count;
  final Color color;
  final VoidCallback onEditTemplate;

  const TemplateSectionHeader({
    super.key,
    required this.templateName,
    required this.count,
    required this.color,
    required this.onEditTemplate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: color,
            width: 3,
          ),
        ),
        color: colorScheme.surfaceContainerLow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'From Template ($count)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Tooltip(
            message: 'Edit "$templateName"',
            child: InkWell(
              onTap: onEditTemplate,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: color,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
