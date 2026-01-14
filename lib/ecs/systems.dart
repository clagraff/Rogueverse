import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:math';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/events.dart';
import 'package:rogueverse/ecs/disposable.dart';

part 'systems.mapper.dart';

// TODO: Example of a potentially better way to do Systems
// abstract class ProcessingSystem extends System {
//   // Define a filter method that returns true for entities this system should process
//   bool filter(Entity entity);
//
//   // Process a single entity
//   void process(Entity entity, double dt);
//
//   @override
//   void update(Chunk world) {
//     // Find all entities that match the filter
//     for (final entity in world.entities.where(filter)) {
//       process(entity, world.deltaTime);
//     }
//   }
// }

/// A base class for all systems that operate over a [Chunk] of ECS data.
/// 
/// Systems execute in (ascending) priority order during World.tick():
/// - 0-50: Early systems (e.g., cache rebuilding, preprocessing)
/// - 100: Normal gameplay systems (default)
/// - 150+: Late systems (e.g., cleanup, post-processing)
@MappableClass()
abstract class System with SystemMappable {
  /// Execution priority. Lower numbers run first. Default is 100.
  int get priority => 100;
  
  void update(World world);

}

/// A base class for all systems which can operate with a time budget, outside
/// of normal ECS ticks.
@MappableClass()
abstract class BudgetedSystem extends System with BudgetedSystemMappable {
  bool budget(World world, Duration budget); // TODO return boolean to indicate if more processing is needed between game ticks?
}

/// System that maintains the hierarchy cache for fast parent-child queries.
///
/// This system rebuilds the World's hierarchyCache each tick from HasParent components.
/// Runs first (priority 0) to ensure cache is fresh for other systems.
@MappableClass()
class HierarchySystem extends System with HierarchySystemMappable {
  @override
  int get priority => 0; // Must run before other systems use hierarchy cache
  
  @override
  void update(World world) {
    Timeline.timeSync("HierarchySystem: update", () {
      world.hierarchyCache.rebuild(world);
    });
  }
}

/// A system that handles collision detection by checking for blocked movement.
///
/// If an entity attempts to move into an occupied tile, its move is cancelled.
/// Uses hierarchy-scoped queries: only checks collisions with sibling entities (same parent).
@MappableClass()
class CollisionSystem extends System with CollisionSystemMappable {
  static final _logger = Logger('CollisionSystem');
  
  @override
  void update(World world) {
    Timeline.timeSync("CollisionSystem: update", () {
      Timeline.startSync("CollisionSystem: gets");
      final positions = world.get<LocalPosition>();
      final blocks = world.get<BlocksMovement>();
      final moveIntents = world.get<MoveByIntent>();

      final movingEntityIds = moveIntents.keys.toList();
      Timeline.finishSync();

      if (blocks.isEmpty) return;

      for (final id in movingEntityIds) {
        final e = world.getEntity(id);
        final pos = e.get<LocalPosition>();
        final intent = e.get<MoveByIntent>();

        if (pos == null || intent == null) continue;

        final dest = LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy);
        var blocked = false;

        // Get entities to check for collisions
        // If entity has parent, only check siblings (same parent)
        // Otherwise, check all entities (backward compatibility)
        final parentId = e.get<HasParent>()?.parentEntityId;

        if (parentId != null) {
          // Hierarchy-scoped: check only siblings
          final siblings = world.hierarchyCache.getSiblings(id);

          for (final siblingId in siblings) {
            final sibling = world.getEntity(siblingId);
            if (!sibling.has<BlocksMovement>()) continue;

            final siblingPos = sibling.get<LocalPosition>();
            if (siblingPos != null &&
                siblingPos.x == dest.x &&
                siblingPos.y == dest.y) {
              blocked = true;
              break;
            }
          }
        } else {
          // No parent: check all entities (old behavior)
          positions.forEach((key, value) {
            if (value.x == dest.x &&
                value.y == dest.y &&
                world.getEntity(key).has<BlocksMovement>()) {
              blocked = true;
            }
          });
        }

        if (blocked) {
          // Update direction even when movement is blocked
          e.upsert(Direction(Direction.fromOffset(intent.dx, intent.dy)));
          e.upsert(BlockedMove(dest));
          e.remove<MoveByIntent>();

          _logger.finest("collision blocked", {"entity": e, "from": pos, "to": dest});
        }
      }
    });
  }
}

