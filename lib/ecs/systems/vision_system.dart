import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:math';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/events.dart';
import 'package:rogueverse/ecs/systems/movement_system.dart';
import 'package:rogueverse/ecs/systems/portal_system.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'vision_system.mapper.dart';

@MappableClass()
class VisionSystem extends BudgetedSystem with VisionSystemMappable, Disposer {
  @override
  Set<Type> get runAfter => {MovementSystem, PortalSystem};
  static final _logger = Logger('VisionSystem');

  /// Track which observers need vision recalculation this tick
  final Set<int> _dirtyObservers = {};

  /// Subscription to component changes (cleaned up via Disposer)
  StreamSubscription<Change>? _changeSubscription;

  /// Flag to ensure initialization happens only once
  bool _initialized = false;

  final Queue<Entity> queue = Queue<Entity>();

  /// Resets the vision system state and recalculates vision for all observers.
  /// Call this when the world is fully reloaded to force a rebuild.
  /// Note: The spatial index is now managed by World.spatialService.
  void resetState(World world) {
    _dirtyObservers.clear();
    queue.clear();
    // Cancel existing subscription to prevent processing stale changes
    _changeSubscription?.cancel();
    _changeSubscription = null;
    _initialized = false;
    // Re-subscribe to changes
    _ensureInitialized(world);
    // Force recalculate vision for all observers so VisibleEntities is fresh
    final observers = world.get<VisionRadius>();
    for (final observerId in observers.keys) {
      _updateVisionForObserver(world, observerId);
    }
  }

  @override
  void update(World world) {
    Timeline.timeSync("VisionSystem: update", () {
      _ensureInitialized(world);

      // Only process observers marked dirty OR first-time (no VisibleEntities yet)
      final observers = world.get<VisionRadius>();

      for (final observerId in observers.keys) {
        final observer = world.getEntity(observerId);

        if (_dirtyObservers.contains(observerId) ||
            observer.get<VisibleEntities>() == null) {
          queue.addLast(observer);
          //_updateVisionForObserver(world, observerId);
        }
      }

      // Clear dirty set for next tick
      _dirtyObservers.clear();
    });
  }

  @override
  bool budget(World world, Duration budget) {
    return Timeline.timeSync("VisionSystem: budget", () {
      _ensureInitialized(world);

      final sw = Stopwatch()..start();

      // Transfer any dirty observers to queue immediately (don't wait for update())
      // This ensures reactive changes (e.g., BlocksSight added) are processed within one frame
      if (_dirtyObservers.isNotEmpty) {
        for (final observerId in _dirtyObservers) {
          final observer = world.getEntity(observerId);
          if (observer.has<VisionRadius>() && observer.get<VisibleEntities>() == null) {
            // First-time observer (no VisibleEntities yet)
            queue.addLast(observer);
          } else if (observer.has<VisionRadius>()) {
            // Existing observer that needs update
            queue.addLast(observer);
          }
        }
        _dirtyObservers.clear();
      }

      if (queue.isEmpty) {
        return false;
      }

      while (sw.elapsed < budget && queue.isNotEmpty) {
        var entity = queue.removeFirst();
        _updateVisionForObserver(world, entity.id);

        if (queue.isEmpty) {
          _logger.fine('vision system emptied queue');
          return false;
        }
      }

      return true;
    });
  }

  /// Manually update vision for a specific observer entity.
  /// Useful for immediately recalculating vision when observer changes.
  /// Marks observer dirty and processes immediately.
  void updateVisionForObserver(World world, int observerId) {
    _ensureInitialized(world);
    _markObserverDirty(observerId);
    _updateVisionForObserver(world, observerId);
  }

  /// Lazy initialization: subscribe to changes for dirty-flagging observers.
  /// The spatial index is now managed by World.spatialService.
  void _ensureInitialized(World world) {
    if (_initialized) return;

    _logger.fine('vision system initializing');

    // Subscribe to component changes for reactive dirty-flagging
    _changeSubscription = world.componentChanges.listen((change) {
      _handleComponentChange(world, change);
    });
    toDispose(_changeSubscription!.cancel.asDisposable());

    _initialized = true;
    _logger.fine('vision system initialized');
  }

