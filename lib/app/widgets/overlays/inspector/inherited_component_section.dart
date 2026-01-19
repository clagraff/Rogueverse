import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';

/// A collapsible section for inherited (template) components in the inspector.
///
/// This widget handles both active inherited components and excluded components:
/// - Active: normal styling, expandable read-only content, exclude toggle
/// - Excluded: greyed out header, not expandable, restore toggle
class InheritedComponentSection extends StatefulWidget {
  /// The entity whose component is being displayed.
  final Entity entity;

  /// Metadata describing how to render and manage this component type.
  final ComponentMetadata metadata;

  /// Whether this component is excluded (in FromTemplate.excludedTypes).
  final bool isExcluded;

  const InheritedComponentSection({
    super.key,
    required this.entity,
    required this.metadata,
    required this.isExcluded,
  });

  @override
  State<InheritedComponentSection> createState() =>
      _InheritedComponentSectionState();
}

class _InheritedComponentSectionState extends State<InheritedComponentSection> {
  /// Whether this section is currently expanded to show its content.
  bool _expanded = false;

  void _toggleExclusion() {
    if (widget.isExcluded) {
      widget.entity.restoreFromTemplate(widget.metadata.componentName);
    } else {
      widget.entity.excludeFromTemplate(widget.metadata.componentName);
    }
  }

  void _duplicateToEntity() {
    // Get the component from the template and copy it to the entity directly
    final component = widget.entity.getByName(widget.metadata.componentName);
    if (component != null) {
      // Use copyWith to create a clone, then upsert to entity for editing
      final copy = component.copyWith.call();
      widget.entity.upsertByName(copy);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Section header with expand/collapse toggle and exclude toggle
        _buildSectionHeader(context),
        // Component-specific content (only shown when expanded and not excluded)
        if (_expanded && !widget.isExcluded)
          IgnorePointer(
            // Make content read-only for inherited components
            child: Opacity(
              opacity: 0.8,
              child: widget.metadata.buildContent(widget.entity),
            ),
          ),
        // Divider between sections
        Divider(
          height: 1,
          thickness: 0.5,
          color: scheme.outlineVariant,
        ),
      ],
    );
  }

  /// Builds the clickable header bar for the component section.
  Widget _buildSectionHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isExcluded = widget.isExcluded;

    return Container(
      height: 26,
      padding: const EdgeInsets.only(left: 8, right: 2),
      color: isExcluded
          ? scheme.surfaceContainerHighest.withValues(alpha: 0.3)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: Row(
        children: [
          // Expandable title area (only works when not excluded)
          Expanded(
            child: InkWell(
              onTap: isExcluded ? null : () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  if (!isExcluded)
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 14,
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    )
                  else
                    SizedBox(
                      width: 14,
                      child: Icon(
                        Icons.remove,
                        size: 10,
                        color: scheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  const SizedBox(width: 3),
                  Text(
                    widget.metadata.componentName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isExcluded
                          ? scheme.onSurface.withValues(alpha: 0.4)
                          : scheme.onSurface.withValues(alpha: 0.7),
                      fontStyle: isExcluded ? FontStyle.italic : null,
                      decoration: isExcluded ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Duplicate to entity button (only for active inherited components)
          if (!isExcluded)
            Tooltip(
              message: 'Copy to entity for editing',
              child: IconButton(
                icon: Icon(
                  Icons.copy,
                  size: 12,
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _duplicateToEntity,
              ),
            ),
          if (!isExcluded) const SizedBox(width: 4),
          // Exclude/Restore toggle button
          Tooltip(
            message: isExcluded ? 'Restore from template' : 'Exclude from template',
            child: IconButton(
              icon: Icon(
                Icons.block,
                size: 13,
                color: isExcluded
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.5),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _toggleExclusion,
            ),
          ),
        ],
      ),
    );
  }
}
