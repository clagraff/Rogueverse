import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';

/// Metadata for the Name component, which stores an entity's display name.
class NameMetadata extends ComponentMetadata {
  /// Theme used for property panel layout.
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'Name';

  @override
  bool hasComponent(Entity entity) => entity.has<Name>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.onEntityOnComponent<Name>(entity.id),
      builder: (context, snapshot) {
        final name = entity.get<Name>();
        if (name == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('name_${name.name}'),
              item: StringPropertyItem(
                id: "name",
                label: "Name",
                value: name.name,
                onChanged: (String s) {
                  entity.upsert<Name>(name.copyWith(name: s));
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
  Component createDefault() => Name(name: 'Unnamed');

  @override
  void removeComponent(Entity entity) => entity.remove<Name>();
}
