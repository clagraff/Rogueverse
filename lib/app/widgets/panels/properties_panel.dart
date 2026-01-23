import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_section.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/inherited_component_section.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/sections/sections.dart';

/// Panel showing the currently selected entity's components for editing.
///
/// Displays all components on the selected entity with editable fields,
/// and provides buttons to add new components or save as template.
class PropertiesPanel extends StatefulWidget {
  final ValueNotifier<Entity?> entityNotifier;
  final ValueNotifier<Set<Entity>>? selectedEntitiesNotifier;

  const PropertiesPanel({
    super.key,
    required this.entityNotifier,
    this.selectedEntitiesNotifier,
  });

  @override
  State<PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<PropertiesPanel> {
  final ValueNotifier<bool> _showTransient = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _registerAllComponents();
  }

  @override
  void dispose() {
    _showTransient.dispose();
    super.dispose();
  }

  /// Registers all component metadata with the registry.
  void _registerAllComponents() {
    // Register all components (registry handles duplicates via map overwrite)
    // Core gameplay components
    ComponentRegistry.register(NameMetadata());
    ComponentRegistry.register(LocalPositionMetadata());
    ComponentRegistry.register(DirectionMetadata());
    ComponentRegistry.register(HealthMetadata());
    ComponentRegistry.register(RenderableMetadata());
    ComponentRegistry.register(EditorRenderableMetadata());

    // Hierarchy components
    ComponentRegistry.register(HasParentMetadata());

    // Inventory components
    ComponentRegistry.register(InventoryMetadata());
    ComponentRegistry.register(InventoryMaxCountMetadata());
    ComponentRegistry.register(PickupIntentMetadata());
    ComponentRegistry.register(PickedUpMetadata());
    ComponentRegistry.register(InventoryFullFailureMetadata());

    // Item components
    ComponentRegistry.register(ItemMetadata());
    ComponentRegistry.register(DescriptionMetadata());
    ComponentRegistry.register(LootTableMetadata());

    // Marker components (tags with no data)
    ComponentRegistry.register(AiControlledMetadata());
    ComponentRegistry.register(BlocksMovementMetadata());
    ComponentRegistry.register(PickupableMetadata());
    ComponentRegistry.register(DeadMetadata());
    ComponentRegistry.register(PlayerMetadata());

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

    // Dialog components
    ComponentRegistry.register(DialogMetadata());

    // Transient event components (for debugging)
    ComponentRegistry.register(MoveByIntentMetadata());
    ComponentRegistry.register(DidMoveMetadata());
    ComponentRegistry.register(BlockedMoveMetadata());
    ComponentRegistry.register(DirectionIntentMetadata());
    ComponentRegistry.register(DidChangeDirectionMetadata());

    // Lifecycle components
    ComponentRegistry.register(LifetimeMetadata());
    ComponentRegistry.register(BeforeTickMetadata());
    ComponentRegistry.register(AfterTickMetadata());

    // Grid components
    ComponentRegistry.register(CellMetadata());

    // Template components
    ComponentRegistry.register(IsTemplateMetadata());
    ComponentRegistry.register(FromTemplateMetadata());
  }

  @override
  Widget build(BuildContext context) {
    // If multi-select notifier is provided, wrap in builder to check selection count
    if (widget.selectedEntitiesNotifier != null) {
      return ValueListenableBuilder<Set<Entity>>(
        valueListenable: widget.selectedEntitiesNotifier!,
        builder: (context, selectedEntities, _) {
          if (selectedEntities.length > 1) {
            return ValueListenableBuilder<bool>(
              valueListenable: _showTransient,
              builder: (context, showTransientValue, _) {
                return Column(
                  children: [
                    _buildSectionHeader(context, showTransientValue),
                    Expanded(child: _buildMultiSelectState(context, selectedEntities.length)),
                  ],
                );
              },
            );
          }
          return _buildMainContent(context);
        },
      );
    }
    return _buildMainContent(context);
  }

