import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/app/widgets/overlays/hierarchy_panel/hierarchy_tree_node.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/world.dart';

/// Overlay panel that displays the entity hierarchy as a tree structure.
///
/// This panel allows users to:
/// - View the parent-child relationships between entities
/// - Select which parent entity's children to render in the game area
/// - Expand/collapse nodes to navigate the hierarchy
/// - Toggle "All Entities" mode to disable filtering
class HierarchyPanel extends StatefulWidget {
  /// The overlay name used to register and toggle this panel.
  static const String overlayName = 'hierarchyPanel';

  /// The ECS world containing all entities
  final World world;

  /// Notifier for the currently viewed parent entity ID
  final ValueNotifier<int?> viewedParentIdNotifier;

  /// Callback to close the panel
  final VoidCallback onClose;

  const HierarchyPanel({
    super.key,
    required this.world,
    required this.viewedParentIdNotifier,
    required this.onClose,
  });

  @override
  State<HierarchyPanel> createState() => _HierarchyPanelState();
}

class _HierarchyPanelState extends State<HierarchyPanel> {
  final FocusNode _focusNode = FocusNode();
  final Map<int, bool> _expandedNodes = {};

  @override
  void dispose() {
    widget.viewedParentIdNotifier.removeListener(_onViewedParentChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _requestFocusAfterBuild();

    // Listen to viewedParentId changes to auto-expand to the selected parent
    widget.viewedParentIdNotifier.addListener(_onViewedParentChanged);
    _onViewedParentChanged(); // Initial expansion
  }

  void _onViewedParentChanged() {
    final viewedParentId = widget.viewedParentIdNotifier.value;
    if (viewedParentId != null) {
      // Auto-expand the path to the selected parent
      _expandPathToEntity(viewedParentId);
    }
  }

  /// Expands all parent nodes in the path to the given entity
  void _expandPathToEntity(int entityId) {
    if (!mounted) return; // Safety check: don't call setState if disposed
    
    final hierarchyCache = widget.world.hierarchyCache;

    // Trace up the hierarchy and expand all ancestors
    var currentId = entityId;
    setState(() {
      _expandedNodes[currentId] =
          true; // Expand the entity itself if it has children

      while (true) {
        final parentId = hierarchyCache.getParent(currentId);
        if (parentId == null) break;

        _expandedNodes[parentId] = true;
        currentId = parentId;
      }
    });
  }

  void _requestFocusAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _toggleExpansion(int entityId) {
    setState(() {
      _expandedNodes[entityId] = !(_expandedNodes[entityId] ?? false);
    });
  }

  void _selectParent(int? parentId) {
    widget.viewedParentIdNotifier.value = parentId;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: false,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;

        // Handle ESC key to close panel
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          widget.onClose();
        }
      },
      child: Material(
        elevation: 4,
        color: Theme.of(context).colorScheme.surface,
        child: ValueListenableBuilder<int?>(
          valueListenable: widget.viewedParentIdNotifier,
          builder: (context, viewedParentId, _) {
            return Column(
              children: [
                _buildHeader(context, viewedParentId),
                Expanded(
                  child: _buildHierarchyTree(context, viewedParentId),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds the panel header with title and close button
  Widget _buildHeader(BuildContext context, int? viewedParentId) {
    // Get the name of the currently viewed parent
    String subtitle = 'Viewing: All Entities';
    if (viewedParentId != null) {
      final parentEntity = widget.world.getEntity(viewedParentId);
      final nameComponent = parentEntity.get<Name>();
      final parentName = nameComponent?.name ?? 'Entity #$viewedParentId';
      subtitle = 'Viewing: $parentName';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hierarchy Navigator',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: widget.onClose,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the hierarchy tree view
  Widget _buildHierarchyTree(BuildContext context, int? viewedParentId) {
    final allEntities = widget.world.entities();
    final hierarchyCache = widget.world.hierarchyCache;

    // Find root entities (entities without HasParent component)
    final rootEntities = allEntities.where((e) => !e.has<HasParent>()).toList();

    // Find all entities that have children (potential parents)
    final parentsWithChildren = allEntities
        .where((e) => hierarchyCache.getChildren(e.id).isNotEmpty)
        .toList();

    // Check if there are any entities in the hierarchy
    final hasHierarchy =
        rootEntities.isNotEmpty || parentsWithChildren.isNotEmpty;

    if (!hasHierarchy) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_tree,
                size: 40,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No hierarchy yet',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ).copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add HasParent components to entities',
                style: const TextStyle(fontSize: 11).copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        // "All Entities" radio option
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Radio<int?>(
                  value: null,
                  groupValue: viewedParentId,
                  onChanged: (value) => _selectParent(null),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'All Entities',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const Divider(height: 16),

        // Root entities section
        if (rootEntities.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Text(
              'Root Entities (${rootEntities.length})',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
          ...rootEntities.map((entity) {
            return HierarchyTreeNode(
              entity: entity,
              world: widget.world,
              selectedParentId: viewedParentId,
              onSelect: _selectParent,
              expandedNodes: _expandedNodes,
              onToggleExpand: _toggleExpansion,
              depth: 0,
            );
          }),
        ],
      ],
    );
  }
}
