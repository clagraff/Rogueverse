import 'package:dart_mappable/dart_mappable.dart';

part 'components.mapper.dart'; // This file will be generated

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

/// A user-friendly, non-unique label for an entity.
///
/// Useful for debugging, UI display, or tagging entities.
@MappableClass()
class Name with NameMappable {
  final String name;

  Name({required this.name});
}

/// The grid-based position of an entity within the game world.
///
/// Currently represents a global position until region support is added.
@MappableClass()
class LocalPosition with LocalPositionMappable {
  int x, y;

  LocalPosition({required this.x, required this.y});
}

extension LocalPositionExtension on LocalPosition {
  bool sameLocation(LocalPosition other) {
    return x == other.x && y == other.y;
  }
}

/// Component that signals an intent to move the entity by a relative offset.
@MappableClass()
class MoveByIntent extends AfterTick with MoveByIntentMappable {
  final int dx, dy;

  MoveByIntent({required this.dx, required this.dy});
}

/// Component added when an entity has successfully moved in a tick.
///
/// Stores the previous and new positions for downstream logic.
@MappableClass()
class DidMove extends BeforeTick with DidMoveMappable {
  final LocalPosition from, to;

  DidMove({required this.from, required this.to}) : super(1);
}

/// Marker component indicating this entity blocks movement.
@MappableClass()
class BlocksMovement with BlocksMovementMappable {}

/// Component added when an entity's movement was blocked by another entity.
@MappableClass()
class BlockedMove extends BeforeTick with BlockedMoveMappable {
  final LocalPosition attempted;

  BlockedMove(this.attempted);
}

/// Marker component indicating the entity is controlled by the player.
@MappableClass()
class PlayerControlled with PlayerControlledMappable {}

@MappableClass()
class AiControlled with AiControlledMappable {}

/// Component that provides a visual asset path for rendering the entity.
@MappableClass()
class Renderable with RenderableMappable {
  final String svgAssetPath;

  Renderable(this.svgAssetPath);
}

@MappableClass()
class Health with HealthMappable {
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

@MappableClass()
class AttackIntent with AttackIntentMappable {
  final int targetId;

  AttackIntent(this.targetId);
}

@MappableClass()
class DidAttack extends BeforeTick with DidAttackMappable{
  final int targetId;
  final int damage;

  DidAttack({required this.targetId, required this.damage});
}


@MappableClass()
class WasAttacked extends BeforeTick with WasAttackedMappable {
  final int sourceId;
  final int damage;

  WasAttacked({required this.sourceId, required this.damage});
}

typedef Attacked = List<WasAttacked>;

@MappableClass()
class Dead with DeadMappable {}


// TODO: can we change this to a typedef of Inventory = List<entityId> ??
typedef Inventory = List<int>;

@MappableClass()
class InventoryMaxCount with InventoryMaxCountMappable {
  final int maxAmount;

  InventoryMaxCount(this.maxAmount);
}

@MappableClass()
class InventoryFullFailure extends BeforeTick with InventoryFullFailureMappable {
  final int targetEntityId;

  InventoryFullFailure(this.targetEntityId);
}

@MappableClass()
class Pickupable with PickupableMappable {}

@MappableClass()
class PickupIntent extends AfterTick with PickupIntentMappable{
  final int targetEntityId;

  PickupIntent(this.targetEntityId);
}

@MappableClass()
class PickedUp extends BeforeTick with PickedUpMappable {
  final int targetEntityId;

  PickedUp(this.targetEntityId);
}