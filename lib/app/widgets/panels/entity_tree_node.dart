import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:rogueverse/ecs/ecs.dart';

/// A recursive tree node widget for displaying entities in a hierarchy.
///
/// Combines tree structure with selection capabilities:
/// - Entities under the current [viewedParentId] are selectable
/// - Other entities are visible but grayed out (double-click to navigate)
class EntityTreeNode extends StatelessWidget {
  /// The entity this node represents
  final Entity entity;

  /// The ECS world
  final World world;

  /// Current viewing scope (null = root level)
  final int? viewedParentId;

  /// Currently selected entities
  final Set<Entity> selectedEntities;

  /// Map tracking which nodes are expanded
  final Map<int, bool> expandedNodes;

  /// Current depth in the tree (for indentation)
  final int depth;

  /// Callback to toggle node expansion
  final void Function(int entityId) onToggleExpand;

  /// Callback to select an entity
  final void Function(Entity entity) onSelect;

  /// Callback for navigation (double-click on parent)
  final void Function(int? parentId) onNavigate;

  /// The currently focused entity ID (for keyboard navigation)
  final int? focusedEntityId;

  const EntityTreeNode({
    super.key,
    required this.entity,
    required this.world,
    required this.viewedParentId,
    required this.selectedEntities,
    required this.expandedNodes,
    required this.depth,
    required this.onToggleExpand,
    required this.onSelect,
    required this.onNavigate,
    this.focusedEntityId,
  });

  /// Whether this entity is selectable (under the current viewed parent)
  bool get _isSelectable {
    // Use the world's component map directly for reliable lookup
    final hasParentMap = world.get<HasParent>();
    final hasParent = hasParentMap[entity.id];
    if (viewedParentId == null) {
      // At root view, root entities (no parent) are selectable
      return hasParent == null;
    }
    // Entity is selectable if its parent matches viewedParentId
    return hasParent?.parentEntityId == viewedParentId;
  }

  bool get _hasChildren {
    // Check component map directly instead of potentially stale cache
    final hasParentMap = world.get<HasParent>();
    return hasParentMap.values.any((hp) => hp.parentEntityId == entity.id);
  }

  bool get _isExpanded => expandedNodes[entity.id] ?? false;

  bool get _isSelected => selectedEntities.contains(entity);

  bool get _isFocused => focusedEntityId == entity.id;

  @override
  Widget build(BuildContext context) {
    // Get children directly from component map (not stale cache)
    final hasParentMap = world.get<HasParent>();
    final childIds = hasParentMap.entries
        .where((e) => e.value.parentEntityId == entity.id)
        .map((e) => e.key)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node row
        _buildNodeRow(context),
        // Recursive children
        if (_hasChildren && _isExpanded)
          ...childIds.map((childId) {
            final childEntity = world.getEntity(childId);
            return EntityTreeNode(
              entity: childEntity,
              world: world,
              viewedParentId: viewedParentId,
              selectedEntities: selectedEntities,
              expandedNodes: expandedNodes,
              depth: depth + 1,
              onToggleExpand: onToggleExpand,
              onSelect: onSelect,
              onNavigate: onNavigate,
              focusedEntityId: focusedEntityId,
            );
          }),
      ],
    );
  }

  Widget _buildNodeRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = entity.get<Name>()?.name ?? 'Entity #${entity.id}';
    final renderable = entity.get<Renderable>();
    // Get child count directly from component map (not stale cache)
    final hasParentMap = world.get<HasParent>();
    final childCount = hasParentMap.values.where((hp) => hp.parentEntityId == entity.id).length;

    // Use GestureDetector for both tap and double-tap to avoid conflicts
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isSelectable ? () => onSelect(entity) : null,
      onDoubleTap: () => onNavigate(entity.id),
      child: Container(
        decoration: BoxDecoration(
          color: _isSelected && _isSelectable
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : _isFocused
                  ? colorScheme.primaryContainer.withValues(alpha: 0.15)
                  : Colors.transparent,
          border: _isFocused
              ? Border(
                  left: BorderSide(
                    color: colorScheme.primary,
                    width: 3,
                  ),
                )
              : null,
        ),
        padding: EdgeInsets.only(
          left: _isFocused ? depth * 16.0 + 1 : depth * 16.0 + 4,
          right: 4,
          top: 2,
          bottom: 2,
        ),
        child: Row(
          children: [
            // Expand/collapse arrow
            SizedBox(
              width: 20,
              child: _hasChildren
                  ? InkWell(
                      onTap: () => onToggleExpand(entity.id),
                      borderRadius: BorderRadius.circular(4),
                      child: Icon(
                        _isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                        size: 20,
                        color: _isSelectable
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 4),
            // Entity icon
            SizedBox(
              width: 16,
              height: 16,
              child: _buildEntityIcon(context, renderable),
            ),
            const SizedBox(width: 4),
            // Entity name with optional child count
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: name),
                    if (_hasChildren)
                      TextSpan(
                        text: ' ($childCount)',
                        style: TextStyle(
                          fontSize: 9,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                  ],
                ),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: _isSelected && _isSelectable
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: _isSelectable
                      ? (_isSelected ? colorScheme.primary : colorScheme.onSurface)
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                  fontStyle: _isSelectable ? FontStyle.normal : FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Entity ID
            Text(
              '#${entity.id}',
              style: TextStyle(
                fontSize: 9,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntityIcon(BuildContext context, Renderable? renderable) {
    final colorScheme = Theme.of(context).colorScheme;
    final alpha = _isSelectable ? 0.7 : 0.4;

    if (renderable != null && renderable.asset is ImageAsset) {
      return Opacity(
        opacity: _isSelectable ? 1.0 : 0.5,
        child: SvgPicture.asset(
          'assets/${(renderable.asset as ImageAsset).svgAssetPath}',
          width: 14,
          height: 14,
          fit: BoxFit.contain,
        ),
      );
    }

    return Icon(
      renderable?.asset is TextAsset ? Icons.text_fields : Icons.widgets_outlined,
      size: 14,
      color: colorScheme.onSurface.withValues(alpha: alpha),
    );
  }
}
