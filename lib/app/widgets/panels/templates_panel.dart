import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/widgets/overlays/template_panel/template_card.dart';

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
  String _searchQuery = '';

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
    super.dispose();
  }

  /// Gets all template entities (entities with IsTemplate component).
  List<Entity> _getTemplateEntities() {
    final query = Query().require<IsTemplate>();
    var templates = query.find(widget.world).toList();

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
    return Column(
      children: [
        // Top action buttons
        _buildTopActions(context),
        // Search bar
        _buildSearchBar(context),
        // Template grid
        Expanded(
          child: Builder(
            builder: (context) {
              final templates = _getTemplateEntities();
              return _buildTemplateGrid(context, templates);
            },
          ),
        ),
      ],
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

            return TemplateCard(
              templateEntity: templateEntity,
              isSelected: isSelected,
              onTap: () {
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

    // Replace the IsTemplate component with new display name
    final newComponents = components
        .where((c) => c is! IsTemplate)
        .toList();
    newComponents.add(IsTemplate(displayName: newName));

    widget.world.add(newComponents);

    // Save the world state
    await WorldSaves.writeInitialState(widget.world);

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
      await WorldSaves.writeInitialState(widget.world);

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
