import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';

/// Metadata for the DirectionIntent component, a transient intent to change facing direction.
///
/// This component is added by input systems (Shift+WASD) or movement systems,
/// and consumed by DirectionSystem to update the entity's Direction.
class DirectionIntentMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'DirectionIntent';

  @override
  bool get isTransient => true;

  @override
  bool hasComponent(Entity entity) => entity.has<DirectionIntent>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<DirectionIntent>(entity.id),
      builder: (context, snapshot) {
        final intent = entity.get<DirectionIntent>();
        if (intent == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "direction",
                label: "Direction",
                value: intent.direction.name,
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => DirectionIntent(CompassDirection.south);

  @override
  void removeComponent(Entity entity) => entity.remove<DirectionIntent>();
}

/// Metadata for the DidChangeDirection component, a transient event recording direction change without movement.
///
/// This component is added when an entity changes direction without moving (e.g., via Shift+WASD).
/// It's primarily useful for debugging the direction system.
class DidChangeDirectionMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'DidChangeDirection';

  @override
  bool get isTransient => true;

  @override
  bool hasComponent(Entity entity) => entity.has<DidChangeDirection>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<DidChangeDirection>(entity.id),
      builder: (context, snapshot) {
        final event = entity.get<DidChangeDirection>();
        if (event == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "from",
                label: "From",
                value: event.from.name,
              ),
              theme: _theme,
            ),
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "to",
                label: "To",
                value: event.to.name,
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => DidChangeDirection(from: CompassDirection.south, to: CompassDirection.south);

  @override
  void removeComponent(Entity entity) => entity.remove<DidChangeDirection>();
}
