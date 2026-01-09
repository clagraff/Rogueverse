import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';
import 'package:rogueverse/ecs/events.dart';

/// Metadata for the PortalToPosition component.
class PortalToPositionMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'PortalToPosition';

  @override
  bool hasComponent(Entity entity) => entity.has<PortalToPosition>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<PortalToPosition>(entity.id),
      builder: (context, snapshot) {
        final portal = entity.get<PortalToPosition>();
        if (portal == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('portal_destParent_${portal.destParentId}'),
              item: IntPropertyItem(
                id: "destParentId",
                label: "Dest Parent ID",
                value: portal.destParentId,
                onChanged: (val) => entity.upsert(PortalToPosition(
                  destParentId: val,
                  destLocation: portal.destLocation,
                  interactionRange: portal.interactionRange,
                )),
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('portal_destX_${portal.destLocation.x}'),
              item: IntPropertyItem(
                id: "destX",
                label: "Dest X",
                value: portal.destLocation.x,
                onChanged: (val) => entity.upsert(PortalToPosition(
                  destParentId: portal.destParentId,
                  destLocation: LocalPosition(x: val, y: portal.destLocation.y),
                  interactionRange: portal.interactionRange,
                )),
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('portal_destY_${portal.destLocation.y}'),
              item: IntPropertyItem(
                id: "destY",
                label: "Dest Y",
                value: portal.destLocation.y,
                onChanged: (val) => entity.upsert(PortalToPosition(
                  destParentId: portal.destParentId,
                  destLocation: LocalPosition(x: portal.destLocation.x, y: val),
                  interactionRange: portal.interactionRange,
                )),
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('portal_range_${portal.interactionRange}'),
              item: IntPropertyItem(
                id: "interactionRange",
                label: "Interaction Range",
                value: portal.interactionRange,
                onChanged: (val) => entity.upsert(PortalToPosition(
                  destParentId: portal.destParentId,
                  destLocation: portal.destLocation,
                  interactionRange: val,
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
  Component createDefault() => PortalToPosition(
        destParentId: 0,
        destLocation: LocalPosition(x: 0, y: 0),
      );

  @override
  void removeComponent(Entity entity) => entity.remove<PortalToPosition>();
}

/// Metadata for the PortalToAnchor component.
class PortalToAnchorMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'PortalToAnchor';

  @override
  bool hasComponent(Entity entity) => entity.has<PortalToAnchor>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<PortalToAnchor>(entity.id),
      builder: (context, snapshot) {
        final portal = entity.get<PortalToAnchor>();
        if (portal == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "anchors",
                label: "Anchor IDs",
                value: portal.destAnchorEntityIds.join(', '),
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('portal_offsetX_${portal.offsetX}'),
              item: IntPropertyItem(
                id: "offsetX",
                label: "Offset X",
                value: portal.offsetX,
                onChanged: (val) => entity.upsert(PortalToAnchor(
                  destAnchorEntityIds: portal.destAnchorEntityIds,
                  offsetX: val,
                  offsetY: portal.offsetY,
                  interactionRange: portal.interactionRange,
                )),
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('portal_offsetY_${portal.offsetY}'),
              item: IntPropertyItem(
                id: "offsetY",
                label: "Offset Y",
                value: portal.offsetY,
                onChanged: (val) => entity.upsert(PortalToAnchor(
                  destAnchorEntityIds: portal.destAnchorEntityIds,
                  offsetX: portal.offsetX,
                  offsetY: val,
                  interactionRange: portal.interactionRange,
                )),
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('portal_range_${portal.interactionRange}'),
              item: IntPropertyItem(
                id: "interactionRange",
                label: "Interaction Range",
                value: portal.interactionRange,
                onChanged: (val) => entity.upsert(PortalToAnchor(
                  destAnchorEntityIds: portal.destAnchorEntityIds,
                  offsetX: portal.offsetX,
                  offsetY: portal.offsetY,
                  interactionRange: val,
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
  Component createDefault() => PortalToAnchor(destAnchorEntityIds: []);

  @override
  void removeComponent(Entity entity) => entity.remove<PortalToAnchor>();
}

/// Metadata for the PortalAnchor marker component.
class PortalAnchorMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'PortalAnchor';

  @override
  bool hasComponent(Entity entity) => entity.has<PortalAnchor>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<PortalAnchor>(entity.id),
      builder: (context, snapshot) {
        final anchor = entity.get<PortalAnchor>();
        if (anchor == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('anchor_name_${anchor.anchorName}'),
              item: StringPropertyItem(
                id: "anchorName",
                label: "Anchor Name",
                value: anchor.anchorName ?? '',
                onChanged: (val) => entity.upsert(PortalAnchor(
                  anchorName: val.isEmpty ? null : val,
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
  Component createDefault() => PortalAnchor();

  @override
  void removeComponent(Entity entity) => entity.remove<PortalAnchor>();
}

/// Metadata for the UsePortalIntent component.
class UsePortalIntentMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'UsePortalIntent';

  @override
  bool hasComponent(Entity entity) => entity.has<UsePortalIntent>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<UsePortalIntent>(entity.id),
      builder: (context, snapshot) {
        final intent = entity.get<UsePortalIntent>();
        if (intent == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "portalEntityId",
                label: "Portal ID",
                value: intent.portalEntityId.toString(),
              ),
              theme: _theme,
            ),
            if (intent.specificAnchorId != null)
              PropertyRow(
                item: ReadonlyPropertyItem(
                  id: "specificAnchorId",
                  label: "Specific Anchor",
                  value: intent.specificAnchorId.toString(),
                ),
                theme: _theme,
              ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => UsePortalIntent(portalEntityId: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<UsePortalIntent>();
}

/// Metadata for the DidPortal component.
class DidPortalMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'DidPortal';

  @override
  bool hasComponent(Entity entity) => entity.has<DidPortal>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<DidPortal>(entity.id),
      builder: (context, snapshot) {
        final didPortal = entity.get<DidPortal>();
        if (didPortal == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "portalEntityId",
                label: "Portal ID",
                value: didPortal.portalEntityId.toString(),
              ),
              theme: _theme,
            ),
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "fromParent",
                label: "From Parent",
                value: didPortal.fromParentId.toString(),
              ),
              theme: _theme,
            ),
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "toParent",
                label: "To Parent",
                value: didPortal.toParentId.toString(),
              ),
              theme: _theme,
            ),
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "fromPos",
                label: "From Position",
                value: '(${didPortal.fromPosition.x}, ${didPortal.fromPosition.y})',
              ),
              theme: _theme,
            ),
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "toPos",
                label: "To Position",
                value: '(${didPortal.toPosition.x}, ${didPortal.toPosition.y})',
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => DidPortal(
        portalEntityId: 0,
        fromParentId: 0,
        toParentId: 0,
        fromPosition: LocalPosition(x: 0, y: 0),
        toPosition: LocalPosition(x: 0, y: 0),
      );

  @override
  void removeComponent(Entity entity) => entity.remove<DidPortal>();
}

/// Metadata for the FailedToPortal component.
class FailedToPortalMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'FailedToPortal';

  @override
  bool hasComponent(Entity entity) => entity.has<FailedToPortal>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<FailedToPortal>(entity.id),
      builder: (context, snapshot) {
        final failed = entity.get<FailedToPortal>();
        if (failed == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "portalEntityId",
                label: "Portal ID",
                value: failed.portalEntityId.toString(),
              ),
              theme: _theme,
            ),
            PropertyRow(
              item: ReadonlyPropertyItem(
                id: "reason",
                label: "Failure Reason",
                value: failed.reason.name,
              ),
              theme: _theme,
            ),
          ],
        );
      },
    );
  }

  @override
  Component createDefault() => FailedToPortal(
        portalEntityId: 0,
        reason: PortalFailureReason.portalNotFound,
      );

  @override
  void removeComponent(Entity entity) => entity.remove<FailedToPortal>();
}
