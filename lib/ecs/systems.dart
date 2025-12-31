import 'dart:math';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/ecs/entity.dart';

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
@MappableClass()
abstract class System with SystemMappable {
  void update(World world);
}

/// System that maintains the hierarchy cache for fast parent-child queries.
///
/// This system rebuilds the World's hierarchyCache each tick from HasParent components.
/// Should run first in the system execution order to ensure cache is fresh for other systems.
@MappableClass()
class HierarchySystem extends System with HierarchySystemMappable {
  @override
  void update(World world) {
    world.hierarchyCache.rebuild(world);
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
    final positions = world.get<LocalPosition>();
    final blocks = world.get<BlocksMovement>();
    final moveIntents = world.get<MoveByIntent>();

    final movingEntityIds = moveIntents.keys.toList();

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
        
        _logger.finest('collision_blocked: entity=$id, from=(${pos.x},${pos.y}), to=(${dest.x},${dest.y})');
      }
    }
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
    final moveIntents = world.get<MoveByIntent>();
    final ids = moveIntents.keys.toList();

    for (final id in ids) {
      final e = world.getEntity(id);
      final pos = e.get<LocalPosition>();
      final intent = e.get<MoveByIntent>();
      if (pos == null || intent == null) continue;

      final from = LocalPosition(x: pos.x, y: pos.y);
      final to = LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy);
      //e.set(to);

      e.upsert<LocalPosition>(
          LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy));

      // Update direction based on movement
      e.upsert(Direction(Direction.fromOffset(intent.dx, intent.dy)));

      e.upsert(DidMove(from: from, to: to));
      e.remove<MoveByIntent>();
      
      final direction = e.get<Direction>();
      _logger.finest('entity_moved: id=$id, from=(${from.x},${from.y}), to=(${to.x},${to.y}), direction=${direction?.facing}');
    }
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
      _logger.info('item_pickup: entity=$sourceId, item=${pickupIntent.targetEntityId}, position=(${targetPos?.x},${targetPos?.y})');
    });
  }
}

@MappableClass()
class CombatSystem extends System with CombatSystemMappable {
  static final _logger = Logger('CombatSystem');
  
  @override
  void update(World world) {
    final attackIntents = world.get<AttackIntent>();

    var components = Map.from(attackIntents);
    components.forEach((sourceId, intent) {
      var attackIntent = intent as AttackIntent;
      var source = world.getEntity(sourceId);
      var target = world.getEntity(attackIntent.targetId);

      var health = target.get<Health>(Health(0, 0))!;
      // TODO change how damage is calculated
      const damage = 1;
      health.current -= damage;
      
      _logger.info('combat_damage: attacker=$sourceId, target=${attackIntent.targetId}, damage=$damage, remaining_health=${health.current}');
      
      if (health.current <= 0) {
        health.current = 0;

        // TODO: this doesnt actually prevent other systems from processing
        // this now-dead entity.
        target.upsert(Dead());
        target.remove<BlocksMovement>();
        
        _logger.info('combat_defeat: attacker=$sourceId, target=${attackIntent.targetId}');

        var r = Random();
        var lootTable = target.get<LootTable>();
        if (lootTable != null) {
          for (var lootable in lootTable.lootables) {
            var prob = r.nextDouble() * (1 + double.minPositive);
            if (prob <= lootable.probability) {
              var inv = target.get<Inventory>(Inventory(
                  []))!; // Create inventory comp if it doesnt exist. Otherwise we cannot do anything from the LootTable
              for (var i = 0; i < lootable.quantity; i++) {
                var item = world.add([]);

                for (var c in lootable.components) {
                  // Have to do things the hard way to avoid `dynamic` component types in the components map.
                  var comp = world.components.putIfAbsent(
                      c.componentType,
                      () =>
                          {}); // TODO must never update `world.components` directly as it side-steps our notifications.
                  comp[item.id] = c;
                }

                inv.items.add(item.id);
              }
            }
          }
        }
      }
      target.upsert(WasAttacked(sourceId: sourceId, damage: 1));
      // TODO notify on health change?

      source.remove<AttackIntent>();
      source.upsert<DidAttack>(DidAttack(targetId: target.id, damage: 1));
    });
  }
}

@MappableClass()
class BehaviorSystem extends System with BehaviorSystemMappable {
  static final _logger = Logger('BehaviorSystem');
  
  @override
  void update(World world) {
    final behaviors = world.get<Behavior>();
    behaviors.forEach((e, b) {
      var entity = world.getEntity(e);
      var result = b.behavior
          .tick(entity); // TODO i dont know what to do with the result....
      
      _logger.fine('behavior_tick: entity=$e, node=${b.behavior.runtimeType}, result=$result');
    });
  }
}

@MappableClass()
class VisionSystem extends System with VisionSystemMappable {
  static final _logger = Logger('VisionSystem');
  
  @override
  void update(World world) {
    // Only process entities with VisionRadius (explicit opt-in for performance)
    final observers = world.get<VisionRadius>();

    observers.forEach((observerId, visionRadius) {
      _updateVisionForObserver(world, observerId);
    });
  }

