import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';
import 'package:rogueverse/ecs/events.dart';

/// Metadata for the Direction component, which stores the direction an entity is facing.
class DirectionMetadata extends ComponentMetadata {
  /// Theme used for property panel layout.
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'Direction';

  @override
  bool hasComponent(Entity entity) => entity.has<Direction>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<Direction>(entity.id),
      builder: (context, snapshot) {
        final direction = entity.get<Direction>();
        if (direction == null) return const SizedBox.shrink();

        Logger("DirectionSection").info(
          "Rebuilding content with facing=${direction.facing}",
        );

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('facing_${direction.facing}'),
              item: EnumPropertyItem<CompassDirection>(
                id: "facing",
                label: "Facing",
                value: direction.facing,
                options: CompassDirection.values,
                optionLabelBuilder: (direction) => _formatDirectionName(direction),
                onChanged: (CompassDirection newDirection) {
                  entity.upsert<Direction>(Direction(newDirection));
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
  Component createDefault() => Direction(CompassDirection.south);

  @override
  void removeComponent(Entity entity) => entity.remove<Direction>();

  /// Format direction name for display (e.g., "northeast" -> "North East")
  String _formatDirectionName(CompassDirection direction) {
    switch (direction) {
      case CompassDirection.north:
        return 'North';
      case CompassDirection.south:
        return 'South';
      case CompassDirection.east:
        return 'East';
      case CompassDirection.west:
        return 'West';
      case CompassDirection.northeast:
        return 'North East';
      case CompassDirection.northwest:
        return 'North West';
      case CompassDirection.southeast:
        return 'South East';
      case CompassDirection.southwest:
        return 'South West';
    }
  }
}