/// A system that processes unblocked movement requests.
///
/// Updates positions and adds [DidMove] to track movement history.
@MappableClass()
class MovementSystem extends System with MovementSystemMappable {
  static final _logger = Logger('MovementSystem');
  
  @override
  void update(World world) {
    Timeline.timeSync("MovementSystem: update", () {
      final moveIntents = world.get<MoveByIntent>();
      final ids = moveIntents.keys.toList();

      for (final id in ids) {
        final e = world.getEntity(id);
        _logger.finest("moving entity", {"entity": e});

        // Skip if entity is docked
        if (e.has<Docked>()) {
          _logger.finest("skipping docked entity movement", {"entity": e});
          continue;
        }

        final pos = e.get<LocalPosition>();
        final intent = e.get<MoveByIntent>();
        if (pos == null || intent == null) {
          _logger.warning("cannot move due to missing position or intent", {"entity": e, "pos": pos, "intent": intent});
          continue;
        }

        final from = LocalPosition(x: pos.x, y: pos.y);
        final to = LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy);

        e.upsert<LocalPosition>(
            LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy));

        // Update direction based on movement
        e.upsert(Direction(Direction.fromOffset(intent.dx, intent.dy)));

        e.upsert(DidMove(from: from, to: to));
        e.remove<MoveByIntent>();

        final direction = e.get<Direction>();
        _logger.finest("moved entity", {"entity": e, "from": from, "to": to, "direction": direction?.facing});
      }
    });
  }
}

@MappableClass()
class InventorySystem extends System with InventorySystemMappable {
  static final _logger = Logger('InventorySystem');
  
  final Query canPickup = Query().require<Inventory>().require<LocalPosition>();

  final Query canBePickedUp =
      Query().require<Pickupable>().require<LocalPosition>();

  @override
  void update(World world) {
    Timeline.timeSync("InventorySystem: update", () {

      final pickupIntents = world.get<PickupIntent>();
      if (pickupIntents.isEmpty) {
        return;
      }

      // need to use a copy so we can modify elements within our loop...
      var components = Map.from(pickupIntents);

      components.forEach((sourceId, intent) {
        var pickupIntent = intent as PickupIntent;
        var source = world.getEntity(sourceId);
        var target = world.getEntity(pickupIntent.targetEntityId);

        if (!canPickup.isMatchEntity(source) ||
            !canBePickedUp.isMatchEntity(target)) {
          return; // Skip. TODO: Add some kind of error feedback or message?
        }

        if (!source
            .get<LocalPosition>()!
            .sameLocation(target.get<LocalPosition>()!)) {
          return; // Skip
        }

        // At this point, no matter what happens, we can remove this intent.
        source.remove<PickupIntent>();

        var invMax = source.get<InventoryMaxCount>();
        if (invMax != null &&
            source.get<Inventory>()!.items.length + 1 > invMax.maxAmount) {
          // Inventory is maxed out, set a failure state and return.
          source.upsert<InventoryFullFailure>(InventoryFullFailure(target.id));
          return;
        }

        target
            .remove<Pickupable>(); // Cannot be picked up again once in inventory.
        target.remove<Renderable>();
        target.remove<LocalPosition>();

        source.upsert<Inventory>(Inventory([
          ...source.get<Inventory>()!.items,
          pickupIntent.targetEntityId
        ])); // Update inventory to include latest object
        source.upsert<PickedUp>(PickedUp(
            pickupIntent.targetEntityId)); // Allow for notifying of new item

        final targetPos = source.get<LocalPosition>();
        _logger.finest("picked up item", {"entity": source, "item": target, "pos": targetPos});
      });
    });
  }
}

