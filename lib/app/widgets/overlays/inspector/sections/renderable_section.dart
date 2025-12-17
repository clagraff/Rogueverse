import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';

/// Metadata for the Renderable component, which specifies the visual appearance of an entity.
class RenderableMetadata extends ComponentMetadata {
  /// Theme used for property panel layout.
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'Renderable';

  @override
  bool hasComponent(Entity entity) => entity.has<Renderable>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.onEntityOnComponent<Renderable>(entity.id),
      builder: (context, snapshot) {
        final renderable = entity.get<Renderable>();
        if (renderable == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('renderable_${renderable.svgAssetPath}'),
              item: StringPropertyItem(
                id: "svgAssetPath",
                label: "SVG Asset Path",
                value: renderable.svgAssetPath,
                onChanged: (String newPath) {
                  entity.upsert<Renderable>(renderable.copyWith(svgAssetPath: newPath));
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
  Component createDefault() => Renderable('sprites/default.svg');

  @override
  void removeComponent(Entity entity) => entity.remove<Renderable>();
}
