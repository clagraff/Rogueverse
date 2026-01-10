import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
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

  /// Available rotation options (in degrees).
  static const _rotationOptions = [0.0, 90.0, 180.0, 270.0];

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<Renderable>(entity.id),
      builder: (context, snapshot) {
        final renderable = entity.get<Renderable>();
        if (renderable == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('renderable_${renderable.svgAssetPath}'),
              item: AssetPathPropertyItem(
                id: "svgAssetPath",
                label: "SVG Asset Path",
                value: renderable.svgAssetPath,
                onChanged: (String newPath) {
                  entity.upsert<Renderable>(renderable.copyWith(svgAssetPath: newPath));
                },
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('renderable_flipH_${renderable.flipHorizontal}'),
              item: BoolPropertyItem(
                id: "flipHorizontal",
                label: "Flip Horizontal",
                value: renderable.flipHorizontal,
                onChanged: (bool newValue) {
                  entity.upsert<Renderable>(renderable.copyWith(flipHorizontal: newValue));
                },
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('renderable_flipV_${renderable.flipVertical}'),
              item: BoolPropertyItem(
                id: "flipVertical",
                label: "Flip Vertical",
                value: renderable.flipVertical,
                onChanged: (bool newValue) {
                  entity.upsert<Renderable>(renderable.copyWith(flipVertical: newValue));
                },
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('renderable_rotation_${renderable.rotationDegrees}'),
              item: EnumPropertyItem<double>(
                id: "rotationDegrees",
                label: "Rotation",
                value: _rotationOptions.contains(renderable.rotationDegrees)
                    ? renderable.rotationDegrees
                    : 0.0,
                options: _rotationOptions,
                optionLabelBuilder: (v) => '${v.toInt()}°',
                onChanged: (double newValue) {
                  entity.upsert<Renderable>(renderable.copyWith(rotationDegrees: newValue));
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
  Component createDefault() => Renderable('images/default.svg');

  @override
  void removeComponent(Entity entity) => entity.remove<Renderable>();
}