  Widget _buildMainContent(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _showTransient,
      builder: (context, showTransientValue, _) {
        return Column(
          children: [
            // Section header
            _buildSectionHeader(context, showTransientValue),
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
                      // Check if entity has a template
                      final hasTemplate = entity.getTemplateEntity() != null;

                      if (hasTemplate) {
                        return _buildSplitView(
                          context,
                          entity,
                          showTransientValue,
                        );
                      } else {
                        return _buildFlatView(
                          context,
                          entity,
                          showTransientValue,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the flat view for entities without templates (original behavior).
  Widget _buildFlatView(
    BuildContext context,
    Entity entity,
    bool showTransient,
  ) {
    var presentComponents = ComponentRegistry.getPresent(entity);
    if (!showTransient) {
      presentComponents = presentComponents
          .where((m) => !m.isTransient)
          .toList();
    }
    presentComponents.sort((a, b) => a.componentName.compareTo(b.componentName));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 2),
      children: [
        ...presentComponents.map(
          (metadata) => ComponentSection(
            entity: entity,
            metadata: metadata,
          ),
        ),
        _AddComponentButton(
          entity: entity,
          showTransient: showTransient,
        ),
      ],
    );
  }

  /// Builds the split view for entities with templates.
  /// Shows direct components section and inherited components section separately.
  Widget _buildSplitView(
    BuildContext context,
    Entity entity,
    bool showTransient,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final templateEntity = entity.getTemplateEntity()!;
    final templateName = templateEntity.get<Name>()?.name ?? 'Template';

    // Get direct components
    var directComponents = ComponentRegistry.getDirectPresent(entity);
    if (!showTransient) {
      directComponents = directComponents.where((m) => !m.isTransient).toList();
    }
    directComponents.sort((a, b) => a.componentName.compareTo(b.componentName));

    // Get inherited (active) components
    var inheritedComponents = ComponentRegistry.getInheritedPresent(entity);
    if (!showTransient) {
      inheritedComponents = inheritedComponents.where((m) => !m.isTransient).toList();
    }
    inheritedComponents.sort((a, b) => a.componentName.compareTo(b.componentName));

    // Get excluded components
    var excludedComponents = ComponentRegistry.getExcludedTypes(entity);
    if (!showTransient) {
      excludedComponents = excludedComponents.where((m) => !m.isTransient).toList();
    }
    excludedComponents.sort((a, b) => a.componentName.compareTo(b.componentName));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 2),
      children: [
        // Direct Components Section Header
        _ComponentSectionHeader(
          title: 'Direct Components',
          count: directComponents.length,
          color: colorScheme.primary,
        ),

        // Direct component sections
        ...directComponents.map(
          (metadata) => _DirectComponentSection(
            entity: entity,
            metadata: metadata,
          ),
        ),

        // Add Component button
        _AddComponentButton(
          entity: entity,
          showTransient: showTransient,
        ),

        const SizedBox(height: 8),

        // From Template Section Header
        _TemplateSectionHeader(
          templateName: templateName,
          count: inheritedComponents.length + excludedComponents.length,
          color: colorScheme.tertiary,
          onEditTemplate: () => _navigateToTemplate(entity),
        ),

        // Active inherited components
        ...inheritedComponents.map(
          (metadata) => InheritedComponentSection(
            entity: entity,
            metadata: metadata,
            isExcluded: false,
          ),
        ),

        // Excluded components (greyed out)
        ...excludedComponents.map(
          (metadata) => InheritedComponentSection(
            entity: entity,
            metadata: metadata,
            isExcluded: true,
          ),
        ),
      ],
    );
  }

  /// Navigate to the template entity when "Edit Template" is clicked.
  void _navigateToTemplate(Entity entity) {
    final templateEntity = entity.getTemplateEntity();
    if (templateEntity != null) {
      // Clear multi-selection if present
      widget.selectedEntitiesNotifier?.value = {};
      widget.entityNotifier.value = templateEntity;
    }
  }

  Widget _buildSectionHeader(BuildContext context, bool showTransientValue) {
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
          // Toggle visibility of transient components
          Tooltip(
            message: showTransientValue
                ? 'Hide transient components'
                : 'Show transient components',
            child: InkWell(
              onTap: () => _showTransient.value = !_showTransient.value,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  showTransientValue ? Icons.visibility : Icons.visibility_off,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
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

  Widget _buildMultiSelectState(BuildContext context, int count) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.select_all,
              size: 32,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              '$count entities selected',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select a single entity to edit',
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
            Icons.copy,
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
///
/// When [showTransient] is false, transient components are hidden from the dialog.
class _AddComponentButton extends StatelessWidget {
  final Entity entity;
  final bool showTransient;

  const _AddComponentButton({
    required this.entity,
    required this.showTransient,
  });

  Future<void> _showAddComponentDialog(BuildContext context) async {
    final available = ComponentRegistry.getAvailable(entity)
      ..sort((a, b) => a.componentName.compareTo(b.componentName));

    if (available.isEmpty) return;

    final selected = await showDialog<ComponentMetadata>(
      context: context,
      builder: (context) => _AddComponentDialog(
        availableComponents: available,
        initialShowTransient: showTransient,
        entity: entity,
      ),
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
    var available = ComponentRegistry.getAvailable(entity);
    if (!showTransient) {
      available = available.where((m) => !m.isTransient).toList();
    }

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
  final bool initialShowTransient;
  final Entity entity;

  const _AddComponentDialog({
    required this.availableComponents,
    required this.initialShowTransient,
    required this.entity,
  });

  @override
  State<_AddComponentDialog> createState() => _AddComponentDialogState();
}

class _AddComponentDialogState extends State<_AddComponentDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late bool _showTransient;

  @override
  void initState() {
    super.initState();
    _showTransient = widget.initialShowTransient;
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
    var components = widget.availableComponents;
    if (!_showTransient) {
      components = components.where((c) => !c.isTransient).toList();
    }
    if (_searchQuery.isNotEmpty) {
      components = components
          .where((c) => c.componentName.toLowerCase().contains(_searchQuery))
          .toList();
    }
    return components;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filtered = _filteredComponents;

    return AlertDialog(
      title: Row(
        children: [
          const Text('Add Component'),
          const Spacer(),
          Tooltip(
            message: _showTransient
                ? 'Hide transient components'
                : 'Show transient components',
            child: InkWell(
              onTap: () => setState(() => _showTransient = !_showTransient),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  _showTransient ? Icons.visibility : Icons.visibility_off,
                  size: 20,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
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
                        final templateEntity = widget.entity.getTemplateEntity();
                        final isOnTemplate = templateEntity != null &&
                            templateEntity.hasType(metadata.componentName);

                        return ListTile(
                          dense: true,
                          title: Row(
                            children: [
                              Text(
                                metadata.componentName,
                                style: const TextStyle(fontSize: 13),
                              ),
                              if (isOnTemplate) ...[
                                const SizedBox(width: 6),
                                Tooltip(
                                  message: 'Exists on template (will override)',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.tertiaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'T',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onTertiaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
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

/// Section header for grouping components (e.g., "Direct Components").
class _ComponentSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _ComponentSectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: color,
            width: 3,
          ),
        ),
        color: colorScheme.surfaceContainerLow,
      ),
      child: Row(
        children: [
          Text(
            '$title ($count)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header for template components with "Edit Template" button.
class _TemplateSectionHeader extends StatelessWidget {
  final String templateName;
  final int count;
  final Color color;
  final VoidCallback onEditTemplate;

  const _TemplateSectionHeader({
    required this.templateName,
    required this.count,
    required this.color,
    required this.onEditTemplate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: color,
            width: 3,
          ),
        ),
        color: colorScheme.surfaceContainerLow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'From Template ($count)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Tooltip(
            message: 'Edit "$templateName"',
            child: InkWell(
              onTap: onEditTemplate,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: color,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A component section for direct components in the split view.
///
/// Uses removeDirect instead of the standard remove to avoid creating
/// exclusions when deleting a direct component that's also on the template.
class _DirectComponentSection extends StatefulWidget {
  final Entity entity;
  final ComponentMetadata metadata;

  const _DirectComponentSection({
    required this.entity,
    required this.metadata,
  });

  @override
  State<_DirectComponentSection> createState() => _DirectComponentSectionState();
}

class _DirectComponentSectionState extends State<_DirectComponentSection> {
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
