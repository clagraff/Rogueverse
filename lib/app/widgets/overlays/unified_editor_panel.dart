import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_section.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/sections/sections.dart';
import 'package:rogueverse/app/widgets/overlays/template_panel/template_card.dart';

/// Unified editor panel that combines entity inspection and template management.
///
/// This panel appears on the right side of the screen and provides:
/// - Entity properties editing (top section)
/// - Template browsing and creation (bottom section)
/// - Mode indicator showing current gameplay/editing state
///
/// Can be dismissed by pressing ESC, Ctrl+E, or Ctrl+T.
class UnifiedEditorPanel extends StatefulWidget {
  /// The overlay name used to register and toggle this panel.
  static const String overlayName = 'editorPanel';

  /// The ECS world for querying template entities.
  final World world;

  /// Notifier that tracks which entity (if any) is currently selected for editing.
  final ValueNotifier<Entity?> entityNotifier;

  /// Notifier that tracks which template entity ID (if any) is currently selected for placement.
  final ValueNotifier<int?> selectedTemplateIdNotifier;

  /// Notifier for the current game mode (gameplay vs editing).
  final ValueNotifier<GameMode> gameModeNotifier;

  /// Callback to create a new template.
  final VoidCallback onCreateTemplate;

  /// Callback to edit an existing template entity.
  final void Function(Entity) onEditTemplate;

  /// Callback to close the panel.
  final VoidCallback onClose;

  const UnifiedEditorPanel({
    super.key,
    required this.world,
    required this.entityNotifier,
    required this.selectedTemplateIdNotifier,
    required this.gameModeNotifier,
    required this.onCreateTemplate,
    required this.onEditTemplate,
    required this.onClose,
  });

  @override
  State<UnifiedEditorPanel> createState() => _UnifiedEditorPanelState();
}