  /// Handle component changes and mark observers dirty as needed.
  /// Note: Spatial index updates are now handled by World.spatialService.
  void _handleComponentChange(World world, Change change) {
    final entity = world.getEntity(change.entityId);

    // 1. Mark observers dirty when they change
    if (entity.has<VisionRadius>()) {
      // Observer moved, rotated, or vision config changed
      if (change.componentType == 'LocalPosition' ||
          change.componentType == 'Direction' ||
          change.componentType == 'VisionRadius') {
        _markObserverDirty(change.entityId);
        _logger.finest("marked observer dirty", {"observer": entity, "componentType": change.componentType, "reason": change.kind});
      }
    }

    // 2. VisionRadius added (new observer)
    if (change.componentType == 'VisionRadius' && change.kind == ChangeKind.added) {
      _markObserverDirty(change.entityId);
      _logger.finest("marked observer dirty", {"observer": entity, "componentType": change.componentType, "reason": change.kind});
    }

    // 3. Handle HasParent changes for observers
    if (change.componentType == 'HasParent' && entity.has<VisionRadius>()) {
      _markObserverDirty(change.entityId);
    }

    // 4. Blocker moved or BlocksSight changed - mark affected observers dirty
    if (change.componentType == 'LocalPosition' && entity.has<BlocksSight>()) {
      final parentId = entity.get<HasParent>()?.parentEntityId;
      final newPos = entity.get<LocalPosition>();

      // Mark observers that can see new position
      if (newPos != null) {
        _markObserversInRange(world, newPos, parentId);
      }

      // Also mark observers that could see old position
      if (change.oldValue != null) {
        final oldPos = change.oldValue as LocalPosition;
        _markObserversInRange(world, oldPos, parentId);
      }
    }

    if (change.componentType == 'BlocksSight') {
      final pos = entity.get<LocalPosition>();
      final parentId = entity.get<HasParent>()?.parentEntityId;

      if (pos != null) {
        _markObserversInRange(world, pos, parentId);
      }
    }

    // 5. LocalPosition removed (item picked up, entity destroyed) - remove
    // from all observers' VisibleEntities and VisionMemory
    if (change.componentType == 'LocalPosition' &&
        change.kind == ChangeKind.removed &&
        change.oldValue != null) {
      // Defer to avoid re-entrancy: can't emit events while processing an event
      scheduleMicrotask(() => _removeEntityFromAllObservers(world, change.entityId));
    }
  }

  /// Immediately removes an entity from all observers' VisibleEntities and VisionMemory.
  /// Called when an entity loses its LocalPosition (picked up, destroyed, etc.)
  void _removeEntityFromAllObservers(World world, int entityId) {
    final observers = world.get<VisionRadius>();
    final entityIdStr = entityId.toString();

    for (final observerId in observers.keys) {
      final observer = world.getEntity(observerId);

      // Remove from VisibleEntities
      final visibleEntities = observer.get<VisibleEntities>();
      if (visibleEntities != null && visibleEntities.entityIds.contains(entityId)) {
        final updatedIds = Set<int>.from(visibleEntities.entityIds)..remove(entityId);
        observer.upsert(VisibleEntities(
          entityIds: updatedIds,
          visibleTiles: visibleEntities.visibleTiles,
        ));
      }

      // Remove from VisionMemory
      final memory = observer.get<VisionMemory>();
      if (memory != null && memory.lastSeenPositions.containsKey(entityIdStr)) {
        final updatedMemory = Map<String, LocalPosition>.from(memory.lastSeenPositions)
          ..remove(entityIdStr);
        observer.upsert(VisionMemory(lastSeenPositions: updatedMemory));
      }
    }
  }

  /// Mark a single observer as needing vision recalculation
  void _markObserverDirty(int observerId) {
    _dirtyObservers.add(observerId);
  }

  /// Mark all observers in range of a position as dirty (optimal: only those who can see it)
  void _markObserversInRange(World world, LocalPosition pos, int? parentId) {
    final observers = world.get<VisionRadius>();
    int matchingParent = 0;
    int inRange = 0;
    int marked = 0;

    for (final entry in observers.entries) {
      final observerId = entry.key;
      final observer = world.getEntity(observerId);

      // Check hierarchy: only consider observers with same parent
      final observerParentId = observer.get<HasParent>()?.parentEntityId;
      if (observerParentId != parentId) continue;
      matchingParent++;

      final observerPos = observer.get<LocalPosition>();
      if (observerPos == null) continue;

      final visionRadius = entry.value;

      // Check if blocker position is within observer's max vision range
      final distance = sqrt(
        pow(pos.x - observerPos.x, 2) + pow(pos.y - observerPos.y, 2)
      );

      if (distance <= visionRadius.radius) {
        inRange++;

        // Additional check: is position within FOV cone?
        if (visionRadius.fieldOfViewDegrees < 360) {
          final direction = observer.get<Direction>();
          if (direction != null && !_isInFOVCone(observerPos, pos, direction, visionRadius)) {
            continue; // Outside FOV cone
          }
        }

        _markObserverDirty(observerId);
        marked++;
      }
    }

    _logger.finest('observer scan for position', {
      'x': pos.x,
      'y': pos.y,
      'parentId': parentId,
      'totalObservers': observers.length,
      'matchingParent': matchingParent,
      'inRange': inRange,
      'markedDirty': marked,
    });
  }

