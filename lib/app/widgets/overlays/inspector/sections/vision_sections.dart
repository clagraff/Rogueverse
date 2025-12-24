import 'package:flutter/material.dart';

import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';
import 'package:rogueverse/ecs/ecs.barrel.dart';

/// Inspector section for VisionRadius component.
class VisionRadiusMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'Vision Radius';

  @override
  bool hasComponent(Entity entity) => entity.has<VisionRadius>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.onEntityOnComponent<VisionRadius>(entity.id),
      builder: (context, snapshot) {
        final vision = entity.get<VisionRadius>();
        if (vision == null) return const SizedBox.shrink();

        return Column(
          children: [
            PropertyRow(
              key: ValueKey('vision_radius_${vision.radius}'),
              item: IntPropertyItem(
                id: "radius",
                label: "Radius",
                value: vision.radius,
                onChanged: (val) => entity.upsert(VisionRadius(
                  radius: val,
                  fieldOfViewDegrees: vision.fieldOfViewDegrees,
                )),
              ),
              theme: _theme,
            ),
            PropertyRow(
              key: ValueKey('vision_fov_${vision.fieldOfViewDegrees}'),
              item: IntPropertyItem(
                id: "fov",
                label: "FOV (°)",
                value: vision.fieldOfViewDegrees,
                onChanged: (val) => entity.upsert(VisionRadius(
                  radius: vision.radius,
                  fieldOfViewDegrees: val,
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
  Component createDefault() => VisionRadius(radius: 5, fieldOfViewDegrees: 360);

  @override
  void removeComponent(Entity entity) => entity.remove<VisionRadius>();
}

/// Inspector section for VisibleEntities component (read-only).
class VisibleEntitiesMetadata extends ComponentMetadata {
  @override
  String get componentName => 'Visible Entities';

  @override
  bool hasComponent(Entity entity) => entity.has<VisibleEntities>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.onEntityOnComponent<VisibleEntities>(entity.id),
      builder: (context, snapshot) {
        final visible = entity.get<VisibleEntities>();
        if (visible == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Can See: ${visible.entityIds.length} entities',
                  style: const TextStyle(fontSize: 12)),
              Text('Visible Tiles: ${visible.visibleTiles.length}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }

  @override
  Component createDefault() => VisibleEntities();

  @override
  void removeComponent(Entity entity) => entity.remove<VisibleEntities>();
}

/// Inspector section for VisionMemory component (read-only).
class VisionMemoryMetadata extends ComponentMetadata {
  @override
  String get componentName => 'Vision Memory';

  @override
  bool hasComponent(Entity entity) => entity.has<VisionMemory>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.onEntityOnComponent<VisionMemory>(entity.id),
      builder: (context, snapshot) {
        final memory = entity.get<VisionMemory>();
        if (memory == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Remembered: ${memory.lastSeenPositions.length} entities',
                  style: const TextStyle(fontSize: 12)),
              if (memory.lastSeenPositions.isNotEmpty)
                ...memory.lastSeenPositions.entries.take(5).map((e) => Text(
                      '  Entity ${e.key} at (${e.value.x}, ${e.value.y})',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    )),
            ],
          ),
        );
      },
    );
  }

  @override
  Component createDefault() => VisionMemory();

  @override
  void removeComponent(Entity entity) => entity.remove<VisionMemory>();
}

/// Inspector section for BlocksSight component (marker).
class BlocksSightMetadata extends ComponentMetadata {
  @override
  String get componentName => 'Blocks Sight';

  @override
  bool hasComponent(Entity entity) => entity.has<BlocksSight>();

  @override
  Widget buildContent(Entity entity) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text('This entity blocks line of sight',
          style: TextStyle(fontSize: 12)),
    );
  }

  @override
  Component createDefault() => BlocksSight();

  @override
  void removeComponent(Entity entity) => entity.remove<BlocksSight>();
}

/// Inspector section for VisibilityState component (read-only).
// class VisibilityStateMetadata extends ComponentMetadata {
//   @override
//   String get componentName => 'Visibility State';
//
//   @override
//   bool hasComponent(Entity entity) => entity.has<VisibilityState>();
//
//   @override
//   Widget buildContent(Entity entity) {
//     return StreamBuilder<Change>(
//       stream: entity.parentCell.onEntityOnComponent<VisibilityState>(entity.id),
//       builder: (context, snapshot) {
//         final state = entity.get<VisibilityState>();
//         if (state == null) return const SizedBox.shrink();
//
//         final levelText = state.level.name.toUpperCase();
//         return Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text('Level: $levelText', style: const TextStyle(fontSize: 12)),
//         );
//       },
//     );
//   }
//
//   @override
//   Component createDefault() => VisibilityState();
//
//   @override
//   void removeComponent(Entity entity) => entity.remove<VisibilityState>();
// }