class _UnifiedEditorPanelState extends State<UnifiedEditorPanel> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _registerAllComponents();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _requestFocusAfterBuild();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
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

      // Template components
      ComponentRegistry.register(IsTemplateMetadata());
      ComponentRegistry.register(FromTemplateMetadata());
    }
  }

  void _requestFocusAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;

        final currentFocus = FocusScope.of(context).focusedChild;
        final isTextFieldFocused = currentFocus != null && currentFocus != _focusNode;

        final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
        final keybindings = KeyBindingService.instance;

        // Close panel on ESC (when not in a text field)
        if (keybindings.matches('game.deselect', keysPressed)) {
          if (!isTextFieldFocused) {
            widget.onClose();
          }
        }

        // Close panel on Ctrl+E or Ctrl+T
        if (keybindings.matches('overlay.editor', keysPressed) ||
            keybindings.matches('overlay.templates', keysPressed)) {
          if (!isTextFieldFocused) {
            widget.onClose();
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          final currentFocus = FocusScope.of(context).focusedChild;
          if (currentFocus == null) {
            _focusNode.requestFocus();
          }
        },
        child: Material(
          elevation: 4,
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              // Main header with mode indicator and close button
              _buildHeader(context),
              // Properties section (entity inspector)
              Expanded(
                flex: 3,
                child: _PropertiesSection(
                  world: widget.world,
                  entityNotifier: widget.entityNotifier,
                ),
              ),
              // Divider between sections
              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              // Templates section
              Expanded(
                flex: 2,
                child: _TemplatesSection(
                  world: widget.world,
                  selectedTemplateIdNotifier: widget.selectedTemplateIdNotifier,
                  searchController: _searchController,
                  searchQuery: _searchQuery,
                  onEditTemplate: widget.onEditTemplate,
                  onCreateTemplate: widget.onCreateTemplate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the main panel header with title, mode indicator, and close button.
  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Editor',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          // Mode indicator
          ValueListenableBuilder<GameMode>(
            valueListenable: widget.gameModeNotifier,
            builder: (context, mode, _) {
              final isEditing = mode == GameMode.editing;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isEditing
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isEditing
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  isEditing ? 'EDITING' : 'GAMEPLAY',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isEditing
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              );
            },
          ),
          const Spacer(),
          // Close button
          InkWell(
            onTap: widget.onClose,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Properties section showing the currently selected entity's components.
class _PropertiesSection extends StatelessWidget {
  final World world;
  final ValueNotifier<Entity?> entityNotifier;

  const _PropertiesSection({
    required this.world,
    required this.entityNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section header
        _buildSectionHeader(context),
        // Component list
        Expanded(
          child: ValueListenableBuilder<Entity?>(
            valueListenable: entityNotifier,
            builder: (context, entity, _) {
              if (entity == null) {
                return _buildEmptyState(context);
              }

              return StreamBuilder<Change>(
                stream: entity.parentCell.componentChanges.onEntityChange(entity.id),
                builder: (context, snapshot) {
                  final presentComponents = ComponentRegistry.getPresent(entity);

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
            valueListenable: entityNotifier,
            builder: (context, entity, _) {
              if (entity == null) return const SizedBox.shrink();
              return _SaveAsTemplateButton(world: world, entity: entity);
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

/// Templates section showing the template grid and search.
class _TemplatesSection extends StatelessWidget {
  final World world;
  final ValueNotifier<int?> selectedTemplateIdNotifier;
  final TextEditingController searchController;
  final String searchQuery;
  final void Function(Entity) onEditTemplate;
  final VoidCallback onCreateTemplate;

  const _TemplatesSection({
    required this.world,
    required this.selectedTemplateIdNotifier,
    required this.searchController,
    required this.searchQuery,
    required this.onEditTemplate,
    required this.onCreateTemplate,
  });

  /// Gets all template entities (entities with IsTemplate component).
  List<Entity> _getTemplateEntities() {
    final query = Query().require<IsTemplate>();
    var templates = query.find(world).toList();

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
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
        // Section header
        _buildSectionHeader(context),
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
        // Create template button
        _buildCreateButton(context),
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
            'Templates',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: TextField(
        controller: searchController,
        style: const TextStyle(fontSize: 11),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: const TextStyle(fontSize: 11),
          prefixIcon: const Icon(Icons.search, size: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          isDense: true,
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 14),
                  iconSize: 14,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => searchController.clear(),
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
      valueListenable: selectedTemplateIdNotifier,
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
                  selectedTemplateIdNotifier.value = null;
                } else {
                  selectedTemplateIdNotifier.value = templateEntity.id;
                }
              },
              onEdit: () => onEditTemplate(templateEntity),
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
              searchQuery.isEmpty ? 'No templates' : 'No matches',
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

  Widget _buildCreateButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onCreateTemplate,
          icon: const Icon(Icons.add, size: 14),
          label: const Text('Create Template', style: TextStyle(fontSize: 11)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            minimumSize: const Size(0, 28),
          ),
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
    final newComponents = components.where((c) => c is! IsTemplate && c is! Name).toList();
    newComponents.add(IsTemplate(displayName: newName));
    newComponents.add(Name(name: newName));

    world.add(newComponents);

    // Save the world state
    await WorldSaves.writeInitialState(world);

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
      await WorldSaves.writeInitialState(world);

      if (selectedTemplateIdNotifier.value == templateEntity.id) {
        selectedTemplateIdNotifier.value = null;
      }
    }
  }
}

/// Button that saves the current entity as a new template.
class _SaveAsTemplateButton extends StatelessWidget {
  final World world;
  final Entity entity;

  const _SaveAsTemplateButton({
    required this.world,
    required this.entity,
  });

  Future<void> _saveAsTemplate(BuildContext context) async {
    final nameComponent = entity.get<Name>();
    final defaultName = nameComponent?.name ?? 'New Template';

    final templateName = await showDialog<String>(
      context: context,
      builder: (context) => _TemplateNameDialog(defaultName: defaultName),
    );

    if (templateName == null || templateName.isEmpty) return;

    // Copy components from entity, excluding position-related ones and Name (will use template name)
    final components = entity.getAll()
        .where((c) => c is! LocalPosition && c is! HasParent && c is! FromTemplate && c is! IsTemplate && c is! Name)
        .toList();

    // Add IsTemplate marker and Name components
    components.add(IsTemplate(displayName: templateName));
    components.add(Name(name: templateName));

    world.add(components);

    // Save the world state
    await WorldSaves.writeInitialState(world);

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

/// Button that opens a menu to add new components to the entity.
class _AddComponentButton extends StatelessWidget {
  final Entity entity;

  const _AddComponentButton({required this.entity});

  void _addComponent(BuildContext context, ComponentMetadata metadata) {
    final component = metadata.createDefault();
    entity.upsertByName(component);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${metadata.componentName}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final available = ComponentRegistry.getAvailable(entity)
      ..sort((a, b) => a.componentName.compareTo(b.componentName));

    if (available.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: PopupMenuButton<ComponentMetadata>(
        onSelected: (metadata) => _addComponent(context, metadata),
        itemBuilder: (context) => available
            .map(
              (metadata) => PopupMenuItem<ComponentMetadata>(
                value: metadata,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(metadata.componentName, style: const TextStyle(fontSize: 11)),
              ),
            )
            .toList(),
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