  /// Check if target position is within observer's FOV cone
  bool _isInFOVCone(LocalPosition observerPos, LocalPosition targetPos,
                    Direction direction, VisionRadius visionRadius) {
    // Calculate angle from observer to target
    final dx = targetPos.x - observerPos.x;
    final dy = targetPos.y - observerPos.y;
    final targetAngleRad = atan2(-dy.toDouble(), dx.toDouble());
    final targetAngle = (targetAngleRad * 180 / pi).round();

    final facingAngle = _directionToAngle(direction.facing);
    final halfFOV = visionRadius.fieldOfViewDegrees / 2;

    return _angleDifference(targetAngle, facingAngle) <= halfFOV;
  }

  /// Get entities at a specific position (O(1) lookup via shared spatial index)
  Set<int> _getEntitiesAtPosition(World world, int x, int y, int? parentId) {
    return world.spatial.getEntitiesAt(x, y, parentId: parentId);
  }

  void _updateVisionForObserver(World world, int observerId) {
    final observer = world.getEntity(observerId);
    final visionRadius = observer.get<VisionRadius>();
    if (visionRadius == null) return;

    final observerPos = observer.get<LocalPosition>();
    if (observerPos == null) return;

    final observerDirection = observer.get<Direction>();

    // Warn if entity has limited FOV but no Direction component
    if (visionRadius.fieldOfViewDegrees < 360 && observerDirection == null) {
      _logger.warning('limited FOV but no Direction', {'entityId': observerId});
    }

    // Calculate visible tiles using Bresenham raycasting
    final visibleTiles = _calculateVisibleTiles(
      world,
      observerPos,
      visionRadius,
      observerDirection,
      observerId,
    );

    // Find entities at visible positions (excluding the observer itself)
    final visibleEntityIds =
        _findEntitiesAtPositions(world, visibleTiles, observerId);

    // Update memory FIRST (so it's ready when VisibleEntities triggers subscriptions)
    // This ensures EntitySprite._updateVisibility has correct VisionMemory when it runs
    _updateMemory(observer, visibleEntityIds, world);

    // THEN update VisibleEntities (triggers EntitySprite subscriptions)
    _logger.finest('vision_update: entity=$observerId, visible_tiles=${visibleTiles.length}, visible_entities=${visibleEntityIds.length}, position=(${observerPos.x},${observerPos.y})');
    observer.upsert(VisibleEntities(
      entityIds: visibleEntityIds,
      visibleTiles: visibleTiles,
    ));
  }

  /// Calculate FOV using Bresenham raycasting with line-of-sight blocking
  /// Optimized: Uses Map<(int,int), bool> to avoid LocalPosition allocations
  Set<LocalPosition> _calculateVisibleTiles(
    World world,
    LocalPosition origin,
    VisionRadius visionRadius,
    Direction? direction,
    int observerId,
  ) {
    // Use Map with coordinate tuples to avoid object allocations during raycasting
    final visibleCoords = <(int, int)>{};
    visibleCoords.add((origin.x, origin.y)); // Observer can always see their own tile

    // Cast rays in a circle around the observer (every 5 degrees for performance)
    for (int angle = 0; angle < 360; angle += 5) {
      // Skip angles outside FOV cone if directional
      if (visionRadius.fieldOfViewDegrees < 360 && direction != null) {
        final facingAngle = _directionToAngle(direction.facing);
        final halfFOV = visionRadius.fieldOfViewDegrees / 2;
        final angleDiff = _angleDifference(angle, facingAngle);

        if (angleDiff > halfFOV) continue; // Outside FOV cone
      }

      // Cast ray using Bresenham's algorithm with callback
      var blocked = false;
      _castRay(origin, angle, visionRadius.radius, (x, y) {
        if (blocked) return; // Already hit a blocker, skip rest of ray

        visibleCoords.add((x, y));

        // Check if this tile blocks sight
        if (_isBlockedAtPositionCoords(world, x, y, observerId: observerId)) {
          blocked = true;
        }
      });
    }

    // Convert coordinate tuples to LocalPosition objects only at the end
    return visibleCoords.map((coord) => LocalPosition(x: coord.$1, y: coord.$2)).toSet();
  }

