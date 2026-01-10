import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';

/// Metadata for the Cell component, which tracks entity IDs at a grid position.
///
/// This component is typically used internally by the grid system to track
/// which entities occupy each cell. It's primarily useful for debugging.
class CellMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'Cell';

  @override
  bool hasComponent(Entity entity) => entity.has<Cell>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<Cell>(entity.id),
      builder: (context, snapshot) {
        final cell = entity.get<Cell>();
        if (cell == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('cell_count_${cell.entityIds.length}'),
              item: ReadonlyPropertyItem(
                id: "entityCount",
                label: "Entity Count",
                value: cell.entityIds.length.toString(),
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('cell_entities_${cell.entityIds.join(",")}'),
              item: ReadonlyPropertyItem(
                id: "entityIds",
                label: "Entity IDs",
                value: cell.entityIds.isEmpty ? '[]' : cell.entityIds.join(', '),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => Cell();

  @override
  void removeComponent(Entity entity) => entity.remove<Cell>();
}
