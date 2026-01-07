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
  north, // (0, -1)
  south, // (0, 1)
  east, // (1, 0)
  west, // (-1, 0)
  northeast, // (1, -1)
  northwest, // (-1, -1)
  southeast, // (1, 1)
  southwest // (-1, 1)
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
class BeforeTick extends Lifetime with BeforeTickMappable implements Component {
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
class Cell with CellMappable implements Component {
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
class MoveByIntent extends AfterTick
    with MoveByIntentMappable
    implements Component {
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
class BlockedMove extends BeforeTick
    with BlockedMoveMappable
    implements Component {
  final LocalPosition attempted;

  BlockedMove(this.attempted);

  @override
  String get componentType => "BlockedMove";
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
class DidAttack extends BeforeTick with DidAttackMappable implements Component {
  final int targetId;
  final int damage;

  DidAttack({required this.targetId, required this.damage});

  @override
  String get componentType => "DidAttack";
}

@MappableClass()
class WasAttacked extends BeforeTick
    with WasAttackedMappable
    implements Component {
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
class InventoryFullFailure extends BeforeTick
    with InventoryFullFailureMappable
    implements Component {
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
class PickupIntent extends AfterTick
    with PickupIntentMappable
    implements Component {
  final int targetEntityId;

  PickupIntent(this.targetEntityId);

  @override
  String get componentType => "PickupIntent";
}

@MappableClass()
class PickedUp extends BeforeTick with PickedUpMappable implements Component {
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
  final int radius; // Vision range in grid tiles
  final int
      fieldOfViewDegrees; // FOV angle (360 = omnidirectional, 90 = narrow cone)

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
  final Set<int> entityIds; // IDs of entities currently visible
  final Set<LocalPosition> visibleTiles; // Grid positions in FOV

  VisibleEntities({
    Set<int>? entityIds,
    Set<LocalPosition>? visibleTiles,
  })  : entityIds = entityIds ?? {},
        visibleTiles = visibleTiles ?? {};

  @override
  String get componentType => "VisibleEntities";

  @override
  String toString() {
    return "VisibleEntities(entityIds: [... ${entityIds.length} count, visibleTiles: [... ${visibleTiles.length} count])";
  }
}

/// Tracks entities that were previously seen by this observer.
/// Memory persists permanently (no decay).
@MappableClass()
class VisionMemory with VisionMemoryMappable implements Component {
  @MappableField(key: 'lastSeenPositions')
  final Map<String, LocalPosition>
      lastSeenPositions; // entityId (as string) -> last position

  VisionMemory({Map<String, LocalPosition>? lastSeenPositions})
      : lastSeenPositions = lastSeenPositions ?? {};

  @override
  String get componentType => "VisionMemory";


  @override
  String toString() {
    return "VisionMemory(lastSeenPositions: {... ${lastSeenPositions.length} entries})";
  }

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

// ============================================================================
// Hierarchy System Components
// ============================================================================

/// Component that marks an entity as having a parent in the entity hierarchy.
///
/// Every entity (except root entities like Universe) should have a parent.
/// This creates a natural tree structure for organization and spatial partitioning.
///
/// Examples:
/// - NPC has HasParent(roomId) - NPC is in a room
/// - Room has HasParent(buildingId) - Room is in a building
/// - Building has HasParent(regionId) - Building is in a region
/// - Region has HasParent(planetId) - Region is on a planet
/// - Planet has HasParent(starSystemId) - Planet is in a star system
@MappableClass()
class HasParent with HasParentMappable implements Component {
  final int parentEntityId;

  HasParent(this.parentEntityId);

  @override
  String get componentType => "HasParent";
}

// ============================================================================
// Portal System Components
// ============================================================================

/// Portal that teleports to a specific position within a destination parent.
///
/// Example: An exterior door that teleports to a fixed spawn point inside a building.
@MappableClass()
class PortalToPosition with PortalToPositionMappable implements Component {
  final int destParentId; // Parent entity where traveler will appear
  final LocalPosition destLocation; // Position within that parent
  final int interactionRange; // Distance from portal: <0=any, 0=exact, >0=max tiles

  PortalToPosition({
    required this.destParentId,
    required this.destLocation,
    this.interactionRange = 0,
  });

  @override
  String get componentType => "PortalToPosition";
}

/// Portal that teleports relative to one of multiple possible anchor entities.
///
/// Example: An entrance that can spawn at any of several interior doors,
/// choosing the first unblocked one.
@MappableClass()
class PortalToAnchor with PortalToAnchorMappable implements Component {
  final List<int> destAnchorEntityIds; // List of entities with PortalAnchor
  final int offsetX; // Offset from anchor position
  final int offsetY;
  final int interactionRange; // Distance from portal: <0=any, 0=exact, >0=max tiles

  PortalToAnchor({
    required this.destAnchorEntityIds,
    this.offsetX = 0,
    this.offsetY = 0,
    this.interactionRange = 0,
  });

  @override
  String get componentType => "PortalToAnchor";
}

/// Marker for entities that can serve as portal anchor destinations.
@MappableClass()
class PortalAnchor with PortalAnchorMappable implements Component {
  final String? anchorName; // Optional: for debugging/UI

  PortalAnchor({this.anchorName});

  @override
  String get componentType => "PortalAnchor";
}

/// Intent to use a portal (supports both PortalToPosition and PortalToAnchor).
@MappableClass()
class UsePortalIntent extends AfterTick
    with UsePortalIntentMappable
    implements Component {
  final int portalEntityId;
  final int?
      specificAnchorId; // Optional: for PortalToAnchor, specify which anchor

  UsePortalIntent({
    required this.portalEntityId,
    this.specificAnchorId,
  });

  @override
  String get componentType => "UsePortalIntent";
}

/// Component added when entity successfully portaled.
@MappableClass()
class DidPortal extends BeforeTick with DidPortalMappable implements Component {
  final int portalEntityId;
  final int fromParentId;
  final int toParentId;
  final LocalPosition fromPosition;
  final LocalPosition toPosition;
  final int? usedAnchorId; // Which anchor was used (if PortalToAnchor)

  DidPortal({
    required this.portalEntityId,
    required this.fromParentId,
    required this.toParentId,
    required this.fromPosition,
    required this.toPosition,
    this.usedAnchorId,
  }) : super(1);

  @override
  String get componentType => "DidPortal";
}

/// Component added when portal attempt failed.
@MappableClass()
class FailedToPortal extends BeforeTick
    with FailedToPortalMappable
    implements Component {
  final int portalEntityId;
  final PortalFailureReason reason;

  FailedToPortal({
    required this.portalEntityId,
    required this.reason,
  }) : super(1);

  @override
  String get componentType => "FailedToPortal";
}

/// Reasons why portal usage might fail.
@MappableEnum()
enum PortalFailureReason {
  portalNotFound, // Portal entity doesn't exist
  notSameParent, // Traveler and portal don't share the same parent
  outOfRange, // Not within interactionRange of portal
  destinationBlocked, // Destination position is occupied
  destinationParentNotFound, // Destination parent doesn't exist
  anchorNotFound, // No valid anchor entity found
  noValidAnchors, // All anchors in list are invalid/blocked
  missingComponents, // Entity lacks required components (position, etc)
}

// ============================================================================
// Control System Components
// ============================================================================

@MappableClass()
class Controllable with ControllableMappable implements Component {

  Controllable();

  @override
  String get componentType => "Controllable";
}

/// Component that marks an actor as controlling another entity (e.g., a vehicle).
///
/// When an actor has this component, the UI switches selectedEntity to the
/// controlled entity, causing input to be directed to it instead of the actor.
@MappableClass()
class Controlling with ControllingMappable implements Component {
  final int controlledEntityId;

  Controlling({required this.controlledEntityId});

  @override
  String get componentType => "Controlling";
}

/// Component that marks an entity (e.g., pilot seat) as enabling control of another entity.
///
/// When an actor interacts with an entity that has this component, they gain
/// a Controlling component that references the controlledEntityId.
@MappableClass()
class EnablesControl with EnablesControlMappable implements Component {
  final int controlledEntityId;

  EnablesControl({required this.controlledEntityId});

  @override
  String get componentType => "EnablesControl";
}

/// Marker component indicating an entity is docked/landed.
///
/// When present, prevents the entity from moving or engaging in combat.
/// Does not prevent other actions like using portals or interacting with objects.
@MappableClass()
class Docked with DockedMappable implements Component {
  @override
  String get componentType => "Docked";
}

/// Intent to take control of an entity via an EnablesControl entity.
@MappableClass()
class WantsControlIntent extends AfterTick
    with WantsControlIntentMappable
    implements Component {
  final int targetEntityId; // Entity with EnablesControl component

  WantsControlIntent({required this.targetEntityId});

  @override
  String get componentType => "WantsControlIntent";
}

/// Intent to release control of the currently controlled entity.
///
/// This intent is added to the controlled entity (e.g., vehicle), and the
/// ControlSystem finds the actor with the matching Controlling component.
@MappableClass()
class ReleasesControlIntent extends AfterTick
    with ReleasesControlIntentMappable
    implements Component {
  ReleasesControlIntent();

  @override
  String get componentType => "ReleasesControlIntent";
}

/// Intent to dock/land the entity.
@MappableClass()
class DockIntent extends AfterTick with DockIntentMappable implements Component {
  DockIntent();

  @override
  String get componentType => "DockIntent";
}

/// Intent to undock/takeoff the entity.
@MappableClass()
class UndockIntent extends AfterTick
    with UndockIntentMappable
    implements Component {
  UndockIntent();

  @override
  String get componentType => "UndockIntent";
}
