/// Base class for components with a limited lifespan that can expire
/// after a certain number of ticks. When lifetime reaches 0, the component
/// is removed when processed.
abstract class Lifetime {
  int _lifetime;

  Lifetime(this._lifetime);

  /// Remaining lifetime of the current component.
  int get lifetime => _lifetime;

  /// Check if the lifetime of the current component has expired.
  /// Otherwise, decrement it by one.
  bool tick() {
    if (_lifetime <= 0) return true;
    _lifetime--;
    return false;
  }
}

/// Component that is removed before a tick update if its [lifetime]
/// has expired.
///
/// Used for temporary effects that should be cleared at start of tick.
abstract class BeforeTick extends Lifetime {
  BeforeTick([super.lifetime = 0]);
}

/// Component that is removed after a tick update if its [lifetime]
/// has expired.
///
/// Used for temporary effects that should be cleared at end of tick.
abstract class AfterTick extends Lifetime {
  AfterTick([super.lifetime = 0]);
}


class Cell {
  List<int> entityIds = [];
}

/// A user-friendly, non-unique label for an entity.
///
/// Useful for debugging, UI display, or tagging entities.
class Name {
  final String name;

  Name({required this.name});
}

/// The grid-based position of an entity within the game world.
///
/// Currently represents a global position until region support is added.
class LocalPosition {
  int x, y;

  LocalPosition({required this.x, required this.y});
}

extension LocalPositionExtension on LocalPosition {
  // TODO: with the dart_mapper, might be able to use `==` comparison.
  bool sameLocation(LocalPosition other) {
    return x == other.x && y == other.y;
  }
}

/// Component that signals an intent to move the entity by a relative offset.
class MoveByIntent extends AfterTick {
  final int dx, dy;

  MoveByIntent({required this.dx, required this.dy});
}

/// Component added when an entity has successfully moved in a tick.
///
/// Stores the previous and new positions for downstream logic.
class DidMove extends BeforeTick {
  final LocalPosition from, to;

  DidMove({required this.from, required this.to}) : super(1);
}

/// Marker component indicating this entity blocks movement.
class BlocksMovement {}

/// Component added when an entity's movement was blocked by another entity.
class BlockedMove extends BeforeTick {
  final LocalPosition attempted;

  BlockedMove(this.attempted);
}

/// Marker component indicating the entity is controlled by the player.
class PlayerControlled {}

class AiControlled {}

/// Component that provides a visual asset path for rendering the entity.
class Renderable {
  final String svgAssetPath;

  Renderable(this.svgAssetPath);
}

class Health {
  int current;
  int max;

  Health(this.current, this.max) {
    if (current > max) {
      // TODO just clamp to max?
      throw Exception("[current] health cannot exceed [max] health");
    }
    // TODO check for under zero?
  }
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

class AttackIntent {
  final int targetId;

  AttackIntent(this.targetId);
}

class DidAttack extends BeforeTick {
  final int targetId;
  final int damage;

  DidAttack({required this.targetId, required this.damage});
}


class WasAttacked extends BeforeTick {
  final int sourceId;
  final int damage;

  WasAttacked({required this.sourceId, required this.damage});
}

// TODO change this back to a class?
typedef Attacked = List<WasAttacked>;

class Dead {}


class Inventory {
  final List<int> items;

  Inventory(this.items);
}

class InventoryMaxCount {
  final int maxAmount;

  InventoryMaxCount(this.maxAmount);
}


class Loot {
  final List<dynamic> components;
  final double probability; // 0.0 - 1.0
  final int quantity;

  Loot({
    required this.components,
    this.probability = 1.0,
    this.quantity = 1,
  });
}

class LootTable {
  final List<Loot> lootables;

  LootTable(this.lootables);
}

class InventoryFullFailure extends BeforeTick {
  final int targetEntityId;

  InventoryFullFailure(this.targetEntityId);
}

class Pickupable {}

class PickupIntent extends AfterTick{
  final int targetEntityId;

  PickupIntent(this.targetEntityId);
}

class PickedUp extends BeforeTick {
  final int targetEntityId;

  PickedUp(this.targetEntityId);
}

// class ComponentRegistry {
//   static final Map<String, dynamic Function(String)> _mappers = {};
//
//   static void initialize() {
//     _mappers['LocalPosition'] = LocalPositionMapper.fromJson;
//     _mappers['Health'] = HealthMapper.fromJson;
//     _mappers['Name'] = NameMapper.fromJson;
//     _mappers['Inventory'] = (String array) => []; // TODO fix this
//     _mappers['PlayerControlled'] = PlayerControlledMapper.fromJson;
//     _mappers['BlocksMovement'] = BlocksMovementMapper.fromJson;
//     // Register all component mappers
//   }
//
//   static dynamic fromJson(String typeName, dynamic json) {
//     final mapper = _mappers[typeName];
//     if (mapper == null) {
//       throw Exception('No mapper registered for component type: $typeName');
//     }
//     return mapper(json);
//   }
// }