@MappableClass()
class CombatSystem extends System with CombatSystemMappable {
  static final _logger = Logger('CombatSystem');
  
  @override
  void update(World world) {
    Timeline.timeSync("CombatSystem: update", () {
      final attackIntents = world.get<AttackIntent>();

      var components = Map.from(attackIntents);
      components.forEach((sourceId, intent) {
        var attackIntent = intent as AttackIntent;
        var source = world.getEntity(sourceId);
        
        // Skip if attacker is docked
        if (source.has<Docked>()) {
          _logger.finest("skipping docked entity combat", {"entity": source});
          source.remove<AttackIntent>();
          return;
        }
        
        var target = world.getEntity(attackIntent.targetId);

        var health = target.get<Health>(Health(0, 0))!;
        // TODO change how damage is calculated
        const damage = 1;
        health.current -= damage;

        _logger.finest("target damanged", {"attacker": source, "target": target, "damage": damage, "remainingHealth": health.current});

        if (health.current <= 0) {
          health.current = 0;

          // TODO: this doesnt actually prevent other systems from processing
          // this now-dead entity.
          target.upsert(Dead());
          target.remove<BlocksMovement>();

          _logger.fine('target killed', {'attacker': source, 'target': target});
        }
        target.upsert(WasAttacked(sourceId: sourceId, damage: 1));
        // TODO notify on health change?

        source.remove<AttackIntent>();
        source.upsert<DidAttack>(DidAttack(targetId: target.id, damage: 1));
      });
    });
  }
}


@MappableClass()
class BehaviorSystem extends BudgetedSystem with BehaviorSystemMappable {
  static final _logger = Logger('BehaviorSystem');
  final Queue<(Entity entity, Behavior behavior)> queue = Queue<(Entity entity, Behavior behavior)>();

  /// Schedule AI behaviors to be processed during the budget run.
  @override
  void update(World world) {
    Timeline.timeSync("BehaviorSystem: update", () {
      final behaviors = world.get<Behavior>();
      behaviors.forEach((e, b) {
        var entity = world.getEntity(e);
        queue.addLast((entity, b));
      });
    });
  }

  /// Process AI behavior trees within the given duration. May exceed duration.
  @override
  bool budget(World world, Duration budget) {
    return Timeline.timeSync("BehaviorSystem: budget", () {
      final sw = Stopwatch()..start();
      if (queue.isEmpty) {
        return false;
      }

      while (sw.elapsed < budget && queue.isNotEmpty) {
        var entry = queue.removeFirst();
        var entity =  entry.$1;
        var behaviorComponent = entry.$2;

        var result = behaviorComponent.behavior.tick(entity);
        _logger.finest("ran behavior tree", {"entity": entity, "node": behaviorComponent.behavior.runtimeType, "result": result});

        if (queue.isEmpty) {
          _logger.finest('behavior queue is empty');
          return false;
        }
      }

      return true;
    });
  }
}

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

/// System that processes control and docking intents.
///
/// Handles:
/// - WantsControlIntent: Grants control of an entity (e.g., vehicle) to an actor
/// - ReleasesControlIntent: Releases control, switching back to actor
/// - DockIntent: Adds Docked component (disables movement/combat)
/// - UndockIntent: Removes Docked component (re-enables movement/combat)
@MappableClass()
class ControlSystem extends System with ControlSystemMappable {
  static final _logger = Logger('ControlSystem');

