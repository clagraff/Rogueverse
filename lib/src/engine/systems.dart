import 'components.dart';
import 'events.dart';
import 'registry.dart';
import 'query.dart';

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
  // TODO: Change to just using the order of systems as provided to a world instance?
  int get priority => System.defaultPriority;

  void update(Registry world);
}

/// A system that handles collision detection by checking for blocked movement.
///
/// If an entity attempts to move into an occupied tile, its move is cancelled.
class CollisionSystem extends System {
  @override
  int get priority => 1;

  @override
  void update(Registry world) {
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

      positions.forEach((key, value) {
        if (value.x == dest.x &&
            value.y == dest.y &&
            world.getEntity(key).has<BlocksMovement>()) {
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
  void update(Registry world) {
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
  void update(Registry world) {
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
    });
  }
}

class CombatSystem extends System {
  @override
  int get priority =>
      CollisionSystem().priority + 2; // TODO: Go after movement I guess?

  @override
  void update(Registry world) {
    final attackIntents = world.get<AttackIntent>();

    var components = Map.from(attackIntents);
    components.forEach((sourceId, intent) {
      var attackIntent = intent as AttackIntent;
      var source = world.getEntity(sourceId);
      var target = world.getEntity(attackIntent.targetId);

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
      EventBus().publish(Event<Health>(
          eventType: EventType.updated, id: target.id, value: health));

      source.remove<AttackIntent>();
      source.upsert<DidAttack>(DidAttack(targetId: target.id, damage: 1));
    });
  }
}
