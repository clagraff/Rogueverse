import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/widgets/keyboard/menu_keyboard_navigation.dart';
import 'package:rogueverse/app/widgets/overlays/template_panel/template_card.dart';

/// Filter tabs for the templates panel.
enum TemplateFilter {
  all,
  items,
}

/// Panel for browsing, searching, and selecting entity templates.
///
/// Displays a searchable grid of template entities (entities with IsTemplate)
/// that can be selected for placement in the game world.
class TemplatesPanel extends StatefulWidget {
  final World world;
  final ValueNotifier<int?> selectedTemplateIdNotifier;
  final void Function(Entity)? onEditTemplate;
  final VoidCallback? onCreateTemplate;

  const TemplatesPanel({
    super.key,
    required this.world,
    required this.selectedTemplateIdNotifier,
    this.onEditTemplate,
    this.onCreateTemplate,
  });

  @override
  State<TemplatesPanel> createState() => _TemplatesPanelState();
}

class _TemplatesPanelState extends State<TemplatesPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';
  TemplateFilter _filter = TemplateFilter.all;
  int _focusedIndex = 0;

  /// Number of columns in the grid (must match GridView's crossAxisCount).
  static const int _gridColumnCount = 4;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    // Listen to component changes to rebuild when templates are added/removed/modified
    widget.world.componentChanges.listen((change) {
      if (change.componentType == 'IsTemplate') {
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    // Don't handle keys if search field has focus
    if (FocusManager.instance.primaryFocus != _focusNode) return;

    final templates = _getTemplateEntities();
    if (templates.isEmpty) return;

    final nav = MenuKeyboardNavigation(
      itemCount: templates.length,
      selectedIndex: _focusedIndex,
      columnCount: _gridColumnCount,
      onIndexChanged: (index) {
        setState(() {
          _focusedIndex = index.clamp(0, templates.length - 1);
        });
      },
      onActivate: () {
        if (_focusedIndex >= 0 && _focusedIndex < templates.length) {
          final template = templates[_focusedIndex];
          final currentSelected = widget.selectedTemplateIdNotifier.value;
          // Toggle selection
          if (currentSelected == template.id) {
            widget.selectedTemplateIdNotifier.value = null;
          } else {
            widget.selectedTemplateIdNotifier.value = template.id;
          }
        }
      },
      onBack: () {
        // Deselect if selected, otherwise do nothing
        if (widget.selectedTemplateIdNotifier.value != null) {
          widget.selectedTemplateIdNotifier.value = null;
        }
      },
      onDelete: () {
        if (_focusedIndex >= 0 && _focusedIndex < templates.length) {
          _deleteTemplate(context, templates[_focusedIndex]);
        }
      },
    );

    nav.handleKeyEvent(event);
  }

  /// Gets all template entities (entities with IsTemplate component).
  List<Entity> _getTemplateEntities() {
    final query = Query().require<IsTemplate>();
    var templates = query.find(widget.world).toList();

    // Filter by tab selection
    if (_filter == TemplateFilter.items) {
      templates = templates.where((entity) => entity.has<Item>()).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      templates = templates.where((entity) {
        final isTemplate = entity.get<IsTemplate>();
        return isTemplate?.displayName.toLowerCase().contains(lowerQuery) ?? false;
      }).toList();
    }

    // Sort by display name
    templates.sort((a, b) {
      final nameA = a.get<IsTemplate>()?.displayName ?? '';
      final nameB = b.get<IsTemplate>()?.displayName ?? '';
      return nameA.compareTo(nameB);
    });

    return templates;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            // Top action buttons
            _buildTopActions(context),
            // Filter tabs
            _buildFilterTabs(context),
            // Search bar
            _buildSearchBar(context),
            // Template grid
            Expanded(
              child: Builder(
                builder: (context) {
                  final templates = _getTemplateEntities();
                  // Clamp focused index when templates change
                  if (_focusedIndex >= templates.length && templates.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _focusedIndex = templates.length - 1;
                        });
                      }
                    });
                  }
                  return _buildTemplateGrid(context, templates);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          _buildFilterTab(
            context,
            filter: TemplateFilter.all,
            icon: Icons.apps,
            tooltip: 'All templates',
          ),
          const SizedBox(width: 4),
          _buildFilterTab(
            context,
            filter: TemplateFilter.items,
            icon: Icons.inventory_2_outlined,
            tooltip: 'Items only',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    BuildContext context, {
    required TemplateFilter filter,
    required IconData icon,
    required String tooltip,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _filter == filter;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          setState(() {
            _filter = filter;
          });
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primaryContainer : null,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
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
          hintText: 'Search templates...',
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

  Widget _buildTemplateGrid(BuildContext context, List<Entity> templates) {
    if (templates.isEmpty) {
      return _buildEmptyState(context);
    }

    return ValueListenableBuilder<int?>(
      valueListenable: widget.selectedTemplateIdNotifier,
      builder: (context, selectedTemplateId, child) {
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 0.9,
          ),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final templateEntity = templates[index];
            final isSelected = selectedTemplateId == templateEntity.id;
            final isFocused = index == _focusedIndex && _focusNode.hasFocus;

            return TemplateCard(
              templateEntity: templateEntity,
              isSelected: isSelected,
              isFocused: isFocused,
              onTap: () {
                // Update focused index on click
                setState(() {
                  _focusedIndex = index;
                });
                _focusNode.requestFocus();
                if (isSelected) {
                  widget.selectedTemplateIdNotifier.value = null;
                } else {
                  widget.selectedTemplateIdNotifier.value = templateEntity.id;
                }
              },
              onEdit: () {
                widget.onEditTemplate?.call(templateEntity);
              },
              onDuplicate: () => _duplicateTemplate(context, templateEntity),
              onDelete: () => _deleteTemplate(context, templateEntity),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 28,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isEmpty ? 'No templates' : 'No matches',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.onCreateTemplate == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: widget.onCreateTemplate,
        icon: const Icon(Icons.add, size: 14),
        label: const Text('Create Template', style: TextStyle(fontSize: 11)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          minimumSize: const Size(0, 28),
        ),
      ),
    );
  }

  Future<void> _duplicateTemplate(BuildContext context, Entity templateEntity) async {
    final isTemplate = templateEntity.get<IsTemplate>();
    if (isTemplate == null) return;

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => _DuplicateTemplateDialog(
        originalName: isTemplate.displayName,
      ),
    );

    if (newName == null || newName.isEmpty) return;

    // Create a new template entity with copied components
    final components = templateEntity.getAll()
        .where((c) => c is! LocalPosition && c is! HasParent && c is! FromTemplate)
        .toList();

    // Replace the IsTemplate and Name components with new display name
    final newComponents = components
        .where((c) => c is! IsTemplate && c is! Name)
        .toList();
    newComponents.add(IsTemplate(displayName: newName));
    newComponents.add(Name(name: newName));

    widget.world.add(newComponents);

    // Save the world state
    await Persistence.writeInitialState(widget.world);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created "$newName"'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteTemplate(BuildContext context, Entity templateEntity) async {
    final isTemplate = templateEntity.get<IsTemplate>();
    if (isTemplate == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${isTemplate.displayName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      templateEntity.destroy();

      // Save the world state
      await Persistence.writeInitialState(widget.world);

      if (widget.selectedTemplateIdNotifier.value == templateEntity.id) {
        widget.selectedTemplateIdNotifier.value = null;
      }
    }
  }
}

/// Dialog for entering a name when duplicating a template.
class _DuplicateTemplateDialog extends StatefulWidget {
  final String originalName;

  const _DuplicateTemplateDialog({required this.originalName});

  @override
  State<_DuplicateTemplateDialog> createState() => _DuplicateTemplateDialogState();
}

class _DuplicateTemplateDialogState extends State<_DuplicateTemplateDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final defaultName = '${widget.originalName} (Copy)';
    _controller = TextEditingController(text: defaultName);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: defaultName.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Duplicate Template'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Template Name',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Duplicate'),
        ),
      ],
    );
  }
}