  @override
  void update(World world) {
    Timeline.timeSync("ControlSystem: update", () {
      // 1. Process WantsControlIntent - grant control
      final wantsControlMap = world.get<WantsControlIntent>();
      for (final actorId in wantsControlMap.keys) {
        final intent = wantsControlMap[actorId]!;
        final actor = world.getEntity(actorId);
        final targetEntity = world.getEntity(intent.targetEntityId);

        if (targetEntity.has<EnablesControl>()) {
          final enablesControl = targetEntity.get<EnablesControl>()!;
          actor.upsert(Controlling(controlledEntityId: enablesControl.controlledEntityId));
          _logger.fine("actor granted control", {"actor": actor, "controlledEntityId": enablesControl.controlledEntityId});
        }
      }

      // 2. Process ReleasesControlIntent - release control
      final releasesControlMap = world.get<ReleasesControlIntent>();
      for (final controlledEntityId in releasesControlMap.keys) {
        // Find actor controlling this entity
        final controllingMap = world.get<Controlling>();

        for (final actorId in controllingMap.keys) {
          final controlling = controllingMap[actorId]!;
          if (controlling.controlledEntityId == controlledEntityId) {
            world.getEntity(actorId).remove<Controlling>();
            _logger.fine("actor released control", {"actorId": actorId, "controlledEntityId": controlledEntityId});
            break;
          }
        }
      }

      // 3. Process DockIntent - add Docked component
      final dockIntentMap = world.get<DockIntent>();
      for (final entityId in dockIntentMap.keys) {
        world.getEntity(entityId).upsert(Docked());
        _logger.fine("entity docked", {"entityId": entityId});
      }

      // 4. Process UndockIntent - remove Docked component
      final undockIntentMap = world.get<UndockIntent>();
      for (final entityId in undockIntentMap.keys) {
        world.getEntity(entityId).remove<Docked>();
        _logger.fine("entity undocked", {"entityId": entityId});
      }
    });
  }
}

/// System that processes open/close intents for Openable entities.
///
/// Handles:
/// - OpenIntent: Opens the target entity (swaps Renderable, removes blockers)
/// - CloseIntent: Closes the target entity (swaps Renderable, adds blockers)
///
/// The system synchronizes BlocksMovement and BlocksSight components based on
/// the Openable configuration and current state.
@MappableClass()
class OpenableSystem extends System with OpenableSystemMappable {
  static final _logger = Logger('OpenableSystem');

  @override
  void update(World world) {
    Timeline.timeSync("OpenableSystem: update", () {
      // Process OpenIntent
      final openIntents = Map.from(world.get<OpenIntent>());
      for (final entry in openIntents.entries) {
        final actorId = entry.key;
        final intent = entry.value as OpenIntent;
        final actor = world.getEntity(actorId);
        final target = world.getEntity(intent.targetEntityId);

        actor.remove<OpenIntent>();

        final openable = target.get<Openable>();
        if (openable == null) {
          _logger.warning("open target missing Openable component", {
            "actor": actor,
            "target": target,
          });
          continue;
        }

        if (openable.isOpen) {
          _logger.finest("target already open", {"target": target});
          continue;
        }

        // Open the entity
        openable.isOpen = true;
        target.upsert(Renderable(ImageAsset(openable.openRenderablePath)));

        // Remove blocking components
        if (openable.blocksMovementWhenClosed) {
          target.remove<BlocksMovement>();
        }
        if (openable.blocksVisionWhenClosed) {
          target.remove<BlocksSight>();
        }

        actor.upsert(DidOpen(targetEntityId: target.id));
        _logger.fine("opened entity", {"actor": actor, "target": target});
      }

      // Process CloseIntent
      final closeIntents = Map.from(world.get<CloseIntent>());
      for (final entry in closeIntents.entries) {
        final actorId = entry.key;
        final intent = entry.value as CloseIntent;
        final actor = world.getEntity(actorId);
        final target = world.getEntity(intent.targetEntityId);

        actor.remove<CloseIntent>();

        final openable = target.get<Openable>();
        if (openable == null) {
          _logger.warning("close target missing Openable component", {
            "actor": actor,
            "target": target,
          });
          continue;
        }

        if (!openable.isOpen) {
          _logger.finest("target already closed", {"target": target});
          continue;
        }

        // Close the entity
        openable.isOpen = false;
        target.upsert(Renderable(ImageAsset(openable.closedRenderablePath)));

        // Add blocking components based on configuration
        if (openable.blocksMovementWhenClosed) {
          target.upsert(BlocksMovement());
        }
        if (openable.blocksVisionWhenClosed) {
          target.upsert(BlocksSight());
        }

        actor.upsert(DidClose(targetEntityId: target.id));
        _logger.fine("closed entity", {"actor": actor, "target": target});
      }
    });
  }
}

