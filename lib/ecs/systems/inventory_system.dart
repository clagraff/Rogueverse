import 'dart:developer';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/ecs/systems/behavior_system.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'inventory_system.mapper.dart';

@MappableClass()
class InventorySystem extends System with InventorySystemMappable {
  @override
  Set<Type> get runAfter => {BehaviorSystem};
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

        // Check if adjacent or same tile (range 1)
        final sourcePos = source.get<LocalPosition>()!;
        final targetPos = target.get<LocalPosition>()!;
        final dx = (sourcePos.x - targetPos.x).abs();
        final dy = (sourcePos.y - targetPos.y).abs();
        if (dx > 1 || dy > 1) {
          return; // Skip - too far away
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

        _logger.finest("picked up item", {"entity": source, "item": target, "pos": sourcePos});
      });
    });
  }
}
