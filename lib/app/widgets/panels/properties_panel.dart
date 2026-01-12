import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_section.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/sections/sections.dart';

/// Panel showing the currently selected entity's components for editing.
///
/// Displays all components on the selected entity with editable fields,
/// and provides buttons to add new components or save as template.
class PropertiesPanel extends StatefulWidget {
  final ValueNotifier<Entity?> entityNotifier;

  const PropertiesPanel({
    super.key,
    required this.entityNotifier,
  });

  @override
  State<PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<PropertiesPanel> {
  @override
  void initState() {
    super.initState();
    _registerAllComponents();
  }

  /// Registers all component metadata with the registry.
  void _registerAllComponents() {
    if (ComponentRegistry.getAll().isEmpty) {
      // Core gameplay components
      ComponentRegistry.register(NameMetadata());
      ComponentRegistry.register(LocalPositionMetadata());
      ComponentRegistry.register(DirectionMetadata());
      ComponentRegistry.register(HealthMetadata());
      ComponentRegistry.register(RenderableMetadata());

      // Hierarchy components
      ComponentRegistry.register(HasParentMetadata());

      // Inventory components
      ComponentRegistry.register(InventoryMetadata());
      ComponentRegistry.register(InventoryMaxCountMetadata());
      ComponentRegistry.register(PickupIntentMetadata());
      ComponentRegistry.register(PickedUpMetadata());
      ComponentRegistry.register(InventoryFullFailureMetadata());

      // Marker components (tags with no data)
      ComponentRegistry.register(AiControlledMetadata());
      ComponentRegistry.register(BlocksMovementMetadata());
      ComponentRegistry.register(PickupableMetadata());
      ComponentRegistry.register(DeadMetadata());

      // Vision components
      ComponentRegistry.register(VisionRadiusMetadata());
      ComponentRegistry.register(VisibleEntitiesMetadata());
      ComponentRegistry.register(VisionMemoryMetadata());
      ComponentRegistry.register(BlocksSightMetadata());

      // Combat components
      ComponentRegistry.register(AttackIntentMetadata());
      ComponentRegistry.register(DidAttackMetadata());
      ComponentRegistry.register(WasAttackedMetadata());

      // Portal components
      ComponentRegistry.register(PortalToPositionMetadata());
      ComponentRegistry.register(PortalToAnchorMetadata());
      ComponentRegistry.register(PortalAnchorMetadata());
      ComponentRegistry.register(UsePortalIntentMetadata());
      ComponentRegistry.register(DidPortalMetadata());
      ComponentRegistry.register(FailedToPortalMetadata());

      // Control components
      ComponentRegistry.register(ControllableMetadata());
      ComponentRegistry.register(ControllingMetadata());
      ComponentRegistry.register(EnablesControlMetadata());
      ComponentRegistry.register(DockedMetadata());
      ComponentRegistry.register(WantsControlIntentMetadata());
      ComponentRegistry.register(ReleasesControlIntentMetadata());
      ComponentRegistry.register(DockIntentMetadata());
      ComponentRegistry.register(UndockIntentMetadata());

      // Openable components
      ComponentRegistry.register(OpenableMetadata());
      ComponentRegistry.register(OpenIntentMetadata());
      ComponentRegistry.register(CloseIntentMetadata());
      ComponentRegistry.register(DidOpenMetadata());
      ComponentRegistry.register(DidCloseMetadata());

      // AI/Behavior components
      ComponentRegistry.register(BehaviorMetadata());

      // Transient event components (for debugging)
      ComponentRegistry.register(MoveByIntentMetadata());
      ComponentRegistry.register(DidMoveMetadata());
      ComponentRegistry.register(BlockedMoveMetadata());

      // Lifecycle components
      ComponentRegistry.register(LifetimeMetadata());
      ComponentRegistry.register(BeforeTickMetadata());
      ComponentRegistry.register(AfterTickMetadata());

      // Grid components
      ComponentRegistry.register(CellMetadata());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section header
        _buildSectionHeader(context),
        // Component list
        Expanded(
          child: ValueListenableBuilder<Entity?>(
            valueListenable: widget.entityNotifier,
            builder: (context, entity, _) {
              if (entity == null) {
                return _buildEmptyState(context);
              }

              return StreamBuilder<Change>(
                stream: entity.parentCell.componentChanges.onEntityChange(entity.id),
                builder: (context, snapshot) {
                  final presentComponents = ComponentRegistry.getPresent(entity)
                    ..sort((a, b) => a.componentName.compareTo(b.componentName));

                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    children: [
                      ...presentComponents.map(
                        (metadata) => ComponentSection(
                          entity: entity,
                          metadata: metadata,
                        ),
                      ),
                      _AddComponentButton(entity: entity),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          Text(
            'Properties',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          // Save as template button (only shown when entity selected)
          ValueListenableBuilder<Entity?>(
            valueListenable: widget.entityNotifier,
            builder: (context, entity, _) {
              if (entity == null) return const SizedBox.shrink();
              return _SaveAsTemplateButton(entity: entity);
            },
          ),
        ],
      ),
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
              Icons.touch_app_outlined,
              size: 32,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No entity selected',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Click an entity to edit',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Button that saves the current entity as a new template.
class _SaveAsTemplateButton extends StatelessWidget {
  final Entity entity;

  const _SaveAsTemplateButton({required this.entity});

  Future<void> _saveAsTemplate(BuildContext context) async {
    final nameComponent = entity.get<Name>();
    final defaultName = nameComponent?.name ?? 'New Template';

    final templateName = await showDialog<String>(
      context: context,
      builder: (context) => _TemplateNameDialog(defaultName: defaultName),
    );

    if (templateName == null || templateName.isEmpty) return;

    final template = EntityTemplate.fromEntity(
      id: TemplateRegistry.instance.generateId(),
      displayName: templateName,
      entity: entity,
    );

    await TemplateRegistry.instance.save(template);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved template "$templateName"'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Save as Template',
      child: InkWell(
        onTap: () => _saveAsTemplate(context),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            Icons.save_outlined,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Dialog for entering the template name when saving.
class _TemplateNameDialog extends StatefulWidget {
  final String defaultName;

  const _TemplateNameDialog({required this.defaultName});

  @override
  State<_TemplateNameDialog> createState() => _TemplateNameDialogState();
}

class _TemplateNameDialogState extends State<_TemplateNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultName);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.defaultName.length,
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
      title: const Text('Save as Template'),
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
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Button that opens a searchable dialog to add new components to the entity.
class _AddComponentButton extends StatelessWidget {
  final Entity entity;

  const _AddComponentButton({required this.entity});

  Future<void> _showAddComponentDialog(BuildContext context) async {
    final available = ComponentRegistry.getAvailable(entity)
      ..sort((a, b) => a.componentName.compareTo(b.componentName));

    if (available.isEmpty) return;

    final selected = await showDialog<ComponentMetadata>(
      context: context,
      builder: (context) => _AddComponentDialog(availableComponents: available),
    );

    if (selected != null && context.mounted) {
      final component = selected.createDefault();
      entity.upsertByName(component);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${selected.componentName}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = ComponentRegistry.getAvailable(entity);

    if (available.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: InkWell(
        onTap: () => _showAddComponentDialog(context),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                size: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Add Component',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for searching and selecting a component to add.
class _AddComponentDialog extends StatefulWidget {
  final List<ComponentMetadata> availableComponents;

  const _AddComponentDialog({required this.availableComponents});

  @override
  State<_AddComponentDialog> createState() => _AddComponentDialogState();
}

class _AddComponentDialogState extends State<_AddComponentDialog> {
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

  List<ComponentMetadata> get _filteredComponents {
    if (_searchQuery.isEmpty) {
      return widget.availableComponents;
    }
    return widget.availableComponents
        .where((c) => c.componentName.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filtered = _filteredComponents;

    return AlertDialog(
      title: const Text('Add Component'),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SizedBox(
        width: 300,
        height: 400,
        child: Column(
          children: [
            // Search field
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search components...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            // Component list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No matching components',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final metadata = filtered[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            metadata.componentName,
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () => Navigator.of(context).pop(metadata),
                          hoverColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