/// System that processes portal usage intents.
///
/// Handles both PortalToPosition (fixed destination) and PortalToAnchor
/// (dynamic destination based on anchor entities) portal types.
@MappableClass()
class PortalSystem extends System with PortalSystemMappable {
  static final _logger = Logger('PortalSystem');

  @override
  void update(World world) {
    Timeline.timeSync("PortalSystem: update", () {
      final portalIntents = world.get<UsePortalIntent>();
      if (portalIntents.isEmpty) return;

      // Create copy to allow modification during iteration
      final components = Map.from(portalIntents);

      components.forEach((travelerId, intent) {
        final traveler = world.getEntity(travelerId);
        final portalIntent = intent as UsePortalIntent;

        _processPortalIntent(world, traveler, portalIntent);

        // Always remove intent after processing
        traveler.remove<UsePortalIntent>();
      });
    });
  }

  void _processPortalIntent(
      World world, Entity traveler, UsePortalIntent intent) {
    _logger.finest("processing portal intent", {"traveler": traveler, "intent": intent});

    final portal = world.getEntity(intent.portalEntityId);
    final travelerPos = traveler.get<LocalPosition>();

    // Validation: Check if traveler has required components
    if (travelerPos == null) {
      _logger.warning("traveler missing local position", {"traveler": traveler});
      _fail(traveler, intent.portalEntityId,
          PortalFailureReason.missingComponents);
      return;
    }

    // Validation: Check if traveler and portal share the same parent
    final travelerParentId = traveler.get<HasParent>()?.parentEntityId;
    final portalParentId = portal.get<HasParent>()?.parentEntityId;

    if (travelerParentId != portalParentId) {
      _logger.warning("mismatched parentId between traveler and portal", {"traveler": traveler, "travelerParentId": travelerParentId, "portalParentId": portalParentId});
      _fail(traveler, intent.portalEntityId, PortalFailureReason.notSameParent);
      return;
    }

    // Check for PortalToPosition or PortalToAnchor
    final toPosition = portal.get<PortalToPosition>();
    final toAnchor = portal.get<PortalToAnchor>();

    if (toPosition != null) {
      _handlePortalToPosition(world, traveler, portal, toPosition, travelerPos);
    } else if (toAnchor != null) {
      _handlePortalToAnchor(world, traveler, portal, toAnchor, travelerPos,
          intent.specificAnchorId);
    } else {
      _logger.warning("portal missing PortalToPosition/PortalToAnchor component", {"portal": portal});
      _fail(traveler, intent.portalEntityId, PortalFailureReason.portalNotFound);
    }
  }

