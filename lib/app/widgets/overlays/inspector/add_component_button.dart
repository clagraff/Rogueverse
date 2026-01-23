import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';

/// Button that opens a searchable dialog to add new components to the entity.
///
/// When [showTransient] is false, transient components are hidden from the dialog.
class AddComponentButton extends StatelessWidget {
  final Entity entity;
  final bool showTransient;

  const AddComponentButton({
    super.key,
    required this.entity,
    required this.showTransient,
  });

  Future<void> _showAddComponentDialog(BuildContext context) async {
    final available = ComponentRegistry.getAvailable(entity)
      ..sort((a, b) => a.componentName.compareTo(b.componentName));

    if (available.isEmpty) return;

    final selected = await showDialog<ComponentMetadata>(
      context: context,
      builder: (context) => AddComponentDialog(
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
class AddComponentDialog extends StatefulWidget {
  final List<ComponentMetadata> availableComponents;
  final bool initialShowTransient;
  final Entity entity;

  const AddComponentDialog({
    super.key,
    required this.availableComponents,
    required this.initialShowTransient,
    required this.entity,
  });

  @override
  State<AddComponentDialog> createState() => _AddComponentDialogState();
}

class _AddComponentDialogState extends State<AddComponentDialog> {
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
