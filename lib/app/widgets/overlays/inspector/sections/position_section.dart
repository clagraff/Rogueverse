import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';

/// Metadata for the LocalPosition component, which stores an entity's X/Y coordinates.
class LocalPositionMetadata extends ComponentMetadata {
  /// Theme used for property panel layout.
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'LocalPosition';

  @override
  bool hasComponent(Entity entity) => entity.has<LocalPosition>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<LocalPosition>(entity.id),
      builder: (context, snapshot) {
        final localPosition = entity.get<LocalPosition>();
        if (localPosition == null) return const SizedBox.shrink();

        Logger("LocalPositionSection").info(
          "Rebuilding content with x=${localPosition.x}, y=${localPosition.y}",
        );

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('x_${localPosition.x}'),
              item: IntPropertyItem(
                id: "x",
                label: "X",
                value: localPosition.x,
                onChanged: (int newX) {
                  entity.upsert<LocalPosition>(localPosition.copyWith(x: newX));
                },
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('y_${localPosition.y}'),
              item: IntPropertyItem(
                id: "y",
                label: "Y",
                value: localPosition.y,
                onChanged: (int newY) {
                  entity.upsert<LocalPosition>(localPosition.copyWith(y: newY));
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
  Component createDefault() => LocalPosition(x: 0, y: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<LocalPosition>();
}
