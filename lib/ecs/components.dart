import 'package:dart_mappable/dart_mappable.dart';
import 'package:rogueverse/ecs/ai/nodes.dart';

part 'components.mapper.dart';

@MappableClass()
abstract class Component with ComponentMappable {
  String get componentType;
}

/// Enum representing the 8 compass directions.
@MappableEnum()
enum CompassDirection {
  north,      // (0, -1)
  south,      // (0, 1)
  east,       // (1, 0)
  west,       // (-1, 0)
  northeast,  // (1, -1)
  northwest,  // (-1, -1)
  southeast,  // (1, 1)
  southwest   // (-1, 1)
}

/// Component that tracks which direction an entity is facing.
///
/// Updated whenever an entity attempts to move (even if blocked).
@MappableClass()
class Direction with DirectionMappable implements Component {
  final CompassDirection facing;

  Direction(this.facing);

  @override
  String get componentType => "Direction";

  /// Calculate direction from a movement offset (dx, dy).
  static CompassDirection fromOffset(int dx, int dy) {
    if (dx == 0 && dy < 0) return CompassDirection.north;
    if (dx == 0 && dy > 0) return CompassDirection.south;
    if (dx > 0 && dy == 0) return CompassDirection.east;
    if (dx < 0 && dy == 0) return CompassDirection.west;
    if (dx > 0 && dy < 0) return CompassDirection.northeast;
    if (dx < 0 && dy < 0) return CompassDirection.northwest;
    if (dx > 0 && dy > 0) return CompassDirection.southeast;
    if (dx < 0 && dy > 0) return CompassDirection.southwest;
    return CompassDirection.south; // Default fallback
  }
}

/// Base class for components with a limited lifespan that can expire
/// after a certain number of ticks. When lifetime reaches 0, the component
/// is removed when processed.
@MappableClass()
class Lifetime with LifetimeMappable implements Component {
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
  String get componentType => "Lifetime";
}

/// Component that is removed before a tick update if its [lifetime]
/// has expired.
///
/// Used for temporary effects that should be cleared at start of tick.
@MappableClass()
class BeforeTick extends Lifetime with BeforeTickMappable implements Component{
  BeforeTick([super.lifetime = 0]);

  @override
  String get componentType => "BeforeTick";
}

/// Component that is removed after a tick update if its [lifetime]
/// has expired.
///
/// Used for temporary effects that should be cleared at end of tick.
@MappableClass()
class AfterTick extends Lifetime with AfterTickMappable implements Component {
  AfterTick([super.lifetime = 0]);

  @override
  String get componentType => "AfterTick";
}


@MappableClass()
class Cell with CellMappable implements Component  {
  List<int> entityIds = [];

  @override
  String get componentType => "Cell";
}

/// A user-friendly, non-unique label for an entity.
///
/// Useful for debugging, UI display, or tagging entities.
@MappableClass()
class Name with NameMappable implements Component {
  final String name;

  Name({required this.name});

  @override
  String get componentType => "Name";
}

/// The grid-based position of an entity within the game world.
///
/// Currently represents a global position until region support is added.
@MappableClass()
class LocalPosition with LocalPositionMappable implements Component {
  int x, y;

  LocalPosition({required this.x, required this.y});

  @override
  String get componentType => "LocalPosition";
}

extension LocalPositionExtension on LocalPosition {
  // TODO: with the dart_mapper, might be able to use `==` comparison.
  bool sameLocation(LocalPosition other) {
    return x == other.x && y == other.y;
  }
}

// TODO have a MoveToIntent that extends LocalPosition maybe?
// TODO and have MoveBy do the same, with the source and target and deltas?
/// Component that signals an intent to move the entity by a relative offset.
@MappableClass()
class MoveByIntent extends AfterTick with MoveByIntentMappable implements Component{
  final int dx, dy;

  MoveByIntent({required this.dx, required this.dy});

  @override
  String get componentType => "MoveByIntent";
}

/// Component added when an entity has successfully moved in a tick.
///
/// Stores the previous and new positions for downstream logic.
@MappableClass()
class DidMove extends BeforeTick with DidMoveMappable implements Component {
  final LocalPosition from, to;

  DidMove({required this.from, required this.to}) : super(1);

  @override
  String get componentType => "DidMove";
}

/// Marker component indicating this entity blocks movement.
@MappableClass()
class BlocksMovement with BlocksMovementMappable implements Component {
  @override
  String get componentType => "BlocksMovement";
}

/// Component added when an entity's movement was blocked by another entity.
@MappableClass()
class BlockedMove extends BeforeTick with BlockedMoveMappable implements Component {
  final LocalPosition attempted;

  BlockedMove(this.attempted);

  @override
  String get componentType => "BlockedMove";
}

/// Marker component indicating the entity is controlled by the player.
@MappableClass()
class PlayerControlled with PlayerControlledMappable implements Component {
  @override
  String get componentType => "PlayerControlled";
}

@MappableClass()
class AiControlled with AiControlledMappable implements Component {
  @override
  String get componentType => "AiControlled";
}

@MappableClass()
class Behavior with BehaviorMappable implements Component {
  final Node behavior;

  Behavior(this.behavior);

  @override
  String get componentType => "Behavior";
}


