import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/ecs/entity_template.dart';
import 'package:rogueverse/ecs/template_registry.dart';
import 'package:rogueverse/app/widgets/overlays/template_panel/template_card.dart';

/// Overlay panel that displays entity templates in a grid layout.
///
/// This panel appears on the left side of the screen and allows users to:
/// - Browse available entity templates
/// - Search/filter templates by name
/// - Select a template for placement
/// - Create new templates
/// - Can be dismissed by pressing Ctrl+T or ESC
class TemplatePanel extends StatefulWidget {
  /// Notifier that tracks which template (if any) is currently selected for placement.
  final ValueNotifier<EntityTemplate?> selectedTemplateNotifier;

  /// Callback to create a new template.
  ///
  /// This should prompt the user for a name, then open the inspector.
  final VoidCallback onCreateTemplate;

  /// Callback to edit an existing template.
  ///
  /// This should open the inspector with the template's components.
  final void Function(EntityTemplate) onEditTemplate;

  /// Callback to close the template panel.
  final VoidCallback onClose;

  const TemplatePanel({
    super.key,
    required this.selectedTemplateNotifier,
    required this.onCreateTemplate,
    required this.onEditTemplate,
    required this.onClose,
  });

  @override
  State<TemplatePanel> createState() => _TemplatePanelState();
}

class _TemplatePanelState extends State<TemplatePanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Requests focus for keyboard handling after the widget is built.
  void _requestFocusAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    // Request focus only when panel first opens
    _requestFocusAfterBuild();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: false, // Don't auto-focus on every rebuild
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;

        // Determine if a text input field currently has focus
        final currentFocus = FocusScope.of(context).focusedChild;
        final isTextFieldFocused = currentFocus != null && currentFocus != _focusNode;

        final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
        final keybindings = KeyBindingService.instance;

        // Handle deselect action (ESC)
        if (keybindings.matches('game.deselect', keysPressed)) {
          // Don't handle ESC if a text field has focus (let it unfocus naturally)
          if (isTextFieldFocused) return;

          // If a template is selected, deselect it first
          if (widget.selectedTemplateNotifier.value != null) {
            widget.selectedTemplateNotifier.value = null;
          } else {
            // If no template selected, close the panel
            widget.onClose();
          }
        }

        // Process overlay.templates action to close the panel
        if (keybindings.matches('overlay.templates', keysPressed)) {
          // Allow text fields to handle the key; otherwise close the panel
          if (!isTextFieldFocused) {
            widget.onClose();
          }
        }
      },
      child: GestureDetector(
        // Restore focus to the panel when clicking outside of interactive elements
        // but not when clicking on text fields or buttons
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
          // Panel header with title
          _buildHeader(context),
          // Search bar
          _buildSearchBar(context),
          // Template grid - rebuilds when registry changes
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: TemplateRegistry.instance.changeNotifier,
              builder: (context, _, __) {
                final templates = TemplateRegistry.instance.search(_searchQuery);
                return _buildTemplateGrid(context, templates);
              },
            ),
          ),
          // Create template button
          _buildCreateButton(context),
        ],
          ),
        ),
      ),
    );
  }

  /// Builds the panel header with "Templates" title.
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Text(
        'Templates',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Builds the search bar for filtering templates.
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: const TextStyle(fontSize: 12),
          prefixIcon: const Icon(Icons.search, size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          isDense: true,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  /// Builds the grid of template cards.
  Widget _buildTemplateGrid(BuildContext context, List<EntityTemplate> templates) {
    if (templates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                _searchQuery.isEmpty ? 'No templates yet' : 'No templates found',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ).copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              if (_searchQuery.isEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Create your first template!',
                  style: const TextStyle(fontSize: 11).copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ValueListenableBuilder<EntityTemplate?>(
      valueListenable: widget.selectedTemplateNotifier,
      builder: (context, selectedTemplate, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 0.9,
          ),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            final isSelected = selectedTemplate?.id == template.id;

            return TemplateCard(
              template: template,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  // Toggle selection
                  if (isSelected) {
                    widget.selectedTemplateNotifier.value = null;
                  } else {
                    widget.selectedTemplateNotifier.value = template;
                  }
                });
              },
              onEdit: () => widget.onEditTemplate(template),
              onDuplicate: () => _duplicateTemplate(context, template),
              onDelete: () async {
                // Show confirmation dialog
                final confirmed = await _confirmDelete(context, template);
                if (confirmed == true) {
                  await TemplateRegistry.instance.delete(template.id);
                  // Deselect if this was the selected template
                  if (widget.selectedTemplateNotifier.value?.id == template.id) {
                    widget.selectedTemplateNotifier.value = null;
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  /// Builds the "Create Template" button at the bottom.
  Widget _buildCreateButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: widget.onCreateTemplate,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Create Template', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            minimumSize: const Size(0, 32),
          ),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before deleting a template.
  Future<bool?> _confirmDelete(BuildContext context, EntityTemplate template) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text(
          'Are you sure you want to delete "${template.displayName}"?',
        ),
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
  }

  /// Duplicates a template with a new name.
  Future<void> _duplicateTemplate(BuildContext context, EntityTemplate template) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => _DuplicateTemplateDialog(
        originalName: template.displayName,
      ),
    );

    if (newName == null || newName.isEmpty) return;

    final duplicate = EntityTemplate(
      id: TemplateRegistry.instance.generateId(),
      displayName: newName,
      components: List.from(template.components),
    );

    await TemplateRegistry.instance.save(duplicate);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created "$newName"'),
          duration: const Duration(seconds: 2),
        ),
      );
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
