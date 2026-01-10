import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';

/// Metadata for the Lifetime component, tracking components with limited lifespans.
///
/// This component tracks how many ticks remain before it expires. When lifetime
/// reaches 0, the component is removed during processing.
class LifetimeMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'Lifetime';

  @override
  bool hasComponent(Entity entity) => entity.has<Lifetime>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<Lifetime>(entity.id),
      builder: (context, snapshot) {
        final lifetime = entity.get<Lifetime>();
        if (lifetime == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: IntPropertyItem(
                id: "lifetime",
                label: "Ticks Remaining",
                value: lifetime.lifetime,
                onChanged: (value) {
                  lifetime.lifetime = value;
                  entity.upsertByName(lifetime);
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
  Component createDefault() => Lifetime(1);

  @override
  void removeComponent(Entity entity) => entity.remove<Lifetime>();
}

/// Metadata for the BeforeTick component, which is removed before tick update.
///
/// This component is used for temporary effects that should be cleared at the
/// start of each tick. It extends Lifetime, so it also has a remaining lifetime counter.
class BeforeTickMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'BeforeTick';

  @override
  bool hasComponent(Entity entity) => entity.has<BeforeTick>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<BeforeTick>(entity.id),
      builder: (context, snapshot) {
        final beforeTick = entity.get<BeforeTick>();
        if (beforeTick == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: IntPropertyItem(
                id: "lifetime",
                label: "Ticks Remaining",
                value: beforeTick.lifetime,
                onChanged: (value) {
                  beforeTick.lifetime = value;
                  entity.upsertByName(beforeTick);
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
  Component createDefault() => BeforeTick(0);

  @override
  void removeComponent(Entity entity) => entity.remove<BeforeTick>();
}

/// Metadata for the AfterTick component, which is removed after tick update.
///
/// This component is used for temporary effects that should be cleared at the
/// end of each tick. It extends Lifetime, so it also has a remaining lifetime counter.
class AfterTickMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'AfterTick';

  @override
  bool hasComponent(Entity entity) => entity.has<AfterTick>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<AfterTick>(entity.id),
      builder: (context, snapshot) {
        final afterTick = entity.get<AfterTick>();
        if (afterTick == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: IntPropertyItem(
                id: "lifetime",
                label: "Ticks Remaining",
                value: afterTick.lifetime,
                onChanged: (value) {
                  afterTick.lifetime = value;
                  entity.upsertByName(afterTick);
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
  Component createDefault() => AfterTick(0);

  @override
  void removeComponent(Entity entity) => entity.remove<AfterTick>();
}