/// Component that provides a visual asset path for rendering the entity.
@MappableClass()
class Renderable with RenderableMappable implements Component {
  final String svgAssetPath;

  Renderable(this.svgAssetPath);

  @override
  String get componentType => "Renderable";
}

@MappableClass()
class Health with HealthMappable implements Component {
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
  String get componentType => "Health";

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
class AttackIntent with AttackIntentMappable implements Component {
  final int targetId;

  AttackIntent(this.targetId);

  @override
  String get componentType => "AttackIntent";
}

@MappableClass()
class DidAttack extends BeforeTick with DidAttackMappable implements Component{
  final int targetId;
  final int damage;

  DidAttack({required this.targetId, required this.damage});

  @override
  String get componentType => "DidAttack";
}


@MappableClass()
class WasAttacked extends BeforeTick with WasAttackedMappable implements Component {
  final int sourceId;
  final int damage;

  WasAttacked({required this.sourceId, required this.damage});

  @override
  String get componentType => "WasAttacked";
}

// // TODO change this back to a class?
// typedef Attacked = List<WasAttacked>;

@MappableClass()
class Dead with DeadMappable implements Component {
  @override
  String get componentType => "Dead";
}

@MappableClass()
class Inventory with InventoryMappable implements Component {
  final List<int> items;

  Inventory(this.items);

  @override
  String get componentType => "Inventory";
}

@MappableClass()
class InventoryMaxCount with InventoryMaxCountMappable implements Component {
  final int maxAmount;

  InventoryMaxCount(this.maxAmount);

  @override
  String get componentType => "InventoryMaxCount";
}


@MappableClass()
class Loot with LootMappable implements Component {
  final List<Component> components;
  final double probability; // 0.0 - 1.0
  final int quantity;

  Loot({
    required this.components,
    this.probability = 1.0,
    this.quantity = 1,
  });

  @override
  String get componentType => "Loot";
}

@MappableClass()
class LootTable with LootTableMappable implements Component {
  final List<Loot> lootables;

  LootTable(this.lootables);

  @override
  String get componentType => "LootTable";
}

@MappableClass()
class InventoryFullFailure extends BeforeTick with InventoryFullFailureMappable implements Component {
  final int targetEntityId;

  InventoryFullFailure(this.targetEntityId);

  @override
  String get componentType => "InventoryFullFailure";
}

@MappableClass()
class Pickupable with PickupableMappable implements Component {
  @override
  String get componentType => "Pickupable";
}

@MappableClass()
class PickupIntent extends AfterTick with PickupIntentMappable implements Component{
  final int targetEntityId;

  PickupIntent(this.targetEntityId);

  @override
  String get componentType => "PickupIntent";
}

@MappableClass()
class PickedUp extends BeforeTick with PickedUpMappable implements Component{
  final int targetEntityId;

  PickedUp(this.targetEntityId);

  @override
  String get componentType => "PickedUp";
}

// ============================================================================
// Vision System Components
// ============================================================================

/// Marker component indicating this entity blocks line-of-sight.
/// Entities with this component will prevent vision from passing through their tile.
@MappableClass()
class BlocksSight with BlocksSightMappable implements Component {
  @override
  String get componentType => "BlocksSight";
}

/// Defines an entity's vision capabilities.
/// Entities with this component will have vision calculated by VisionSystem.
@MappableClass()
class VisionRadius with VisionRadiusMappable implements Component {
  final int radius;              // Vision range in grid tiles
  final int fieldOfViewDegrees;  // FOV angle (360 = omnidirectional, 90 = narrow cone)

  VisionRadius({
    required this.radius,
    this.fieldOfViewDegrees = 360,
  });

  @override
  String get componentType => "VisionRadius";
}

/// Stores what this entity can currently see.
/// Updated by VisionSystem each tick.
@MappableClass()
class VisibleEntities with VisibleEntitiesMappable implements Component {
  final Set<int> entityIds;           // IDs of entities currently visible
  final Set<LocalPosition> visibleTiles;  // Grid positions in FOV

  VisibleEntities({
    Set<int>? entityIds,
    Set<LocalPosition>? visibleTiles,
  }) : entityIds = entityIds ?? {},
       visibleTiles = visibleTiles ?? {};

  @override
  String get componentType => "VisibleEntities";
}

/// Tracks entities that were previously seen by this observer.
/// Memory persists permanently (no decay).
@MappableClass()
class VisionMemory with VisionMemoryMappable implements Component {
  @MappableField(key: 'lastSeenPositions')
  final Map<String, LocalPosition> lastSeenPositions;  // entityId (as string) -> last position

  VisionMemory({Map<String, LocalPosition>? lastSeenPositions})
      : lastSeenPositions = lastSeenPositions ?? {};

  @override
  String get componentType => "VisionMemory";
  
  // Helper methods to work with int keys
  LocalPosition? getLastSeenPosition(int entityId) {
    return lastSeenPositions[entityId.toString()];
  }
  
  void setLastSeenPosition(int entityId, LocalPosition position) {
    lastSeenPositions[entityId.toString()] = position;
  }
  
  bool hasSeenEntity(int entityId) {
    return lastSeenPositions.containsKey(entityId.toString());
  }
}

// VisibilityState and VisibilityLevel removed - now using VisionCamera for visibility management