  void _handlePortalToPosition(
    World world,
    Entity traveler,
    Entity portal,
    PortalToPosition portalConfig,
    LocalPosition travelerPos,
  ) {
    _logger.finest("portaling traveler", {"traveler": traveler, "destParentId": portalConfig.destParentId, "destLocalPosition": portalConfig.destLocation});
    final portalPos = portal.get<LocalPosition>();

    // Validation: Check interaction range
    if (!_isWithinRange(
        travelerPos, portalPos, portalConfig.interactionRange, traveler, portal, world)) {
      _logger.warning("traveler not in portal range", {"traveler": traveler, "portal": portal});
      _fail(traveler, portal.id, PortalFailureReason.outOfRange);
      return;
    }

    // Check if destination parent exists (check if any component exists for this entity ID)
    final destParentExists = world.components.values.any((componentMap) => 
        componentMap.containsKey(portalConfig.destParentId));
    if (!destParentExists) {
      _logger.warning("portal parent missing", {"portal": portal, "destParentId": portalConfig.destParentId});
      _fail(
          traveler, portal.id, PortalFailureReason.destinationParentNotFound);
      return;
    }

    // Check if destination is blocked
    // TODO: double-check this logic.
    if (_isDestinationBlocked(
        world, portalConfig.destParentId, portalConfig.destLocation, traveler.id)) {
      _logger.warning("portal destination blocked", {"traveler": traveler, "portal": portal, "portalConfig": portalConfig});
      _fail(traveler, portal.id, PortalFailureReason.destinationBlocked);
      return;
    }

    // Perform the portal!
    _teleport(
      world,
      traveler,
      portal.id,
      traveler.get<HasParent>()?.parentEntityId ?? -1,
      portalConfig.destParentId,
      travelerPos,
      portalConfig.destLocation,
      null, // No anchor used
    );
  }

  void _handlePortalToAnchor(
    World world,
    Entity traveler,
    Entity portal,
    PortalToAnchor portalConfig,
    LocalPosition travelerPos,
    int? specificAnchorId,
  ) {
    final portalPos = portal.get<LocalPosition>();

    // Validation: Check interaction range
    if (!_isWithinRange(
        travelerPos, portalPos, portalConfig.interactionRange, traveler, portal, world)) {
      _fail(traveler, portal.id, PortalFailureReason.outOfRange);
      return;
    }

    // Determine which anchor to use
    int? targetAnchorId;

    if (specificAnchorId != null) {
      // Use the specifically requested anchor if it's in the list
      if (portalConfig.destAnchorEntityIds.contains(specificAnchorId)) {
        targetAnchorId = specificAnchorId;
      } else {
        _fail(traveler, portal.id, PortalFailureReason.anchorNotFound);
        return;
      }
    } else {
      // No specific anchor requested, try anchors in order until one works
      for (final anchorId in portalConfig.destAnchorEntityIds) {
        final anchor = world.getEntity(anchorId);

        if (!anchor.has<PortalAnchor>()) continue;

        final anchorPos = anchor.get<LocalPosition>();
        final anchorParent = anchor.get<HasParent>();

        if (anchorPos == null || anchorParent == null) continue;

        // Calculate destination position (anchor + offset)
        final destPos = LocalPosition(
          x: anchorPos.x + portalConfig.offsetX,
          y: anchorPos.y + portalConfig.offsetY,
        );

        // Check if destination is blocked
        if (!_isDestinationBlocked(
            world, anchorParent.parentEntityId, destPos, traveler.id)) {
          // Found a valid anchor!
          targetAnchorId = anchorId;
          break;
        }
      }

      if (targetAnchorId == null) {
        _fail(traveler, portal.id, PortalFailureReason.noValidAnchors);
        return;
      }
    }

    // We have a valid anchor, perform the teleport
    final anchor = world.getEntity(targetAnchorId);
    final anchorPos = anchor.get<LocalPosition>()!;
    final anchorParent = anchor.get<HasParent>()!;

    final destPos = LocalPosition(
      x: anchorPos.x + portalConfig.offsetX,
      y: anchorPos.y + portalConfig.offsetY,
    );

    // Final check if destination is blocked (in case specificAnchorId was provided)
    if (_isDestinationBlocked(
        world, anchorParent.parentEntityId, destPos, traveler.id)) {
      _fail(traveler, portal.id, PortalFailureReason.destinationBlocked);
      return;
    }

    // Perform the portal!
    _teleport(
      world,
      traveler,
      portal.id,
      traveler.get<HasParent>()?.parentEntityId ?? -1,
      anchorParent.parentEntityId,
      travelerPos,
      destPos,
      targetAnchorId,
    );
  }

