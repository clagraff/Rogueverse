import 'package:flutter/material.dart';

import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';
import 'package:rogueverse/ecs/ecs.dart';

/// Inspector section for DirectionBasedRendering component.
///
/// Allows toggling whether diagonal directions use 45-degree rotation
/// or snap to the nearest cardinal direction.
class DirectionBasedRenderingMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 160);

  @override
  String get componentName => 'DirectionBasedRendering';

  @override
  bool hasComponent(Entity entity) => entity.has<DirectionBasedRendering>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges
          .onEntityOnComponent<DirectionBasedRendering>(entity.id),
      builder: (context, snapshot) {
        final rendering = entity.get<DirectionBasedRendering>();
        if (rendering == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Text(
                'Sprite rotation is derived from Direction component.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ),
            PropertyRow(
              key: ValueKey(
                  'dbr_diagonal_${rendering.allowDiagonalRotation}'),
              item: BoolPropertyItem(
                id: "allowDiagonalRotation",
                label: "45° Diagonals",
                value: rendering.allowDiagonalRotation,
                onChanged: (val) => entity.upsert(
                  DirectionBasedRendering(allowDiagonalRotation: val),
                ),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => DirectionBasedRendering();

  @override
  void removeComponent(Entity entity) => entity.remove<DirectionBasedRendering>();
}
