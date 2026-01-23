import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';

/// Metadata for the Item marker component.
///
/// Items are template entities that can be spawned from LootTables.
/// This is a marker component with no editable fields.
class ItemMetadata extends ComponentMetadata {
  @override
  String get componentName => 'Item';

  @override
  bool hasComponent(Entity entity) => entity.has<Item>();

  @override
  Widget buildContent(Entity entity) {
    return Builder(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Marker component for item templates.\n'
            'Items can be spawned from LootTables.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
        );
      },
    );
  }

  @override
  Component createDefault() => Item();

  @override
  void removeComponent(Entity entity) => entity.remove<Item>();
}

/// Metadata for the Description component, which stores flavor text.
class DescriptionMetadata extends ComponentMetadata {
  /// Theme used for property panel layout.
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'Description';

  @override
  bool hasComponent(Entity entity) => entity.has<Description>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<Description>(entity.id),
      builder: (context, snapshot) {
        final description = entity.get<Description>();
        if (description == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('description_${description.text.hashCode}'),
              item: StringPropertyItem(
                id: "text",
                label: "Text",
                value: description.text,
                multiline: true,
                onChanged: (String s) {
                  entity.upsert<Description>(Description(s));
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
  Component createDefault() => Description('');

  @override
  void removeComponent(Entity entity) => entity.remove<Description>();
}
