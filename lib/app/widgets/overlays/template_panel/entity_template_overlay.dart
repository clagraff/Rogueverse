import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
/// - Can be dismissed by pressing Ctrl+E
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

        // Handle ESC key
        if (event.logicalKey == LogicalKeyboardKey.escape) {
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

        // Process Ctrl+E to close the panel
        if (event.logicalKey == LogicalKeyboardKey.keyE &&
            (HardwareKeyboard.instance.isControlPressed)) {
          // Allow text fields to handle Ctrl+E for unfocusing; otherwise close the panel
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  /// Builds the search bar for filtering templates.
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search templates...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty ? 'No templates yet' : 'No templates found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
              if (_searchQuery.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Create your first template!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
          padding: const EdgeInsets.all(12.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.85,
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
      padding: const EdgeInsets.all(12.0),
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
          icon: const Icon(Icons.add),
          label: const Text('Create Template'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
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
}
