import 'package:dart_mappable/dart_mappable.dart';

part 'components.mapper.dart';

@MappableClass(discriminatorKey: "__type")
abstract class Comp with CompMappable {
  Type get componentType;
}

/// Base class for components with a limited lifespan that can expire
/// after a certain number of ticks. When lifetime reaches 0, the component
/// is removed when processed.
@MappableClass()
class Lifetime with LifetimeMappable implements Comp {
  /// Remaining lifetime of the current component.
  int lifetime;

  Lifetime(this.lifetime);


  /// Check if the lifetime of the current component has expired.
  /// Otherwise, decrement it by one.
  bool tick() {
    if (lifetime <= 0) return true;
    lifetime--;
    return false;
  }

  @override
  Type get componentType => Lifetime;
}

/// Component that is removed before a tick update if its [lifetime]
/// has expired.
///
/// Used for temporary effects that should be cleared at start of tick.
@MappableClass()
class BeforeTick extends Lifetime with BeforeTickMappable implements Comp{
  BeforeTick([super.lifetime = 0]);

  @override
  Type get componentType => BeforeTick;
}

/// Component that is removed after a tick update if its [lifetime]
/// has expired.
///
/// Used for temporary effects that should be cleared at end of tick.
@MappableClass()
class AfterTick extends Lifetime with AfterTickMappable implements Comp {
  AfterTick([super.lifetime = 0]);

  @override
  Type get componentType => AfterTick;
}


@MappableClass()
class Cell with CellMappable implements Comp  {
  List<int> entityIds = [];

  @override
  Type get componentType => Cell;
}

/// A user-friendly, non-unique label for an entity.
///
/// Useful for debugging, UI display, or tagging entities.
@MappableClass()
class Name with NameMappable implements Comp {
  final String name;

  Name({required this.name});

  @override
  Type get componentType => Name;
}

/// The grid-based position of an entity within the game world.
///
/// Currently represents a global position until region support is added.
@MappableClass()
class LocalPosition with LocalPositionMappable implements Comp {
  int x, y;

  LocalPosition({required this.x, required this.y});

  @override
  Type get componentType => LocalPosition;
}

extension LocalPositionExtension on LocalPosition {
  // TODO: with the dart_mapper, might be able to use `==` comparison.
  bool sameLocation(LocalPosition other) {
    return x == other.x && y == other.y;
  }
}

/// Component that signals an intent to move the entity by a relative offset.
@MappableClass()
class MoveByIntent extends AfterTick with MoveByIntentMappable implements Comp{
  final int dx, dy;

  MoveByIntent({required this.dx, required this.dy});

  @override
  Type get componentType => MoveByIntent;
}

/// Component added when an entity has successfully moved in a tick.
///
/// Stores the previous and new positions for downstream logic.
@MappableClass()
class DidMove extends BeforeTick with DidMoveMappable implements Comp {
  final LocalPosition from, to;

  DidMove({required this.from, required this.to}) : super(1);

  @override
  Type get componentType => LocalPosition;
}

/// Marker component indicating this entity blocks movement.
@MappableClass()
class BlocksMovement with BlocksMovementMappable implements Comp {
  @override
  Type get componentType => BlocksMovement;
}

/// Component added when an entity's movement was blocked by another entity.
@MappableClass()
class BlockedMove extends BeforeTick with BlockedMoveMappable implements Comp {
  final LocalPosition attempted;

  BlockedMove(this.attempted);

  @override
  Type get componentType => LocalPosition;
}

/// Marker component indicating the entity is controlled by the player.
@MappableClass()
class PlayerControlled with PlayerControlledMappable implements Comp {
  @override
  Type get componentType => PlayerControlled;
}

@MappableClass()
class AiControlled with AiControlledMappable implements Comp {
  @override
  Type get componentType => AiControlled;
}

/// Component that provides a visual asset path for rendering the entity.
@MappableClass()
class Renderable with RenderableMappable implements Comp {
  final String svgAssetPath;

  Renderable(this.svgAssetPath);

  @override
  Type get componentType => Renderable;
}

@MappableClass()
class Health with HealthMappable implements Comp {
  int current;
  int max;

  Health(this.current, this.max) {
    if (current > max) {
      // TODO just clamp to max?
      throw Exception("[current] health cannot exceed [max] health");
    }
    // TODO check for under zero?
  }

  @override
  Type get componentType => Health;
}

extension HealthExtension on Health {
  Health cloneRelative(int change) {
    var next = current + change;
    if (next > max) {
      next = max;
    }
    if (next < 0) {
      next = 0;
    }

    return Health(next, max);
  }
}

@MappableClass()
class AttackIntent with AttackIntentMappable implements Comp {
  final int targetId;

  AttackIntent(this.targetId);

  @override
  Type get componentType => AttackIntent;
}

@MappableClass()
class DidAttack extends BeforeTick with DidAttackMappable implements Comp{
  final int targetId;
  final int damage;

  DidAttack({required this.targetId, required this.damage});

  @override
  Type get componentType => DidAttack;
}


@MappableClass()
class WasAttacked extends BeforeTick with WasAttackedMappable implements Comp {
  final int sourceId;
  final int damage;

  WasAttacked({required this.sourceId, required this.damage});

  @override
  Type get componentType => WasAttacked;
}

// // TODO change this back to a class?
// typedef Attacked = List<WasAttacked>;

@MappableClass()
class Dead with DeadMappable implements Comp {
  @override
  Type get componentType => Dead;
}

@MappableClass()
class Inventory with InventoryMappable implements Comp {
  final List<int> items;

  Inventory(this.items);

  @override
  Type get componentType => Inventory;
}

@MappableClass()
class InventoryMaxCount with InventoryMaxCountMappable implements Comp {
  final int maxAmount;

  InventoryMaxCount(this.maxAmount);

  @override
  Type get componentType => InventoryMaxCount;
}


@MappableClass()
class Loot with LootMappable implements Comp {
  final List<Comp> components;
  final double probability; // 0.0 - 1.0
  final int quantity;

  Loot({
    required this.components,
    this.probability = 1.0,
    this.quantity = 1,
  });

  @override
  Type get componentType => Loot;
}

@MappableClass()
class LootTable with LootTableMappable implements Comp {
  final List<Loot> lootables;

  LootTable(this.lootables);

  @override
  Type get componentType => LootTable;
}

@MappableClass()
class InventoryFullFailure extends BeforeTick with InventoryFullFailureMappable implements Comp {
  final int targetEntityId;

  InventoryFullFailure(this.targetEntityId);

  @override
  Type get componentType => InventoryFullFailure;
}

@MappableClass()
class Pickupable with PickupableMappable implements Comp {
  @override
  Type get componentType => Pickupable;
}

@MappableClass()
class PickupIntent extends AfterTick with PickupIntentMappable implements Comp{
  final int targetEntityId;

  PickupIntent(this.targetEntityId);

  @override
  Type get componentType => PickupIntent;
}

@MappableClass()
class PickedUp extends BeforeTick with PickedUpMappable implements Comp{
  final int targetEntityId;

  PickedUp(this.targetEntityId);

  @override
  Type get componentType => PickedUp;
}