  bool _isWithinRange(
    LocalPosition travelerPos,
    LocalPosition? portalPos,
    int interactionRange,
    Entity traveler,
    Entity portal,
    World world,
  ) {
    // Range < 0: any distance allowed
    if (interactionRange < 0) return true;

    // No portal position means we can't check range
    if (portalPos == null) return false;

    // Range == 0: must be at exact same position
    if (interactionRange == 0) {
      return travelerPos.sameLocation(portalPos);
    }

    // Range > 0: within Manhattan distance
    final dx = (travelerPos.x - portalPos.x).abs();
    final dy = (travelerPos.y - portalPos.y).abs();
    final distance = dx + dy; // Manhattan distance

    return distance <= interactionRange;
  }

  bool _isDestinationBlocked(
    World world,
    int destParentId,
    LocalPosition destPos,
    int travelerId,
  ) {
    // Get all children in destination parent
    final children = world.hierarchyCache.getChildren(destParentId);

    for (final childId in children) {
      if (childId == travelerId) continue; // Don't check against self

      final child = world.getEntity(childId);
      if (!child.has<BlocksMovement>()) continue;

      final childPos = child.get<LocalPosition>();
      if (childPos != null && childPos.sameLocation(destPos)) {
        return true; // Destination is blocked
      }
    }

    return false;
  }

  void _teleport(
    World world,
    Entity traveler,
    int portalId,
    int fromParentId,
    int toParentId,
    LocalPosition fromPos,
    LocalPosition toPos,
    int? usedAnchorId,
  ) {
    // Update position
    traveler.upsert(LocalPosition(x: toPos.x, y: toPos.y));

    // Update parent if changing
    if (fromParentId != toParentId) {
      traveler.upsert(HasParent(toParentId));
    } else {
      _logger.finest("traveler already in same parent", {"traveler": traveler, "destParentId": toParentId});
    }

    // Add success component
    traveler.upsert(DidPortal(
      portalEntityId: portalId,
      fromParentId: fromParentId,
      toParentId: toParentId,
      fromPosition: fromPos,
      toPosition: toPos,
      usedAnchorId: usedAnchorId,
    ));

    // TODO: set entity direction based on Portal component (as an optional field in there).

    _logger.finest("portaled traveler", {
      "traveler": traveler,
      "portalId": portalId,
      "fromParentId": fromParentId,
      "toParentId": toParentId,
      "fromPos": fromPos,
      "toPos": toPos,
      "usedAnchorId": usedAnchorId != null
    });
  }

  // TODO: uh do we need this? we already have log statements for most of the failure conditions at the place they happened.
  void _fail(Entity traveler, int portalId, PortalFailureReason reason) {
    traveler.upsert(FailedToPortal(
      portalEntityId: portalId,
      reason: reason,
    ));

    _logger.warning(
        'portal_failed: entity=${traveler.id}, portal=$portalId, reason=$reason');
  }
}

/// System that periodically saves the world state.
///
/// Saves every [saveIntervalTicks] ticks to avoid saving too frequently
/// with periodic game ticks. Runs last (priority 200) to ensure all
/// other systems have processed before saving.
@MappableClass()
class SaveSystem extends System with SaveSystemMappable {
  static final _logger = Logger('SaveSystem');

  /// Number of ticks between saves. With 600ms ticks, 10 = ~6 seconds.
  static const int saveIntervalTicks = 10;

  @override
  int get priority => 200; // Run after all other systems

  @override
  void update(World world) {
    if (world.tickId % saveIntervalTicks == 0) {
      _logger.fine("periodic save triggered", {"tickId": world.tickId});
      WorldSaves.writeSavePatch(world);
    }
  }
}
