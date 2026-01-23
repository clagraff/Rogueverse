import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/ui_constants.dart';
import 'package:rogueverse/app/widgets/keyboard/menu_keyboard_navigation.dart';

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
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';
  final Map<int, bool> _expandedNodes = {};
  StreamSubscription<Change>? _entityChangeSubscription;
  _SortColumn _sortColumn = _SortColumn.id;
  bool _sortAscending = true;
  int? _focusedEntityId;

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
    _focusNode.dispose();
    widget.selectedEntitiesNotifier.removeListener(_onExternalSelectionChanged);
    widget.viewedParentIdNotifier.removeListener(_onViewedParentChanged);
    super.dispose();
  }

  /// Build a flat list of visible entities in tree order for keyboard navigation.
  List<Entity> _buildVisibleEntityList() {
    final visible = <Entity>[];
    final rootEntities = _getRootEntities();

    void addVisibleChildren(Entity entity, int depth) {
      visible.add(entity);
      if (_expandedNodes[entity.id] == true) {
        final hasParentMap = widget.world.get<HasParent>();
        final childIds = hasParentMap.entries
            .where((e) => e.value.parentEntityId == entity.id)
            .map((e) => e.key)
            .toList();

        // Sort children same as the main list
        final children = childIds.map((id) => widget.world.getEntity(id)).toList();
        _sortEntities(children);

        for (final child in children) {
          addVisibleChildren(child, depth + 1);
        }
      }
    }

    for (final root in rootEntities) {
      addVisibleChildren(root, 0);
    }

    return visible;
  }

  void _handleKeyEvent(KeyEvent event) {
    // Don't handle keys if search field has focus
    if (FocusManager.instance.primaryFocus != _focusNode) return;

    final visibleEntities = _searchQuery.isNotEmpty
        ? _getFilteredEntities(widget.viewedParentIdNotifier.value)
        : _buildVisibleEntityList();

    if (visibleEntities.isEmpty) return;

    // Find current index
    final currentIndex = _focusedEntityId != null
        ? visibleEntities.indexWhere((e) => e.id == _focusedEntityId)
        : -1;
    final safeIndex = currentIndex == -1 ? 0 : currentIndex;

    final nav = MenuKeyboardNavigation(
      itemCount: visibleEntities.length,
      selectedIndex: safeIndex,
      onIndexChanged: (index) {
        setState(() {
          _focusedEntityId = visibleEntities[index].id;
        });
      },
      onActivate: () {
        if (safeIndex >= 0 && safeIndex < visibleEntities.length) {
          _selectEntity(visibleEntities[safeIndex]);
        }
      },
      onBack: () {
        // Deselect if selected
        if (widget.selectedEntitiesNotifier.value.isNotEmpty) {
          widget.selectedEntitiesNotifier.value = {};
        }
      },
      onDelete: () {
        final selected = widget.selectedEntitiesNotifier.value;
        if (selected.isNotEmpty) {
          _showDeleteConfirmation(context, selected);
        }
      },
      onLeft: () {
        // Collapse current node or go to parent
        if (_focusedEntityId != null) {
          if (_expandedNodes[_focusedEntityId!] == true) {
            // Collapse current node
            setState(() {
              _expandedNodes[_focusedEntityId!] = false;
            });
          } else {
            // Go to parent
            final parentId = widget.world.hierarchyCache.getParent(_focusedEntityId!);
            if (parentId != null) {
              setState(() {
                _focusedEntityId = parentId;
              });
            }
          }
        }
      },
      onRight: () {
        // Expand current node
        if (_focusedEntityId != null) {
          final hasParentMap = widget.world.get<HasParent>();
          final hasChildren = hasParentMap.values.any((hp) => hp.parentEntityId == _focusedEntityId);
          if (hasChildren) {
            setState(() {
              _expandedNodes[_focusedEntityId!] = true;
            });
          }
        }
      },
    );

    nav.handleKeyEvent(event);
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

    // Get all entities under the viewed parent (excluding templates)
    var entities = widget.world.entities().where((e) {
      // Exclude template entities - they're shown in the Templates panel
      if (e.has<IsTemplate>()) return false;

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

  /// Get all root entities (no parent, excluding templates)
  List<Entity> _getRootEntities() {
    // Get all entity IDs that have a HasParent component
    final hasParentMap = widget.world.get<HasParent>();
    final entitiesWithParent = hasParentMap.keys.toSet();

    // Root entities are those NOT in the hasParent map and NOT templates
    var entities = widget.world.entities().where((e) {
      if (e.has<IsTemplate>()) return false;
      return !entitiesWithParent.contains(e.id);
    }).toList();

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
    final colorScheme = Theme.of(context).colorScheme;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        behavior: HitTestBehavior.translucent,
        child: ValueListenableBuilder<int?>(
          valueListenable: widget.viewedParentIdNotifier,
          builder: (context, viewedParentId, _) {
            return ValueListenableBuilder<Set<Entity>>(
              valueListenable: widget.selectedEntitiesNotifier,
              builder: (context, selectedEntities, _) {
                final selectableEntities = _getFilteredEntities(viewedParentId);

                return Column(
                  children: [
                    // Breadcrumb navigation
                    _buildBreadcrumb(colorScheme, viewedParentId),
                    // Search bar
                    _buildSearchBar(colorScheme),
                    // Toolbar
                    _buildToolbar(colorScheme, selectableEntities, selectedEntities),
                    // Column headers
                    _buildColumnHeaders(colorScheme),
                    // Entity tree or list
                    Expanded(
                      child: _searchQuery.isNotEmpty
                          ? _buildFlatList(colorScheme, selectableEntities, selectedEntities)
                          : _buildTreeView(colorScheme, viewedParentId, selectedEntities),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(ColorScheme colorScheme, int? viewedParentId) {
    final path = _buildPathToRoot(viewedParentId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingM, vertical: kSpacingS),
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
          const SizedBox(width: kSpacingS),
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
                    colorScheme: colorScheme,
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
                          colorScheme: colorScheme,
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
            const SizedBox(width: kSpacingS),
            Tooltip(
              message: 'Go up',
              child: InkWell(
                onTap: () {
                  final parentOfCurrent = widget.world.hierarchyCache.getParent(viewedParentId);
                  _handleNavigate(parentOfCurrent);
                },
                borderRadius: BorderRadius.circular(kRadiusS),
                child: Padding(
                  padding: const EdgeInsets.all(kSpacingS),
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

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(kSpacingM),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 11),
        decoration: InputDecoration(
          hintText: 'Search by ID or name...',
          hintStyle: const TextStyle(fontSize: 11),
          prefixIcon: const Icon(Icons.search, size: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadiusM),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: kSpacingM, vertical: kSpacingS),
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

  Widget _buildToolbar(ColorScheme colorScheme, List<Entity> entities, Set<Entity> selectedEntities) {
    final hasSelection = selectedEntities.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingM, vertical: kSpacingS),
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

  Widget _buildColumnHeaders(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingM, vertical: kSpacingS),
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
              colorScheme: colorScheme,
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
              colorScheme: colorScheme,
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
    final colorScheme = Theme.of(context).colorScheme;
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
              foregroundColor: colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeView(ColorScheme colorScheme, int? viewedParentId, Set<Entity> selectedEntities) {
    final rootEntities = _getRootEntities();

    if (rootEntities.isEmpty) {
      return _buildEmptyState(colorScheme);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: kSpacingXS),
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
          focusedEntityId: _focusNode.hasFocus ? _focusedEntityId : null,
        );
      }).toList(),
    );
  }

  Widget _buildFlatList(ColorScheme colorScheme, List<Entity> entities, Set<Entity> selectedEntities) {
    if (entities.isEmpty) {
      return _buildEmptyState(colorScheme);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: kSpacingXS),
      itemCount: entities.length,
      itemBuilder: (context, index) {
        final entity = entities[index];
        final isSelected = selectedEntities.contains(entity);
        final isFocused = _focusNode.hasFocus && _focusedEntityId == entity.id;
        return _EntityListItem(
          entity: entity,
          isSelected: isSelected,
          isFocused: isFocused,
          colorScheme: colorScheme,
          onTap: () {
            setState(() {
              _focusedEntityId = entity.id;
            });
            _selectEntity(entity);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 32,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: kSpacingM),
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
  final ColorScheme colorScheme;

  const _BreadcrumbSegment({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kRadiusS),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSpacingS, vertical: kSpacingXS),
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
  final ColorScheme colorScheme;

  const _SortableColumnHeader({
    required this.label,
    required this.isActive,
    required this.ascending,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kRadiusS),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSpacingXS, vertical: kSpacingXS),
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
              const SizedBox(width: kSpacingXS),
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
        borderRadius: BorderRadius.circular(kRadiusS),
        child: Padding(
          padding: const EdgeInsets.all(kSpacingS),
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
  final bool isFocused;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _EntityListItem({
    required this.entity,
    required this.isSelected,
    this.isFocused = false,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final name = entity.get<Name>()?.name ?? 'Entity #${entity.id}';
    final renderable = entity.get<Renderable>();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : isFocused
                    ? colorScheme.primaryContainer.withValues(alpha: 0.15)
                    : Colors.transparent,
            border: isFocused
                ? Border(
                    left: BorderSide(
                      color: colorScheme.primary,
                      width: 3,
                    ),
                  )
                : null,
          ),
          padding: EdgeInsets.only(
            left: isFocused ? 3 : kSpacingM,
            right: kSpacingM,
            top: kSpacingS,
            bottom: kSpacingS,
          ),
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
              const SizedBox(width: kSpacingM),
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
