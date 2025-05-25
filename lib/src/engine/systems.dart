import 'dart:math';

import 'components.dart';
import 'ecs.dart';
import 'events.dart';

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
abstract class System {
  static const int defaultPriority = 1;

  /// Systems are executed in ascending order of priority.
  int get priority => System.defaultPriority;

  /// Called once per tick to apply logic to the given [world].
  void update(Chunk world);

  void update2(EcsWorld world, Cell cell);
}

/// A system that handles collision detection by checking for blocked movement.
///
/// If an entity attempts to move into an occupied tile, its move is cancelled.
class CollisionSystem extends System {
  @override
  int get priority => 1;

  @override
  void update(Chunk world) {
    final positions = world.components<LocalPosition>();
    final blocks = world.components<BlocksMovement>();
    final moveIntents = world.components<MoveByIntent>();

    final movingEntityIds = moveIntents.ids;

    if (blocks.components.isEmpty) return;

    for (final id in movingEntityIds) {
      final e = world.entity(id);
      final pos = e.get<LocalPosition>();
      final intent = e.get<MoveByIntent>();

      if (pos == null || intent == null) continue;

      final dest = LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy);
      var blocked = false;

      positions.components.forEach((key, value) {
        if (value.x == dest.x &&
            value.y == dest.y &&
            world.has<BlocksMovement>(key)) {
          blocked = true;
        }
      });

      if (blocked) {
        e.set(BlockedMove(dest));
        e.remove<MoveByIntent>();
      }
    }
  }

  @override
  void update2(EcsWorld world, Cell cell) {
    final positions = cell.get<LocalPosition>();
    final blocks = cell.get<BlocksMovement>();
    final moveIntents = cell.get<MoveByIntent>();

    final movingEntityIds = moveIntents.keys.toList();

    if (blocks.isEmpty) return;

    for (final id in movingEntityIds) {
      final e = cell.getEntity(id);
      final pos = e.get<LocalPosition>();
      final intent = e.get<MoveByIntent>();

      if (pos == null || intent == null) continue;

      final dest = LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy);
      var blocked = false;

      positions.forEach((key, value) {
        if (value.x == dest.x &&
            value.y == dest.y &&
            cell.getEntity(key).has<BlocksMovement>()) {
          blocked = true;
        }
      });

      if (blocked) {
        e.upsert(BlockedMove(dest));
        e.remove<MoveByIntent>();
      }
    }
  }
}

/// A system that processes unblocked movement requests.
///
/// Updates positions and adds [DidMove] to track movement history.
class MovementSystem extends System {
  @override
  int get priority => CollisionSystem().priority + 1;

  @override
  void update(Chunk world) {
    final moveIntents = world.components<MoveByIntent>();
    final ids = List<int>.from(moveIntents.components.keys);

    for (final id in ids) {
      final e = world.entity(id);
      final pos = e.get<LocalPosition>();
      final intent = e.get<MoveByIntent>();
      if (pos == null || intent == null) continue;

      final from = LocalPosition(x: pos.x, y: pos.y);
      final to = LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy);
      //e.set(to);

      e.update<LocalPosition>((p) {
        p.x = pos.x + intent.dx;
        p.y = pos.y + intent.dy;
      });

      e.set(DidMove(from: from, to: to));
      e.remove<MoveByIntent>();
    }
  }

  @override
  void update2(EcsWorld world, Cell cell) {
    final moveIntents = cell.get<MoveByIntent>();
    final ids = moveIntents.keys.toList();

    for (final id in ids) {
      final e = cell.getEntity(id);
      final pos = e.get<LocalPosition>();
      final intent = e.get<MoveByIntent>();
      if (pos == null || intent == null) continue;

      final from = LocalPosition(x: pos.x, y: pos.y);
      final to = LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy);
      //e.set(to);

      e.upsert<LocalPosition>(LocalPosition(x: pos.x + intent.dx, y: pos.y + intent.dy));

      e.upsert(DidMove(from: from, to: to));
      e.remove<MoveByIntent>();
    }
  }
}

class InventorySystem extends System {
  final Query canPickup = Query().require<Inventory>().require<LocalPosition>();

  final Query canBePickedUp =
      Query().require<Pickupable>().require<LocalPosition>();

  @override
  int get priority => 1;

