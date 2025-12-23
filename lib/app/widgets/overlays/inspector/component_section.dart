import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';

/// A collapsible section in the inspector that displays a single component's properties.
///
/// This widget provides the common accordion-style UI (header with expand/collapse
/// and delete buttons) while delegating the actual content rendering to the
/// component's [ComponentMetadata] implementation.
class ComponentSection extends StatefulWidget {
  /// The entity whose component is being displayed.
  final Entity entity;

  /// Metadata describing how to render and manage this component type.
  final ComponentMetadata metadata;

  const ComponentSection({
    super.key,
    required this.entity,
    required this.metadata,
  });

  @override
  State<ComponentSection> createState() => _ComponentSectionState();
}

class _ComponentSectionState extends State<ComponentSection> {
  /// Whether this section is currently expanded to show its content.
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Section header with expand/collapse toggle and delete button
        _buildSectionHeader(
          context: context,
          title: widget.metadata.componentName,
          expanded: _expanded,
          onTap: () => setState(() => _expanded = !_expanded),
          onDelete: () => widget.metadata.removeComponent(widget.entity),
        ),
        // Component-specific content (only shown when expanded)
        if (_expanded) widget.metadata.buildContent(widget.entity),
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
  ///
  /// The header displays the component name and includes controls for
  /// expanding/collapsing the section and removing the component from the entity.
  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 26,
      padding: const EdgeInsets.only(left: 8, right: 2),
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: Row(
        children: [
          // Expandable title area
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  Icon(
                    expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.close, size: 13),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onDelete,
            tooltip: 'Remove component',
          ),
        ],
      ),
    );
  }
}