  /// Manually update vision for a specific observer entity.
  /// Useful for immediately recalculating vision when observer changes.
  void updateVisionForObserver(World world, int observerId) {
    _updateVisionForObserver(world, observerId);
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
    _logger.fine('vision_update: entity=$observerId, visible_tiles=${visibleTiles.length}, visible_entities=${visibleEntityIds.length}, position=(${observerPos.x},${observerPos.y})');
    observer.upsert(VisibleEntities(
      entityIds: visibleEntityIds,
      visibleTiles: visibleTiles,
    ));

    // Update memory (simple: just store last seen positions)
    _updateMemory(observer, visibleEntityIds, world);
  }

  /// Calculate FOV using Bresenham raycasting with line-of-sight blocking
  Set<LocalPosition> _calculateVisibleTiles(
    World world,
    LocalPosition origin,
    VisionRadius visionRadius,
    Direction? direction,
    int observerId,
  ) {
    final visible = <LocalPosition>{};
    visible.add(origin); // Observer can always see their own tile

    // Cast rays in a circle around the observer (every 2 degrees for performance)
    for (int angle = 0; angle < 360; angle += 2) {
      // Skip angles outside FOV cone if directional
      if (visionRadius.fieldOfViewDegrees < 360 && direction != null) {
        final facingAngle = _directionToAngle(direction.facing);
        final halfFOV = visionRadius.fieldOfViewDegrees / 2;
        final angleDiff = _angleDifference(angle, facingAngle);

        if (angleDiff > halfFOV) continue; // Outside FOV cone
      }

      // Cast ray using Bresenham's algorithm
      final rayTiles = _castRay(origin, angle, visionRadius.radius);

      for (final tile in rayTiles) {
        visible.add(tile);

        // Stop ray if blocked by BlocksSight
        if (_isBlockedAtPosition(world, tile, observerId: observerId)) break;
      }
    }

    return visible;
  }

  /// Bresenham line algorithm from origin at angle for distance
  List<LocalPosition> _castRay(
      LocalPosition origin, int angleDegrees, int distance) {
    final angleRad = angleDegrees * (3.14159265359 / 180.0);
    final endX = origin.x + (distance * cos(angleRad)).round();
    // Negate Y because screen coordinates have Y increasing downward,
    // but sin() assumes Y increases upward (standard math coordinates)
    final endY = origin.y - (distance * sin(angleRad)).round();

    return _bresenhamLine(origin.x, origin.y, endX, endY);
  }

  /// Classic Bresenham line algorithm
  List<LocalPosition> _bresenhamLine(int x0, int y0, int x1, int y1) {
    final points = <LocalPosition>[];

    int dx = (x1 - x0).abs();
    int dy = (y1 - y0).abs();
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx - dy;

    int x = x0;
    int y = y0;

    while (true) {
      points.add(LocalPosition(x: x, y: y));

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

    return points;
  }

  /// Check if position blocks sight
  /// If observerId has a parent, only check siblings. Otherwise check all entities.
  bool _isBlockedAtPosition(World world, LocalPosition pos, {int? observerId}) {
    final positions = world.get<LocalPosition>();

    // If observer has parent, only check siblings for blocking sight
    if (observerId != null) {
      final observer = world.getEntity(observerId);
      final parentId = observer.get<HasParent>()?.parentEntityId;

      if (parentId != null) {
        final siblings = world.hierarchyCache.getSiblings(observerId);

        return siblings.any((siblingId) {
          final sibling = world.getEntity(siblingId);
          if (!sibling.has<BlocksSight>()) return false;

          final siblingPos = sibling.get<LocalPosition>();
          return siblingPos != null &&
              siblingPos.x == pos.x &&
              siblingPos.y == pos.y;
        });
      }
    }

    // No parent or no observerId: check all entities (old behavior)
    return positions.entries.any((entry) {
      final entityPos = entry.value;
      if (entityPos.x != pos.x || entityPos.y != pos.y) return false;

      final entity = world.getEntity(entry.key);
      return entity.has<BlocksSight>();
    });
  }

  /// Find entities at visible positions (excluding the observer itself)
  /// If observer has parent, only finds sibling entities. Otherwise finds all entities.
  Set<int> _findEntitiesAtPositions(
      World world, Set<LocalPosition> positions, int observerId) {
    final entityIds = <int>{};

    final observer = world.getEntity(observerId);
    final parentId = observer.get<HasParent>()?.parentEntityId;

    if (parentId != null) {
      // Hierarchy-scoped: only find siblings
      final siblings = world.hierarchyCache.getSiblings(observerId);

      for (final siblingId in siblings) {
        final sibling = world.getEntity(siblingId);
        final siblingPos = sibling.get<LocalPosition>();

        if (siblingPos != null &&
            positions.any((p) => p.x == siblingPos.x && p.y == siblingPos.y)) {
          entityIds.add(siblingId);
        }
      }
    } else {
      // No parent: check all entities (old behavior)
      final allPositions = world.get<LocalPosition>();

      for (final entry in allPositions.entries) {
        final entityId = entry.key;

        // Skip the observer itself - it shouldn't see itself
        if (entityId == observerId) continue;

        final entityPos = entry.value;
        if (positions.any((p) => p.x == entityPos.x && p.y == entityPos.y)) {
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
