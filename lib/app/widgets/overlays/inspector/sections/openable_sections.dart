import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';
import 'package:rogueverse/ecs/events.dart';

/// Metadata for the Openable component.
class OpenableMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 160);

  @override
  String get componentName => 'Openable';

  @override
  bool hasComponent(Entity entity) => entity.has<Openable>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<Openable>(entity.id),
      builder: (context, snapshot) {
        final openable = entity.get<Openable>();
        if (openable == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('openable_isOpen_${openable.isOpen}'),
              item: BoolPropertyItem(
                id: "isOpen",
                label: "Is Open",
                value: openable.isOpen,
                onChanged: (val) => entity.upsert(Openable(
                  isOpen: val,
                  openRenderablePath: openable.openRenderablePath,
                  closedRenderablePath: openable.closedRenderablePath,
                  blocksMovementWhenClosed: openable.blocksMovementWhenClosed,
                  blocksVisionWhenClosed: openable.blocksVisionWhenClosed,
                )),
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('openable_openPath_${openable.openRenderablePath}'),
              item: StringPropertyItem(
                id: "openRenderablePath",
                label: "Open Renderable",
                value: openable.openRenderablePath,
                onChanged: (val) => entity.upsert(Openable(
                  isOpen: openable.isOpen,
                  openRenderablePath: val,
                  closedRenderablePath: openable.closedRenderablePath,
                  blocksMovementWhenClosed: openable.blocksMovementWhenClosed,
                  blocksVisionWhenClosed: openable.blocksVisionWhenClosed,
                )),
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('openable_closedPath_${openable.closedRenderablePath}'),
              item: StringPropertyItem(
                id: "closedRenderablePath",
                label: "Closed Renderable",
                value: openable.closedRenderablePath,
                onChanged: (val) => entity.upsert(Openable(
                  isOpen: openable.isOpen,
                  openRenderablePath: openable.openRenderablePath,
                  closedRenderablePath: val,
                  blocksMovementWhenClosed: openable.blocksMovementWhenClosed,
                  blocksVisionWhenClosed: openable.blocksVisionWhenClosed,
                )),
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('openable_blocksMove_${openable.blocksMovementWhenClosed}'),
              item: BoolPropertyItem(
                id: "blocksMovementWhenClosed",
                label: "Blocks Movement",
                value: openable.blocksMovementWhenClosed,
                onChanged: (val) => entity.upsert(Openable(
                  isOpen: openable.isOpen,
                  openRenderablePath: openable.openRenderablePath,
                  closedRenderablePath: openable.closedRenderablePath,
                  blocksMovementWhenClosed: val,
                  blocksVisionWhenClosed: openable.blocksVisionWhenClosed,
                )),
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('openable_blocksVision_${openable.blocksVisionWhenClosed}'),
              item: BoolPropertyItem(
                id: "blocksVisionWhenClosed",
                label: "Blocks Vision",
                value: openable.blocksVisionWhenClosed,
                onChanged: (val) => entity.upsert(Openable(
                  isOpen: openable.isOpen,
                  openRenderablePath: openable.openRenderablePath,
                  closedRenderablePath: openable.closedRenderablePath,
                  blocksMovementWhenClosed: openable.blocksMovementWhenClosed,
                  blocksVisionWhenClosed: val,
                )),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => Openable(
        openRenderablePath: '',
        closedRenderablePath: '',
      );

  @override
  void removeComponent(Entity entity) => entity.remove<Openable>();
}

/// Metadata for the OpenIntent component.
class OpenIntentMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'OpenIntent';

  @override
  bool hasComponent(Entity entity) => entity.has<OpenIntent>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<OpenIntent>(entity.id),
      builder: (context, snapshot) {
        final intent = entity.get<OpenIntent>();
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
  Component createDefault() => OpenIntent(targetEntityId: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<OpenIntent>();
}

/// Metadata for the CloseIntent component.
class CloseIntentMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'CloseIntent';

  @override
  bool hasComponent(Entity entity) => entity.has<CloseIntent>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<CloseIntent>(entity.id),
      builder: (context, snapshot) {
        final intent = entity.get<CloseIntent>();
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
  Component createDefault() => CloseIntent(targetEntityId: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<CloseIntent>();
}

/// Metadata for the DidOpen component.
class DidOpenMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'DidOpen';

  @override
  bool hasComponent(Entity entity) => entity.has<DidOpen>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<DidOpen>(entity.id),
      builder: (context, snapshot) {
        final didOpen = entity.get<DidOpen>();
        if (didOpen == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "targetEntityId",
                label: "Target ID",
                value: didOpen.targetEntityId.toString(),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => DidOpen(targetEntityId: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<DidOpen>();
}

/// Metadata for the DidClose component.
class DidCloseMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'DidClose';

  @override
  bool hasComponent(Entity entity) => entity.has<DidClose>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<DidClose>(entity.id),
      builder: (context, snapshot) {
        final didClose = entity.get<DidClose>();
        if (didClose == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "targetEntityId",
                label: "Target ID",
                value: didClose.targetEntityId.toString(),
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => DidClose(targetEntityId: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<DidClose>();
}
