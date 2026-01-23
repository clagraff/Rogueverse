import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';

/// Metadata for the LootTable component.
///
/// Displays a list editor for loot entries with template picker and weight fields.
class LootTableMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 100);

  @override
  String get componentName => 'LootTable';

  @override
  bool hasComponent(Entity entity) => entity.has<LootTable>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<LootTable>(entity.id),
      builder: (context, snapshot) {
        final lootTable = entity.get<LootTable>();
        if (lootTable == null) return const SizedBox.shrink();

        return _LootTableEditor(
          entity: entity,
          lootTable: lootTable,
          theme: _theme,
        );
      },
    );
  }

  @override
  Component createDefault() => LootTable(entries: [], dropCount: 1);

  @override
  void removeComponent(Entity entity) => entity.remove<LootTable>();
}

/// Widget for editing a LootTable component.
class _LootTableEditor extends StatelessWidget {
  final Entity entity;
  final LootTable lootTable;
  final PropertyPanelThemeData theme;

  const _LootTableEditor({
    required this.entity,
    required this.lootTable,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drop count field
        PropertyRow(
          key: ValueKey('lootTable_dropCount_${lootTable.dropCount}'),
          item: IntPropertyItem(
            id: "dropCount",
            label: "Drop Count",
            value: lootTable.dropCount,
            onChanged: (int val) {
              entity.upsert(LootTable(
                entries: lootTable.entries,
                dropCount: val,
              ));
            },
          ),
          theme: theme,
        ),
        const SizedBox(height: 8),
        // Entries list header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text(
                'Loot Entries (${lootTable.entries.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              // Add entry button
              IconButton(
                icon: Icon(Icons.add, size: 16, color: scheme.primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Add loot entry',
                onPressed: () => _addEntry(context),
              ),
            ],
          ),
        ),
        // Entries list
        if (lootTable.entries.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'No loot entries. Click + to add.',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          )
        else
          ...lootTable.entries.asMap().entries.map((entry) {
            final index = entry.key;
            final lootEntry = entry.value;
            return _LootEntryRow(
              key: ValueKey('lootEntry_$index'),
              entity: entity,
              lootTable: lootTable,
              entry: lootEntry,
              index: index,
            );
          }),
      ],
    );
  }

  void _addEntry(BuildContext context) {
    // Get available item templates
    final itemTemplates = _getItemTemplates();

    if (itemTemplates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No item templates found. Create an Item template first.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Add entry with first available template
    final newEntry = LootEntry(
      templateId: itemTemplates.first.id,
      weight: 1,
    );

    entity.upsert(LootTable(
      entries: [...lootTable.entries, newEntry],
      dropCount: lootTable.dropCount,
    ));
  }

  List<Entity> _getItemTemplates() {
    return entity.parentCell.entities()
        .where((e) => e.has<IsTemplate>() && e.has<Item>())
        .toList();
  }
}

/// Widget for editing a single LootEntry.
class _LootEntryRow extends StatelessWidget {
  final Entity entity;
  final LootTable lootTable;
  final LootEntry entry;
  final int index;

  const _LootEntryRow({
    super.key,
    required this.entity,
    required this.lootTable,
    required this.entry,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final itemTemplates = _getItemTemplates();

    // Find current template
    Entity? currentTemplate;
    try {
      currentTemplate = entity.parentCell.getEntity(entry.templateId);
      // Verify it's still a valid item template
      if (!currentTemplate.has<IsTemplate>() || !currentTemplate.has<Item>()) {
        currentTemplate = null;
      }
    } catch (e) {
      currentTemplate = null;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Template selector
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int>(
              value: itemTemplates.any((t) => t.id == entry.templateId)
                  ? entry.templateId
                  : (itemTemplates.isNotEmpty ? itemTemplates.first.id : null),
              isDense: true,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Template',
                labelStyle: const TextStyle(fontSize: 10),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              ),
              style: const TextStyle(fontSize: 11),
              items: itemTemplates.map((template) {
                final name = template.get<Name>()?.name ??
                    template.get<IsTemplate>()?.displayName ??
                    'Template #${template.id}';
                return DropdownMenuItem<int>(
                  value: template.id,
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val == null) return;
                _updateEntry(LootEntry(templateId: val, weight: entry.weight));
              },
            ),
          ),
          const SizedBox(width: 8),
          // Weight field
          SizedBox(
            width: 50,
            child: TextFormField(
              initialValue: entry.weight.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Wt',
                labelStyle: const TextStyle(fontSize: 10),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              ),
              style: const TextStyle(fontSize: 11),
              onFieldSubmitted: (text) {
                final weight = int.tryParse(text) ?? 1;
                _updateEntry(LootEntry(templateId: entry.templateId, weight: weight));
              },
            ),
          ),
          const SizedBox(width: 4),
          // Delete button
          IconButton(
            icon: Icon(Icons.close, size: 14, color: scheme.error),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            tooltip: 'Remove entry',
            onPressed: _deleteEntry,
          ),
        ],
      ),
    );
  }

  List<Entity> _getItemTemplates() {
    return entity.parentCell.entities()
        .where((e) => e.has<IsTemplate>() && e.has<Item>())
        .toList();
  }

  void _updateEntry(LootEntry newEntry) {
    final newEntries = List<LootEntry>.from(lootTable.entries);
    newEntries[index] = newEntry;
    entity.upsert(LootTable(
      entries: newEntries,
      dropCount: lootTable.dropCount,
    ));
  }

  void _deleteEntry() {
    final newEntries = List<LootEntry>.from(lootTable.entries);
    newEntries.removeAt(index);
    entity.upsert(LootTable(
      entries: newEntries,
      dropCount: lootTable.dropCount,
    ));
  }
}
