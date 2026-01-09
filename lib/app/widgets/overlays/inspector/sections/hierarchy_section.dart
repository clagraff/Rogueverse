import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';
import 'package:rogueverse/ecs/events.dart';

/// Metadata for the HasParent component, which links an entity to its parent in the hierarchy.
class HasParentMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'HasParent';

  @override
  bool hasComponent(Entity entity) => entity.has<HasParent>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<HasParent>(entity.id),
      builder: (context, snapshot) {
        final hasParent = entity.get<HasParent>();
        if (hasParent == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('hasParent_${hasParent.parentEntityId}'),
              item: IntPropertyItem(
                id: "parentEntityId",
                label: "Parent Entity ID",
                value: hasParent.parentEntityId,
                onChanged: (val) => entity.upsert(HasParent(val)),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => HasParent(0);

  @override
  void removeComponent(Entity entity) => entity.remove<HasParent>();
}
