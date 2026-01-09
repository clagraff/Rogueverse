import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';
import 'package:rogueverse/ecs/events.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/sections/marker_sections.dart';

/// Metadata for the Controllable marker component.
class ControllableMetadata extends MarkerComponentMetadata {
  @override
  String get componentName => 'Controllable';

  @override
  bool hasComponent(Entity entity) => entity.has<Controllable>();

  @override
  Component createDefault() => Controllable();

  @override
  void removeComponent(Entity entity) => entity.remove<Controllable>();
}

/// Metadata for the Controlling component.
class ControllingMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'Controlling';

  @override
  bool hasComponent(Entity entity) => entity.has<Controlling>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<Controlling>(entity.id),
      builder: (context, snapshot) {
        final controlling = entity.get<Controlling>();
        if (controlling == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "controlledEntityId",
                label: "Controlled ID",
                value: controlling.controlledEntityId.toString(),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => Controlling(controlledEntityId: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<Controlling>();
}

/// Metadata for the EnablesControl component.
class EnablesControlMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'EnablesControl';

  @override
  bool hasComponent(Entity entity) => entity.has<EnablesControl>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<EnablesControl>(entity.id),
      builder: (context, snapshot) {
        final enables = entity.get<EnablesControl>();
        if (enables == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('enables_${enables.controlledEntityId}'),
              item: IntPropertyItem(
                id: "controlledEntityId",
                label: "Controlled ID",
                value: enables.controlledEntityId,
                onChanged: (val) => entity.upsert(EnablesControl(controlledEntityId: val)),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => EnablesControl(controlledEntityId: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<EnablesControl>();
}

/// Metadata for the Docked marker component.
class DockedMetadata extends MarkerComponentMetadata {
  @override
  String get componentName => 'Docked';

  @override
  bool hasComponent(Entity entity) => entity.has<Docked>();

  @override
  Component createDefault() => Docked();

  @override
  void removeComponent(Entity entity) => entity.remove<Docked>();
}

/// Metadata for the WantsControlIntent component.
class WantsControlIntentMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'WantsControlIntent';

  @override
  bool hasComponent(Entity entity) => entity.has<WantsControlIntent>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<WantsControlIntent>(entity.id),
      builder: (context, snapshot) {
        final intent = entity.get<WantsControlIntent>();
        if (intent == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "targetEntityId",
                label: "Target ID",
                value: intent.targetEntityId.toString(),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => WantsControlIntent(targetEntityId: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<WantsControlIntent>();
}

/// Metadata for the ReleasesControlIntent marker component.
class ReleasesControlIntentMetadata extends MarkerComponentMetadata {
  @override
  String get componentName => 'ReleasesControlIntent';

  @override
  bool hasComponent(Entity entity) => entity.has<ReleasesControlIntent>();

  @override
  Component createDefault() => ReleasesControlIntent();

  @override
  void removeComponent(Entity entity) => entity.remove<ReleasesControlIntent>();
}

/// Metadata for the DockIntent marker component.
class DockIntentMetadata extends MarkerComponentMetadata {
  @override
  String get componentName => 'DockIntent';

  @override
  bool hasComponent(Entity entity) => entity.has<DockIntent>();

  @override
  Component createDefault() => DockIntent();

  @override
  void removeComponent(Entity entity) => entity.remove<DockIntent>();
}

/// Metadata for the UndockIntent marker component.
class UndockIntentMetadata extends MarkerComponentMetadata {
  @override
  String get componentName => 'UndockIntent';

  @override
  bool hasComponent(Entity entity) => entity.has<UndockIntent>();

  @override
  Component createDefault() => UndockIntent();

  @override
  void removeComponent(Entity entity) => entity.remove<UndockIntent>();
}
