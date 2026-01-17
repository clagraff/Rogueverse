import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';

/// Metadata for the IsTemplate component, which marks an entity as a template.
class IsTemplateMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'IsTemplate';

  @override
  bool hasComponent(Entity entity) => entity.has<IsTemplate>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<IsTemplate>(entity.id),
      builder: (context, snapshot) {
        final isTemplate = entity.get<IsTemplate>();
        if (isTemplate == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('isTemplate_${isTemplate.displayName}'),
              item: StringPropertyItem(
                id: "displayName",
                label: "Display Name",
                value: isTemplate.displayName,
                onChanged: (String s) {
                  entity.upsert<IsTemplate>(IsTemplate(displayName: s));
                },
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => IsTemplate(displayName: 'New Template');

  @override
  void removeComponent(Entity entity) => entity.remove<IsTemplate>();
}

/// Metadata for the FromTemplate component, which links an entity to a template.
///
/// Provides a dropdown of available templates and a button to navigate to the
/// selected template entity for editing.
class FromTemplateMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'FromTemplate';

  @override
  bool hasComponent(Entity entity) => entity.has<FromTemplate>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<FromTemplate>(entity.id),
      builder: (context, snapshot) {
        final fromTemplate = entity.get<FromTemplate>();
        if (fromTemplate == null) return const SizedBox.shrink();

        return _FromTemplateEditor(
          entity: entity,
          fromTemplate: fromTemplate,
          theme: _theme,
        );
      },
    );
  }

  @override
  Component createDefault() => FromTemplate(0);

  @override
  void removeComponent(Entity entity) => entity.remove<FromTemplate>();
}

/// Custom editor widget for FromTemplate that shows a dropdown of templates.
class _FromTemplateEditor extends StatelessWidget {
  final Entity entity;
  final FromTemplate fromTemplate;
  final PropertyPanelThemeData theme;

  const _FromTemplateEditor({
    required this.entity,
    required this.fromTemplate,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final world = entity.parentCell;
    final colorScheme = Theme.of(context).colorScheme;

    // Get all template entities
    final templates = Query().require<IsTemplate>().find(world).toList();
    templates.sort((a, b) {
      final nameA = a.get<IsTemplate>()?.displayName ?? '';
      final nameB = b.get<IsTemplate>()?.displayName ?? '';
      return nameA.compareTo(nameB);
    });

    // Build options: null for "None", then all template IDs
    final options = <int?>[null, ...templates.map((t) => t.id)];

    // Find current selection
    final currentValue = templates.any((t) => t.id == fromTemplate.templateEntityId)
        ? fromTemplate.templateEntityId
        : null;

    final excludedList = fromTemplate.excludedTypes.toList()..sort();

    return Column(
      children: [
        // Template dropdown
        PropertyRow(
          key: ValueKey('fromTemplate_${fromTemplate.templateEntityId}'),
          item: CustomPropertyItem<int?>(
            id: "templateEntityId",
            label: "Template",
            value: currentValue,
            builder: (context, value, readOnly, onChanged) {
              return DropdownButtonFormField<int?>(
                value: value,
                isDense: true,
                isExpanded: true,
                style: const TextStyle(fontSize: 12, color: Colors.white),
                items: options.map((id) {
                  if (id == null) {
                    return const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('(None)', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                    );
                  }
                  final template = world.getEntity(id);
                  final name = template.get<IsTemplate>()?.displayName ?? 'Template #$id';
                  return DropdownMenuItem<int?>(
                    value: id,
                    child: Text(name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: readOnly ? null : (newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                },
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
              );
            },
            onChanged: (int? newId) {
              if (newId != null) {
                // Preserve excludedTypes when changing template
                entity.upsert<FromTemplate>(FromTemplate(newId, excludedTypes: fromTemplate.excludedTypes));
              }
            },
          ),
          theme: theme,
        ),
        // Navigate to template button
        if (currentValue != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
            child: Row(
              children: [
                SizedBox(width: theme.labelColumnWidth),
                const SizedBox(width: 6),
                Expanded(
                  child: _NavigateToTemplateButton(
                    templateId: currentValue,
                    world: world,
                  ),
                ),
              ],
            ),
          ),
        // Excluded types section
        if (excludedList.isNotEmpty) ...[
          PropertyRow(
            key: ValueKey('excludedTypes_${excludedList.join(",")}'),
            item: StringPropertyItem(
              id: "excludedTypes",
              label: "Excluded Types",
              value: excludedList.join(', '),
              hintText: 'Comma-separated list',
              onChanged: (String s) {
                final types = s.split(',')
                    .map((t) => t.trim())
                    .where((t) => t.isNotEmpty)
                    .toSet();
                entity.upsert<FromTemplate>(FromTemplate(
                  fromTemplate.templateEntityId,
                  excludedTypes: types,
                ));
              },
            ),
            theme: theme,
          ),
          // Show individual excluded types as chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: excludedList.map((type) {
                return Chip(
                  label: Text(type, style: const TextStyle(fontSize: 10)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () {
                    final newTypes = Set<String>.from(fromTemplate.excludedTypes)..remove(type);
                    entity.upsert<FromTemplate>(FromTemplate(
                      fromTemplate.templateEntityId,
                      excludedTypes: newTypes,
                    ));
                  },
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

/// Button that navigates to (selects) the template entity for editing.
class _NavigateToTemplateButton extends StatelessWidget {
  final int templateId;
  final World world;

  const _NavigateToTemplateButton({
    required this.templateId,
    required this.world,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final templateEntity = world.getEntity(templateId);
    final templateName = templateEntity.get<IsTemplate>()?.displayName ?? 'Template #$templateId';

    return OutlinedButton.icon(
      onPressed: () {
        // Find the GameArea and select the template entity
        // This works by finding the nearest ancestor that can handle selection
        _selectTemplateEntity(context, templateEntity);
      },
      icon: Icon(Icons.open_in_new, size: 14, color: colorScheme.primary),
      label: Text(
        'Edit "$templateName"',
        style: TextStyle(fontSize: 11, color: colorScheme.primary),
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 28),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
      ),
    );
  }

  void _selectTemplateEntity(BuildContext context, Entity templateEntity) {
    // Walk up the widget tree to find a way to select entities
    // This is a simple approach - in a real app you might use a provider or callback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to template: ${templateEntity.get<IsTemplate>()?.displayName}'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Select',
          onPressed: () {
            // TODO: Implement actual navigation by finding GameArea's selectedEntities notifier
            // For now, we show a message. The user can manually select the template.
          },
        ),
      ),
    );
  }
}
