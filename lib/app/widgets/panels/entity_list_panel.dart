import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rogueverse/ecs/ecs.dart';

import 'entity_tree_node.dart';

/// Sort column for entity list
enum _SortColumn { name, id }

/// Panel for browsing, searching, and selecting entities in a tree hierarchy.
///
/// Features:
/// - Breadcrumb navigation for parent traversal
/// - Tree view showing entity hierarchy with expand/collapse
/// - Search bar to filter by entity ID or name (shows flat list when active)
/// - Sortable columns (Name, ID)
/// - Double-click on parent entities to navigate into them
class EntityListPanel extends StatefulWidget {
  final World world;
  final ValueNotifier<int?> viewedParentIdNotifier;
  final ValueNotifier<Set<Entity>> selectedEntitiesNotifier;

  const EntityListPanel({
    super.key,
    required this.world,
    required this.viewedParentIdNotifier,
    required this.selectedEntitiesNotifier,
  });

  @override
  State<EntityListPanel> createState() => _EntityListPanelState();
}

class _EntityListPanelState extends State<EntityListPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<int, bool> _expandedNodes = {};
  StreamSubscription<Change>? _entityChangeSubscription;
  _SortColumn _sortColumn = _SortColumn.id;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    // Listen for external selection changes to auto-expand path
    widget.selectedEntitiesNotifier.addListener(_onExternalSelectionChanged);
    // Ensure rebuild when viewed parent changes
    widget.viewedParentIdNotifier.addListener(_onViewedParentChanged);
    // Listen for entity creation/deletion to update the list
    _entityChangeSubscription = widget.world.componentChanges.listen(_onEntityChanged);
  }

  @override
  void dispose() {
    _entityChangeSubscription?.cancel();
    _searchController.dispose();
    widget.selectedEntitiesNotifier.removeListener(_onExternalSelectionChanged);
    widget.viewedParentIdNotifier.removeListener(_onViewedParentChanged);
    super.dispose();
  }

  void _onEntityChanged(Change change) {
    // Rebuild when Name or HasParent components change (entity created/destroyed/reparented)
    if (change.componentType == 'Name' || change.componentType == 'HasParent') {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _onViewedParentChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onExternalSelectionChanged() {
    final selected = widget.selectedEntitiesNotifier.value;
    if (selected.isNotEmpty) {
      // Auto-expand path to the first selected entity
      final firstSelected = selected.first;
      _expandPathToEntity(firstSelected.id);
    }
  }

  /// Expand all ancestor nodes to make the given entity visible
  void _expandPathToEntity(int entityId) {
    var currentId = widget.world.hierarchyCache.getParent(entityId);
    var needsRebuild = false;

    while (currentId != null) {
      if (_expandedNodes[currentId] != true) {
        _expandedNodes[currentId] = true;
        needsRebuild = true;
      }
      currentId = widget.world.hierarchyCache.getParent(currentId);
    }

    if (needsRebuild && mounted) {
      setState(() {});
    }
  }

  /// Build the path from root to the given entity ID
  List<int> _buildPathToRoot(int? entityId) {
    if (entityId == null) return [];

    final path = <int>[];
    int? currentId = entityId;

    while (currentId != null) {
      path.insert(0, currentId);
      currentId = widget.world.hierarchyCache.getParent(currentId);
    }

    return path;
  }

  /// Sort entities based on current sort column and direction
  void _sortEntities(List<Entity> entities) {
    entities.sort((a, b) {
      int result;
      if (_sortColumn == _SortColumn.name) {
        final aName = a.get<Name>()?.name ?? '';
        final bName = b.get<Name>()?.name ?? '';
        result = aName.compareTo(bName);
        // If names are equal, fall back to ID
        if (result == 0) result = a.id.compareTo(b.id);
      } else {
        result = a.id.compareTo(b.id);
      }
      return _sortAscending ? result : -result;
    });
  }

  List<Entity> _getFilteredEntities(int? viewedParentId) {
    // Get the HasParent component map directly from the world
    final hasParentMap = widget.world.get<HasParent>();

    // Get all entities under the viewed parent
    var entities = widget.world.entities().where((e) {
      final hasParent = hasParentMap[e.id];
      if (viewedParentId == null) {
        // Show entities without a parent
        return hasParent == null;
      } else {
        // Show entities with matching parent
        return hasParent != null && hasParent.parentEntityId == viewedParentId;
      }
    }).toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      entities = entities.where((e) {
        final name = e.get<Name>()?.name.toLowerCase() ?? '';
        final id = e.id.toString();
        return name.contains(_searchQuery) || id.contains(_searchQuery);
      }).toList();
    }

    _sortEntities(entities);
    return entities;
  }

  /// Get all root entities (no parent)
  List<Entity> _getRootEntities() {
    // Get all entity IDs that have a HasParent component
    final hasParentMap = widget.world.get<HasParent>();
    final entitiesWithParent = hasParentMap.keys.toSet();

    // Root entities are those NOT in the hasParent map
    var entities = widget.world.entities().where((e) => !entitiesWithParent.contains(e.id)).toList();

    _sortEntities(entities);
    return entities;
  }

  void _selectEntity(Entity entity) {
    final current = widget.selectedEntitiesNotifier.value;
    // If clicking the only selected entity, deselect it
    if (current.length == 1 && current.contains(entity)) {
      widget.selectedEntitiesNotifier.value = {};
    } else {
      // Otherwise, select just this entity (clears any multi-selection)
      widget.selectedEntitiesNotifier.value = {entity};
    }
  }

  void _deleteSelected(Set<Entity> selected) {
    for (final entity in selected.toList()) {
      entity.destroy();
    }
    widget.selectedEntitiesNotifier.value = {};
  }

  void _toggleExpand(int entityId) {
    setState(() {
      _expandedNodes[entityId] = !(_expandedNodes[entityId] ?? false);
    });
  }

  void _handleNavigate(int? parentId) {
    widget.viewedParentIdNotifier.value = parentId;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: widget.viewedParentIdNotifier,
      builder: (context, viewedParentId, _) {
        return ValueListenableBuilder<Set<Entity>>(
          valueListenable: widget.selectedEntitiesNotifier,
          builder: (context, selectedEntities, _) {
            final selectableEntities = _getFilteredEntities(viewedParentId);

            return Column(
              children: [
                // Breadcrumb navigation
                _buildBreadcrumb(context, viewedParentId),
                // Search bar
                _buildSearchBar(context),
                // Toolbar
                _buildToolbar(context, selectableEntities, selectedEntities),
                // Column headers
                _buildColumnHeaders(context),
                // Entity tree or list
                Expanded(
                  child: _searchQuery.isNotEmpty
                      ? _buildFlatList(context, selectableEntities, selectedEntities)
                      : _buildTreeView(context, viewedParentId, selectedEntities),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBreadcrumb(BuildContext context, int? viewedParentId) {
    final colorScheme = Theme.of(context).colorScheme;
    final path = _buildPathToRoot(viewedParentId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Root button
                  _BreadcrumbSegment(
                    label: 'Root',
                    isActive: viewedParentId == null,
                    onTap: () => _handleNavigate(null),
                  ),
                  // Path segments
                  ...path.map((entityId) {
                    final entity = widget.world.getEntity(entityId);
                    final name = entity.get<Name>()?.name ?? '#$entityId';
                    final isCurrent = entityId == viewedParentId;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ' > ',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        _BreadcrumbSegment(
                          label: name,
                          isActive: isCurrent,
                          onTap: () => _handleNavigate(entityId),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          // Go up button (when not at root)
          if (viewedParentId != null) ...[
            const SizedBox(width: 4),
            Tooltip(
              message: 'Go up',
              child: InkWell(
                onTap: () {
                  final parentOfCurrent = widget.world.hierarchyCache.getParent(viewedParentId);
                  _handleNavigate(parentOfCurrent);
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.arrow_upward,
                    size: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 11),
        decoration: InputDecoration(
          hintText: 'Search by ID or name...',
          hintStyle: const TextStyle(fontSize: 11),
          prefixIcon: const Icon(Icons.search, size: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          isDense: true,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 14),
                  iconSize: 14,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, List<Entity> entities, Set<Entity> selectedEntities) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasSelection = selectedEntities.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Entity count
          Text(
            '${entities.length} entities',
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          // Delete selected (single entity)
          if (hasSelection)
            _ToolbarButton(
              icon: Icons.delete_outline,
              tooltip: 'Delete',
              color: colorScheme.error,
              onPressed: () => _showDeleteConfirmation(context, selectedEntities),
            ),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Spacer for expand arrow and icon
          const SizedBox(width: 44),
          // Name column header
          Expanded(
            child: _SortableColumnHeader(
              label: 'Name',
              isActive: _sortColumn == _SortColumn.name,
              ascending: _sortAscending,
              onTap: () {
                setState(() {
                  if (_sortColumn == _SortColumn.name) {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortColumn = _SortColumn.name;
                    _sortAscending = true;
                  }
                });
              },
            ),
          ),
          // ID column header
          SizedBox(
            width: 50,
            child: _SortableColumnHeader(
              label: 'ID',
              isActive: _sortColumn == _SortColumn.id,
              ascending: _sortAscending,
              onTap: () {
                setState(() {
                  if (_sortColumn == _SortColumn.id) {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortColumn = _SortColumn.id;
                    _sortAscending = true;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Set<Entity> selected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entities'),
        content: Text('Delete ${selected.length} selected entities?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteSelected(selected);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeView(BuildContext context, int? viewedParentId, Set<Entity> selectedEntities) {
    final rootEntities = _getRootEntities();

    if (rootEntities.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 2),
      children: rootEntities.map((entity) {
        return EntityTreeNode(
          entity: entity,
          world: widget.world,
          viewedParentId: viewedParentId,
          selectedEntities: selectedEntities,
          expandedNodes: _expandedNodes,
          depth: 0,
          onToggleExpand: _toggleExpand,
          onSelect: _selectEntity,
          onNavigate: _handleNavigate,
        );
      }).toList(),
    );
  }

  Widget _buildFlatList(BuildContext context, List<Entity> entities, Set<Entity> selectedEntities) {
    if (entities.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 2),
      itemCount: entities.length,
      itemBuilder: (context, index) {
        final entity = entities[index];
        final isSelected = selectedEntities.contains(entity);
        return _EntityListItem(
          entity: entity,
          isSelected: isSelected,
          onTap: () => _selectEntity(entity),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 32,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty ? 'No entities' : 'No matches',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreadcrumbSegment extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BreadcrumbSegment({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SortableColumnHeader extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool ascending;
  final VoidCallback onTap;

  const _SortableColumnHeader({
    required this.label,
    required this.isActive,
    required this.ascending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 2),
              Icon(
                ascending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 16,
            color: color ?? colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _EntityListItem extends StatelessWidget {
  final Entity entity;
  final bool isSelected;
  final VoidCallback onTap;

  const _EntityListItem({
    required this.entity,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = entity.get<Name>()?.name ?? 'Entity #${entity.id}';
    final renderable = entity.get<Renderable>();

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              // Icon from Renderable asset or generic fallback
              SizedBox(
                width: 16,
                height: 16,
                child: renderable != null && renderable.asset is ImageAsset
                    ? SvgPicture.asset(
                        'assets/${(renderable.asset as ImageAsset).svgAssetPath}',
                        width: 14,
                        height: 14,
                        fit: BoxFit.contain,
                      )
                    : Icon(
                        renderable?.asset is TextAsset
                            ? Icons.text_fields
                            : Icons.widgets_outlined,
                        size: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
              ),
              const SizedBox(width: 6),
              // Name
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // ID
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
      ),
    );
  }
}
