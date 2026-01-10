import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';

/// Metadata for the AttackIntent component.
class AttackIntentMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'AttackIntent';

  @override
  bool hasComponent(Entity entity) => entity.has<AttackIntent>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<AttackIntent>(entity.id),
      builder: (context, snapshot) {
        final intent = entity.get<AttackIntent>();
        if (intent == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "targetId",
                label: "Target ID",
                value: intent.targetId.toString(),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => AttackIntent(0);

  @override
  void removeComponent(Entity entity) => entity.remove<AttackIntent>();
}

/// Metadata for the DidAttack component.
class DidAttackMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'DidAttack';

  @override
  bool hasComponent(Entity entity) => entity.has<DidAttack>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<DidAttack>(entity.id),
      builder: (context, snapshot) {
        final didAttack = entity.get<DidAttack>();
        if (didAttack == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "targetId",
                label: "Target ID",
                value: didAttack.targetId.toString(),
              ),
              theme: _theme,
            ),
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "damage",
                label: "Damage",
                value: didAttack.damage.toString(),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => DidAttack(targetId: 0, damage: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<DidAttack>();
}

/// Metadata for the WasAttacked component.
class WasAttackedMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'WasAttacked';

  @override
  bool hasComponent(Entity entity) => entity.has<WasAttacked>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<WasAttacked>(entity.id),
      builder: (context, snapshot) {
        final wasAttacked = entity.get<WasAttacked>();
        if (wasAttacked == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "sourceId",
                label: "Source ID",
                value: wasAttacked.sourceId.toString(),
              ),
              theme: _theme,
            ),
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "damage",
                label: "Damage",
                value: wasAttacked.damage.toString(),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => WasAttacked(sourceId: 0, damage: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<WasAttacked>();
}
