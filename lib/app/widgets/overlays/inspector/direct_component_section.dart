import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';

/// A component section for direct components in the split view.
///
/// Uses removeDirect instead of the standard remove to avoid creating
/// exclusions when deleting a direct component that's also on the template.
class DirectComponentSection extends StatefulWidget {
  final Entity entity;
  final ComponentMetadata metadata;

  const DirectComponentSection({
    super.key,
    required this.entity,
    required this.metadata,
  });

  @override
  State<DirectComponentSection> createState() => _DirectComponentSectionState();
}

class _DirectComponentSectionState extends State<DirectComponentSection> {
  bool _expanded = false;

  void _handleDelete() {
    // Use removeDirectByName to avoid adding exclusions
    widget.entity.removeDirectByName(widget.metadata.componentName);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Section header with expand/collapse toggle and delete button
        Container(
          height: 26,
          padding: const EdgeInsets.only(left: 8, right: 2),
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
          child: Row(
            children: [
              // Expandable title area
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    children: [
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        widget.metadata.componentName,
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
                onPressed: _handleDelete,
                tooltip: 'Remove component',
              ),
            ],
          ),
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
}