  @override
  void update(Chunk world) {
    final pickupIntents = world.components<PickupIntent>();
    if (pickupIntents.components.isEmpty) {
      return;
    }

    // need to use a copy so we can modify elements within our loop...
    var components = Map.from(pickupIntents.components);

    components.forEach((sourceId, intent) {
      var pickupIntent = intent as PickupIntent;
      var source = world.entity(sourceId);
      var target = world.entity(pickupIntent.targetEntityId);

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
        source.set<InventoryFullFailure>(InventoryFullFailure(target.id));
        return;
      }

      target
          .remove<Pickupable>(); // Cannot be picked up again once in inventory.
      target.remove<Renderable>();
      target.remove<LocalPosition>();

      source.set<Inventory>(Inventory([...source.get<Inventory>()!.items, pickupIntent.targetEntityId])); // Update inventory to include latest object
      source.set<PickedUp>(PickedUp(
          pickupIntent.targetEntityId)); // Allow for notifying of new item
    });
  }

  @override
  void update2(EcsWorld world, Cell cell) {
    final pickupIntents = cell.get<PickupIntent>();
    if (pickupIntents.isEmpty) {
      return;
    }

    // need to use a copy so we can modify elements within our loop...
    var components = Map.from(pickupIntents);

    components.forEach((sourceId, intent) {
      var pickupIntent = intent as PickupIntent;
      var source = cell.getEntity(sourceId);
      var target = cell.getEntity(pickupIntent.targetEntityId);

      if (!canPickup.isMatchEntity2(source) ||
          !canBePickedUp.isMatchEntity2(target)) {
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
        source.upsert<InventoryFullFailure>(InventoryFullFailure(target.entityId));
        return;
      }

      target
          .remove<Pickupable>(); // Cannot be picked up again once in inventory.
      target.remove<Renderable>();
      target.remove<LocalPosition>();

      source.upsert<Inventory>(Inventory([...source.get<Inventory>()!.items, pickupIntent.targetEntityId])); // Update inventory to include latest object
      source.upsert<PickedUp>(PickedUp(
          pickupIntent.targetEntityId)); // Allow for notifying of new item
    });
  }
}


class CombatSystem extends System {
  @override
  int get priority => CollisionSystem().priority + 2; // TODO: Go after movement I guess?

  @override
  void update(Chunk world) {
    final attackIntents = world.components<AttackIntent>();

    var components = Map.from(attackIntents.components);
    components.forEach((sourceId, intent) {
      var attackIntent = intent as AttackIntent;
      var source = world.entity(sourceId);
      var target = world.entity(attackIntent.targetId);

      target.update<Health>((health) {
        // TODO change how damage is calculated
        health.current -= 1;
        if (health.current <= 0) {
          health.current = 0;

          // TODO: this doesnt actually prevent other systems from processing
          // this now-dead entity.
          target.set(Dead());
        }

        // TODO this assumes the Attacked compont already exists. That may not be the case.
        target.update<Attacked>((attacked) {
          attacked.add(WasAttacked(sourceId: sourceId, damage: 1));
        });
      });

      source.remove<AttackIntent>();
      source.set<DidAttack>(DidAttack(targetId: target.id, damage: 1));
    });
  }

  @override
  void update2(EcsWorld world, Cell cell) {
    final attackIntents = cell.get<AttackIntent>();

    var components = Map.from(attackIntents);
    components.forEach((sourceId, intent) {
      var attackIntent = intent as AttackIntent;
      var source = cell.getEntity(sourceId);
      var target = cell.getEntity(attackIntent.targetId);

      var health = target.get<Health>(Health(0, 0))!;
      // TODO change how damage is calculated
      health.current -= 1;
      if (health.current <= 0) {
        health.current = 0;

        // TODO: this doesnt actually prevent other systems from processing
        // this now-dead entity.
        target.upsert(Dead());
      }
      target.upsert(WasAttacked(sourceId: sourceId, damage: 1));
      EventBus().publish(Event<Health>(eventType: EventType.updated, id: target.entityId, value: health));


      source.remove<AttackIntent>();
      source.upsert<DidAttack>(DidAttack(targetId: target.entityId, damage: 1));
    });
  }
}


/// A high-level coordinator that advances ECS game logic by executing systems.
class GameEngine {
  final List<Chunk> chunks;
  final List<System> systems;

  GameEngine(this.chunks, this.systems);

  /// Executes a single ECS update tick.
  void tick() {
    var sortedSystems = systems
      ..sort((a, b) => a.priority.compareTo(b
          .priority)); // TODO: move this elsewhere? Just sort once? Or when new systems are added?

    for (var chunk in chunks) {
      chunk.tick(sortedSystems);
    }
  }
}


class PreTick {
  final int tickId;

  PreTick(this.tickId);
}
class PostTick{
  final int tickId;

  PostTick(this.tickId);

}

class EcsWorld {
  int tickId = 0;
  final List<Cell> cells;
  final List<System> systems;

  EcsWorld(this.systems, this.cells);

  /// Executes a single ECS update tick.
  void tick() {
    EventBus().publish(Event<PreTick>(eventType: EventType.updated, value: PreTick(tickId), id: tickId));
    clearLifetimeComponents<BeforeTick>();

    var sortedSystems = systems
      ..sort((a, b) => a.priority.compareTo(b
          .priority)); // TODO: move this elsewhere? Just sort once? Or when new systems are added?

    for(var s in sortedSystems) {
      for(var c in cells) {
        s.update2(this, c);
      }
    }

    clearLifetimeComponents<AfterTick>();
    EventBus().publish(Event<PostTick>(eventType: EventType.updated, value: PostTick(tickId), id: tickId));

    tickId++; // TODO: wrap around to avoid out of bounds type error?
  }

  void clearLifetimeComponents<T extends Lifetime>() {
    for(var cell in cells) {
      for (var componentMap in cell.components.values) {
        var entries = Map.of(componentMap).entries; // Create copy since we'll be modifying the actual map.

        for (var entityToComponent in entries) {
          if (entityToComponent.value is BeforeTick && entityToComponent.value.tick()) { // if is BeforeTick and is dead, remove.
            componentMap.remove(entityToComponent.key);
          }
        }
      }
    }
  }
}