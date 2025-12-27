import 'package:flutter/material.dart';

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';

/// A tree node widget representing an entity in the hierarchy.
///
/// Displays:
/// - Radio button for selection
/// - Expand/collapse arrow (if has children)
/// - Entity name
/// - Child count badge
/// - Recursive children when expanded
class HierarchyTreeNode extends StatelessWidget {
  /// The entity this node represents
  final Entity entity;

  /// The ECS world
  final World world;

  /// Currently selected/viewed parent entity ID (null = all entities)
  final int? selectedParentId;

  /// Callback when an entity is selected as the viewed parent
  final void Function(int? parentId) onSelect;

  /// Map tracking which nodes are expanded
  final Map<int, bool> expandedNodes;

  /// Callback to toggle node expansion
  final void Function(int entityId) onToggleExpand;

  /// Current depth in the tree (for indentation)
  final int depth;

  const HierarchyTreeNode({
    super.key,
    required this.entity,
    required this.world,
    required this.selectedParentId,
    required this.onSelect,
    required this.expandedNodes,
    required this.onToggleExpand,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final children = world.hierarchyCache.getChildren(entity.id);
    final hasChildren = children.isNotEmpty;
    final isExpanded = expandedNodes[entity.id] ?? false;
    final isSelected = selectedParentId == entity.id;

    // Get entity name
    final nameComponent = entity.get<Name>();
    final entityName = nameComponent?.name ?? 'Entity #${entity.id}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node row
        InkWell(
          onTap: hasChildren ? () => onToggleExpand(entity.id) : null,
          child: Container(
            padding: EdgeInsets.only(
                left: depth * 16.0 + 4, right: 4, top: 2, bottom: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.5)
                  : Colors.transparent,
              border: isSelected
                  ? Border(
                      left: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Radio button (only show for entities with children)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: hasChildren
                      ? Radio<int?>(
                          value: entity.id,
                          groupValue: selectedParentId,
                          onChanged: (value) => onSelect(value),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        )
                      : null, // No radio button for leaf nodes
                ),
                const SizedBox(width: 4),
                // Expand/collapse arrow
                SizedBox(
                  width: 20,
                  child: hasChildren
                      ? Icon(
                          isExpanded
                              ? Icons.arrow_drop_down
                              : Icons.arrow_right,
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 4),
                // Entity name
                Expanded(
                  child: Text(
                    entityName,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Child count badge
                if (hasChildren)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${children.length}',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
        // Recursive children
        if (hasChildren && isExpanded)
          ...children.map((childId) {
            final childEntity = world.getEntity(childId);
            return HierarchyTreeNode(
              entity: childEntity,
              world: world,
              selectedParentId: selectedParentId,
              onSelect: onSelect,
              expandedNodes: expandedNodes,
              onToggleExpand: onToggleExpand,
              depth: depth + 1,
            );
          }),
      ],
    );
  }
}
