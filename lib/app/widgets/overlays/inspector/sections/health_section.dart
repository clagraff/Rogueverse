import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';

/// Metadata for the Health component, which tracks an entity's current and max health.
class HealthMetadata extends ComponentMetadata {
  /// Theme used for property panel layout.
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'Health';

  @override
  bool hasComponent(Entity entity) => entity.has<Health>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.onEntityOnComponent<Health>(entity.id),
      builder: (context, snapshot) {
        final health = entity.get<Health>();
        if (health == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('health_current_${health.current}'),
              item: IntPropertyItem(
                id: "current",
                label: "Current",
                value: health.current,
                onChanged: (int newCurrent) {
                  entity.upsert<Health>(health.copyWith(current: newCurrent));
                },
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('health_max_${health.max}'),
              item: IntPropertyItem(
                id: "max",
                label: "Max",
                value: health.max,
                onChanged: (int newMax) {
                  entity.upsert<Health>(health.copyWith(max: newMax));
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
  Component createDefault() => Health(10, 10);

  @override
  void removeComponent(Entity entity) => entity.remove<Health>();
}