  /// Bresenham line algorithm from origin at angle for distance
  /// Optimized: Uses callback to avoid allocations
  void _castRay(
      LocalPosition origin, int angleDegrees, int distance, void Function(int x, int y) callback) {
    final angleRad = angleDegrees * (3.14159265359 / 180.0);
    final endX = origin.x + (distance * cos(angleRad)).round();
    // Negate Y because screen coordinates have Y increasing downward,
    // but sin() assumes Y increases upward (standard math coordinates)
    final endY = origin.y - (distance * sin(angleRad)).round();

    _bresenhamLine(origin.x, origin.y, endX, endY, callback);
  }

  /// Classic Bresenham line algorithm
  /// Optimized: Uses callback to avoid allocating LocalPosition objects
  void _bresenhamLine(int x0, int y0, int x1, int y1, void Function(int x, int y) callback) {
    int dx = (x1 - x0).abs();
    int dy = (y1 - y0).abs();
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx - dy;

    int x = x0;
    int y = y0;

    while (true) {
      callback(x, y);

      if (x == x1 && y == y1) break;

      int e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x += sx;
      }
      if (e2 < dx) {
        err += dx;
        y += sy;
      }
    }
  }

  /// Check if position blocks sight using coordinates (O(1) via spatial index)
  /// Optimized version that avoids LocalPosition parameter overhead
  bool _isBlockedAtPositionCoords(World world, int x, int y, {int? observerId}) {
    int? parentId;

    if (observerId != null) {
      final observer = world.getEntity(observerId);
      parentId = observer.get<HasParent>()?.parentEntityId;
    }

    // Get all entities at this position (O(1) spatial index lookup)
    final entitiesAtPos = _getEntitiesAtPosition(world, x, y, parentId);

    // Check if any of them block sight
    return entitiesAtPos.any((entityId) {
      return world.getEntity(entityId).has<BlocksSight>();
    });
  }

  /// Find entities at visible positions (O(1) per position via spatial index)
  /// If observer has parent, only finds sibling entities. Otherwise finds all entities.
  /// Excludes the observer itself.
  Set<int> _findEntitiesAtPositions(
      World world, Set<LocalPosition> positions, int observerId) {
    final entityIds = <int>{};
    final observer = world.getEntity(observerId);
    final parentId = observer.get<HasParent>()?.parentEntityId;

    // For each visible position, get all entities there (O(1) lookup)
    for (final pos in positions) {
      final entitiesAtPos = _getEntitiesAtPosition(world, pos.x, pos.y, parentId);

      // Add all except the observer itself
      for (final entityId in entitiesAtPos) {
        if (entityId != observerId) {
          entityIds.add(entityId);
        }
      }
    }

    return entityIds;
  }

  /// Update memory (simple: just store positions, no decay)
  void _updateMemory(Entity observer, Set<int> visibleEntityIds, World world) {
    var memory = observer.get<VisionMemory>() ?? VisionMemory();
    final updated = Map<String, LocalPosition>.from(memory.lastSeenPositions);

    // Clean up memory entries for entities that no longer have a position
    // (e.g., picked up items, destroyed entities)
    final toRemove = <String>[];
    for (final entityIdStr in updated.keys) {
      final entityId = int.tryParse(entityIdStr);
      if (entityId == null) continue;

      final entity = world.getEntity(entityId);
      // Remove if entity has no position (picked up, destroyed, etc.)
      if (!entity.has<LocalPosition>()) {
        toRemove.add(entityIdStr);
      }
    }
    for (final key in toRemove) {
      updated.remove(key);
    }

    // Add/update visible entities
    for (final entityId in visibleEntityIds) {
      final entity = world.getEntity(entityId);
      final pos = entity.get<LocalPosition>();
      if (pos != null) {
        updated[entityId.toString()] = pos;
      }
    }

    observer.upsert(VisionMemory(lastSeenPositions: updated));
  }

  /// Helper: Convert Direction to angle
  int _directionToAngle(CompassDirection dir) {
    switch (dir) {
      case CompassDirection.east:
        return 0;
      case CompassDirection.northeast:
        return 45;
      case CompassDirection.north:
        return 90;
      case CompassDirection.northwest:
        return 135;
      case CompassDirection.west:
        return 180;
      case CompassDirection.southwest:
        return 225;
      case CompassDirection.south:
        return 270;
      case CompassDirection.southeast:
        return 315;
    }
  }

  /// Helper: Shortest angle difference
  int _angleDifference(int a, int b) {
    int diff = (a - b).abs() % 360;
    return diff > 180 ? 360 - diff : diff;
  }
}
