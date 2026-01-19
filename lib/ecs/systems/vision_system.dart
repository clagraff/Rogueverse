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
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'vision_system.mapper.dart';

@MappableClass()
class VisionSystem extends BudgetedSystem with VisionSystemMappable, Disposer {
  static final _logger = Logger('VisionSystem');

  /// Spatial index: parentId -> (x, y) -> Set of entityId
  /// Enables O(1) position lookups instead of O(n) scans
  /// null parentId = global entities without parent
  final Map<int?, Map<(int, int), Set<int>>> _positionIndex = {};

  /// Track which observers need vision recalculation this tick
  final Set<int> _dirtyObservers = {};

  /// Subscription to component changes (cleaned up via Disposer)
  StreamSubscription<Change>? _changeSubscription;

  /// Flag to ensure initialization happens only once
  bool _initialized = false;

  final Queue<Entity> queue = Queue<Entity>();

  /// Resets the spatial index and rebuilds it immediately.
  /// Also recalculates vision for all observers so VisibleEntities is fresh.
  /// Call this when the world is fully reloaded to force a rebuild.
  void resetState(World world) {
    _positionIndex.clear();
    _dirtyObservers.clear();
    queue.clear();
    // Cancel existing subscription to prevent processing stale changes
    _changeSubscription?.cancel();
    _changeSubscription = null;
    _initialized = false;
    // Immediately rebuild spatial index
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

  /// Lazy initialization: build spatial index and subscribe to changes
  void _ensureInitialized(World world) {
    if (_initialized) return;

    _logger.fine('vision system initializing');

    // Build initial spatial index from all existing LocalPosition components
    final positions = world.get<LocalPosition>();
    for (final entry in positions.entries) {
      final entityId = entry.key;
      final pos = entry.value;
      final parentId = world.getEntity(entityId).get<HasParent>()?.parentEntityId;

      _positionIndex
        .putIfAbsent(parentId, () => {})
        .putIfAbsent((pos.x, pos.y), () => {})
        .add(entityId);
    }

    // Subscribe to component changes for reactive updates
    _changeSubscription = world.componentChanges.listen((change) {
      _handleComponentChange(world, change);
    });
    toDispose(_changeSubscription!.cancel.asDisposable());

    _initialized = true;
    _logger.fine('vision system initialized', {"indexPositionsCount": positions.length});
  }

  /// Handle component changes and mark observers dirty as needed
  void _handleComponentChange(World world, Change change) {
    final entity = world.getEntity(change.entityId);

    // 1. Update spatial index for position changes
    if (change.componentType == 'LocalPosition') {
      _updatePositionIndex(change, world);
    }

    // 2. Handle HasParent changes (entity moving between hierarchy scopes)
    if (change.componentType == 'HasParent') {
      _handleParentChange(change, world);
    }

    // 3. Mark observers dirty when they change
    if (entity.has<VisionRadius>()) {
      // Observer moved, rotated, or vision config changed
      if (change.componentType == 'LocalPosition' ||
          change.componentType == 'Direction' ||
          change.componentType == 'VisionRadius') {
        _markObserverDirty(change.entityId);
        _logger.finest("marked observer dirty", {"observer": entity, "componentType": change.componentType, "reason": change.kind});
      }
    }

    // 4. VisionRadius added (new observer)
    if (change.componentType == 'VisionRadius' && change.kind == ChangeKind.added) {
      _markObserverDirty(change.entityId);
      _logger.finest("marked observer dirty", {"observer": entity, "componentType": change.componentType, "reason": change.kind});
    }

    // 5. Blocker moved or BlocksSight changed
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
  }

  /// Update spatial index when LocalPosition changes
  void _updatePositionIndex(Change change, World world) {
    final entity = world.getEntity(change.entityId);
    final parentId = entity.get<HasParent>()?.parentEntityId;

    // Remove from old position
    if (change.oldValue != null) {
      final oldPos = change.oldValue as LocalPosition;
      _positionIndex[parentId]?[(oldPos.x, oldPos.y)]?.remove(change.entityId);
    }

    // Add to new position
    if (change.kind == ChangeKind.added || change.kind == ChangeKind.updated) {
      final newPos = entity.get<LocalPosition>();
      if (newPos != null) {
        _positionIndex
          .putIfAbsent(parentId, () => {})
          .putIfAbsent((newPos.x, newPos.y), () => {})
          .add(change.entityId);
      }
    }
  }

  /// Handle entity reparenting (moving between hierarchy scopes)
  void _handleParentChange(Change change, World world) {
    final entity = world.getEntity(change.entityId);
    final pos = entity.get<LocalPosition>();

    if (pos != null) {
      // Remove from old parent's spatial index
      final oldParentId = (change.oldValue as HasParent?)?.parentEntityId;
      _positionIndex[oldParentId]?[(pos.x, pos.y)]?.remove(change.entityId);

      // Add to new parent's spatial index
      final newParentId = entity.get<HasParent>()?.parentEntityId;
      _positionIndex
        .putIfAbsent(newParentId, () => {})
        .putIfAbsent((pos.x, pos.y), () => {})
        .add(change.entityId);

      // Mark observers dirty in both old and new parent scopes
      _markObserversInRange(world, pos, oldParentId);
      _markObserversInRange(world, pos, newParentId);

      _logger.finest('vision_dirty_marked: reason=parent_change, entity=${change.entityId}');
    }

    // If the entity being reparented is an observer, mark it dirty
    if (entity.has<VisionRadius>()) {
      _markObserverDirty(change.entityId);
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

  /// Get entities at a specific position (O(1) lookup via spatial index)
  Set<int> _getEntitiesAtPosition(int x, int y, int? parentId) {
    return _positionIndex[parentId]?[(x, y)] ?? {};
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

    // Update observer's VisibleEntities component
    _logger.finest('vision_update: entity=$observerId, visible_tiles=${visibleTiles.length}, visible_entities=${visibleEntityIds.length}, position=(${observerPos.x},${observerPos.y})');
    observer.upsert(VisibleEntities(
      entityIds: visibleEntityIds,
      visibleTiles: visibleTiles,
    ));

    // Update memory (simple: just store last seen positions)
    _updateMemory(observer, visibleEntityIds, world);
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
    final entitiesAtPos = _getEntitiesAtPosition(x, y, parentId);

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
      final entitiesAtPos = _getEntitiesAtPosition(pos.x, pos.y, parentId);

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
