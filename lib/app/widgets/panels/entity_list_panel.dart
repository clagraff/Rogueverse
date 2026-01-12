import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rogueverse/ecs/ecs.dart';

/// Panel for browsing, searching, and selecting entities under the current viewed parent.
///
/// Features:
/// - Search bar to filter by entity ID or name
/// - Checkbox multi-select that syncs with selectedEntitiesNotifier
/// - Toolbar with Select All, Deselect All, Delete buttons
/// - Click entity row to single-select for editing
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Entity> _getFilteredEntities(int? viewedParentId) {
    // Get all entities under the viewed parent
    var entities = widget.world.entities().where((e) {
      if (viewedParentId == null) {
        // Show entities without a parent
        return !e.has<HasParent>();
      } else {
        // Show entities with matching parent
        final hasParent = e.get<HasParent>();
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

    // Sort by name, then by ID
    entities.sort((a, b) {
      final aName = a.get<Name>()?.name ?? '';
      final bName = b.get<Name>()?.name ?? '';
      if (aName.isNotEmpty && bName.isNotEmpty) {
        return aName.compareTo(bName);
      }
      return a.id.compareTo(b.id);
    });

    return entities;
  }

  void _toggleEntitySelection(Entity entity, Set<Entity> currentSelection) {
    final newSelection = Set<Entity>.from(currentSelection);
    if (newSelection.contains(entity)) {
      newSelection.remove(entity);
    } else {
      newSelection.add(entity);
    }
    widget.selectedEntitiesNotifier.value = newSelection;
  }

  void _selectSingleEntity(Entity entity) {
    widget.selectedEntitiesNotifier.value = {entity};
  }

  void _selectAll(List<Entity> entities) {
    widget.selectedEntitiesNotifier.value = entities.toSet();
  }

  void _deselectAll() {
    widget.selectedEntitiesNotifier.value = {};
  }

  void _deleteSelected(Set<Entity> selected) {
    for (final entity in selected.toList()) {
      entity.destroy();
    }
    widget.selectedEntitiesNotifier.value = {};
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: widget.viewedParentIdNotifier,
      builder: (context, viewedParentId, _) {
        return ValueListenableBuilder<Set<Entity>>(
          valueListenable: widget.selectedEntitiesNotifier,
          builder: (context, selectedEntities, _) {
            final entities = _getFilteredEntities(viewedParentId);

            return Column(
              children: [
                // Search bar
                _buildSearchBar(context),
                // Toolbar
                _buildToolbar(context, entities, selectedEntities),
                // Entity list
                Expanded(
                  child: entities.isEmpty
                      ? _buildEmptyState(context)
                      : _buildEntityList(context, entities, selectedEntities),
                ),
              ],
            );
          },
        );
      },
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
    final allSelected = entities.isNotEmpty &&
        entities.every((e) => selectedEntities.contains(e));

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
          if (hasSelection) ...[
            Text(
              ' (${selectedEntities.length} selected)',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.primary,
              ),
            ),
          ],
          const Spacer(),
          // Select all / Deselect all
          if (entities.isNotEmpty) ...[
            _ToolbarButton(
              icon: allSelected ? Icons.deselect : Icons.select_all,
              tooltip: allSelected ? 'Deselect All' : 'Select All',
              onPressed: () {
                if (allSelected) {
                  _deselectAll();
                } else {
                  _selectAll(entities);
                }
              },
            ),
          ],
          // Delete selected
          if (hasSelection) ...[
            const SizedBox(width: 4),
            _ToolbarButton(
              icon: Icons.delete_outline,
              tooltip: 'Delete Selected',
              color: colorScheme.error,
              onPressed: () => _showDeleteConfirmation(context, selectedEntities),
            ),
          ],
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

  Widget _buildEntityList(BuildContext context, List<Entity> entities, Set<Entity> selectedEntities) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 2),
      itemCount: entities.length,
      itemBuilder: (context, index) {
        final entity = entities[index];
        final isSelected = selectedEntities.contains(entity);
        return _EntityListItem(
          entity: entity,
          isSelected: isSelected,
          onCheckboxChanged: () => _toggleEntitySelection(entity, selectedEntities),
          onTap: () => _selectSingleEntity(entity),
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
  final VoidCallback onCheckboxChanged;
  final VoidCallback onTap;

  const _EntityListItem({
    required this.entity,
    required this.isSelected,
    required this.onCheckboxChanged,
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
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(
            children: [
              // Checkbox
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onCheckboxChanged(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 4),
              // Icon from Renderable asset or generic fallback
              SizedBox(
                width: 16,
                height: 16,
                child: renderable != null
                    ? SvgPicture.asset(
                        'assets/${renderable.svgAssetPath}',
                        width: 14,
                        height: 14,
                        fit: BoxFit.contain,
                      )
                    : Icon(
                        Icons.widgets_outlined,
                        size: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
              ),
              const SizedBox(width: 4),
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
