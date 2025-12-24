import 'package:flutter/foundation.dart';

import 'package:rogueverse/ecs/ecs.barrel.dart';

/// Vision mode determines how the camera aggregates vision data.
enum VisionMode {
  /// Show everything (default editor mode)
  showAll,

  /// Show based on player entity's vision
  player,

  /// Show based on specific selected entity's vision
  selectedEntity,
}

/// Manages vision aggregation and determines what entities should be visible.
/// Acts as the "camera" for the vision system, providing reactive updates.
class VisionCamera {
  VisionCamera(this.world);

  final World world;

  /// Current vision mode
  VisionMode mode = VisionMode.player;

  /// Currently selected entity ID (for selectedEntity mode)
  int? selectedEntityId;

  /// Active observers (entity IDs whose vision we're currently using)
  final activeObservers = ValueNotifier<Set<int>>({});

  /// Aggregated visible entities from active observers
  final visibleEntities = ValueNotifier<Set<int>>({});

  /// Aggregated remembered entities from active observers
  final rememberedEntities = ValueNotifier<Set<int>>({});

  /// Update vision based on current mode and observers.
  /// Call this after VisionSystem runs each tick.
  void updateVision() {
    final visible = <int>{};
    final remembered = <int>{};

    switch (mode) {
      case VisionMode.showAll:
        // Show everything - all entities are visible
        activeObservers.value = {};
        visible.addAll(world.get<LocalPosition>().keys);
        break;

      case VisionMode.player:
        // Use player-controlled entity's vision
        final playerIds = world.get<PlayerControlled>().keys;
        if (playerIds.isNotEmpty) {
          final playerId = playerIds.first;
          activeObservers.value = {playerId};
          _aggregateVision(playerId, visible, remembered);
        } else {
          // No player found, fall back to show all
          visible.addAll(world.get<LocalPosition>().keys);
        }
        break;

      case VisionMode.selectedEntity:
        // Use selected entity's vision if it has VisionRadius
        if (selectedEntityId != null) {
          final selectedEntity = world.getEntity(selectedEntityId!);
          if (selectedEntity.has<VisionRadius>()) {
            activeObservers.value = {selectedEntityId!};
            _aggregateVision(selectedEntityId!, visible, remembered);
          } else {
            // Selected entity has no vision, fall back to show all
            activeObservers.value = {};
            visible.addAll(world.get<LocalPosition>().keys);
          }
        } else {
          // No selection, fall back to show all
          visible.addAll(world.get<LocalPosition>().keys);
        }
        break;
    }

    visibleEntities.value = visible;
    rememberedEntities.value = remembered;
  }

  /// Aggregate vision from a specific observer entity.
  void _aggregateVision(int observerId, Set<int> visible, Set<int> remembered) {
    final observer = world.getEntity(observerId);

    // Get visible entities
    final visibleComponent = observer.get<VisibleEntities>();
    if (visibleComponent != null) {
      visible.addAll(visibleComponent.entityIds);
    }

    // Get remembered entities (excluding already visible)
    final memoryComponent = observer.get<VisionMemory>();
    if (memoryComponent != null) {
      for (final entityIdStr in memoryComponent.lastSeenPositions.keys) {
        final entityId = int.parse(entityIdStr);
        if (!visible.contains(entityId)) {
          remembered.add(entityId);
        }
      }
    }
  }

  /// Handle entity selection - switches to that entity's perspective if it has vision.
  void onEntitySelected(int entityId) {
    selectedEntityId = entityId;
    final entity = world.getEntity(entityId);

    if (entity.has<VisionRadius>()) {
      // Entity has vision - switch to its perspective
      mode = VisionMode.selectedEntity;
    } else {
      // Entity has no vision - show everything
      mode = VisionMode.showAll;
    }

    updateVision();
  }

  /// Handle entity deselection - switch back to player mode.
  void onEntityDeselected() {
    selectedEntityId = null;
    mode = VisionMode.player;
    updateVision();
  }

  /// Check if a specific entity should be visible based on current camera state.
  bool isEntityVisible(int entityId) {
    if (mode == VisionMode.showAll) return true;
    return visibleEntities.value.contains(entityId);
  }

  /// Check if a specific entity is in memory (seen before but not currently visible).
  bool isEntityRemembered(int entityId) {
    if (mode == VisionMode.showAll) return false;
    return rememberedEntities.value.contains(entityId);
  }

  /// Get the current active observer entity ID (for vision cone display).
  int? get currentObserverId {
    final observers = activeObservers.value;
    return observers.isEmpty ? null : observers.first;
  }
}
