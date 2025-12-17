import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';

/// Metadata for the MoveByIntent component, a transient event used during movement processing.
///
/// This component is typically added by input systems and consumed by movement systems,
/// so it may appear and disappear rapidly. It's primarily useful for debugging.
class MoveByIntentMetadata extends ComponentMetadata {
  /// Theme used for property panel layout.
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'MoveByIntent';

  @override
  bool hasComponent(Entity entity) => entity.has<MoveByIntent>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.onEntityOnComponent<MoveByIntent>(entity.id),
      builder: (context, snapshot) {
        final intent = entity.get<MoveByIntent>();
        if (intent == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "dx",
                label: "Delta X",
                value: intent.dx.toString(),
              ),
              theme: _theme,
            ),
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "dy",
                label: "Delta Y",
                value: intent.dy.toString(),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => MoveByIntent(dx: 0, dy: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<MoveByIntent>();
}

/// Metadata for the DidMove component, a transient event recording successful movement.
///
/// This component is added after an entity successfully moves from one position to another.
/// It's primarily useful for debugging movement systems.
class DidMoveMetadata extends ComponentMetadata {
  /// Theme used for property panel layout.
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'DidMove';

  @override
  bool hasComponent(Entity entity) => entity.has<DidMove>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.onEntityOnComponent<DidMove>(entity.id),
      builder: (context, snapshot) {
        final didMove = entity.get<DidMove>();
        if (didMove == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "from",
                label: "From",
                value: '(${didMove.from.x}, ${didMove.from.y})',
              ),
              theme: _theme,
            ),
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "to",
                label: "To",
                value: '(${didMove.to.x}, ${didMove.to.y})',
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() {
    final pos = LocalPosition(x: 0, y: 0);
    return DidMove(from: pos, to: pos);
  }

  @override
  void removeComponent(Entity entity) => entity.remove<DidMove>();
}

/// Metadata for the BlockedMove component, a transient event recording failed movement attempts.
///
/// This component is added when an entity tries to move to a blocked position.
/// It's primarily useful for debugging collision and movement systems.
class BlockedMoveMetadata extends ComponentMetadata {
  /// Theme used for property panel layout.
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'BlockedMove';

  @override
  bool hasComponent(Entity entity) => entity.has<BlockedMove>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.onEntityOnComponent<BlockedMove>(entity.id),
      builder: (context, snapshot) {
        final blockedMove = entity.get<BlockedMove>();
        if (blockedMove == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "attempted",
                label: "Attempted",
                value: '(${blockedMove.attempted.x}, ${blockedMove.attempted.y})',
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => BlockedMove(LocalPosition(x: 0, y: 0));

  @override
  void removeComponent(Entity entity) => entity.remove<BlockedMove>();
}
