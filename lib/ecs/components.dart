import 'package:dart_mappable/dart_mappable.dart';
import 'package:rogueverse/ecs/ai/nodes.dart';
import 'package:rogueverse/ecs/dialog/dialog_nodes.dart';

part 'components.mapper.dart';

// ============================================================================
// Component Base Class
// ============================================================================

/// Base class for all ECS components.
///
/// # Component Type Identity
///
/// Components use string-based type identity (`componentType` getter) rather than
/// Dart's `Type` system for two important reasons:
///
/// ## 1. Serialization Compatibility
/// Dart's `Type` instances cannot be serialized to JSON via dart_mappable.
/// Using strings allows components to be persisted and loaded correctly.
///
/// ## 2. Runtime Type Preservation
/// In certain generic contexts, Dart's type erasure can cause a `LocalPosition`
/// to appear as `dynamic` or `Component` at runtime. The string-based approach
/// ensures the actual component type is always accessible regardless of how
/// the component was obtained.
///
/// ## Implementation
/// Each component implements:
/// ```dart
/// @override
/// String get componentType => 'ComponentClassName';
/// ```
///
/// This string is used for:
/// - Component storage keys in World
/// - Serialization type discriminators
/// - Template inheritance lookups
/// - Query matching
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

/// Base class for all player/AI action intents.
///
/// Only one IntentComponent should exist per entity at a time.
/// Use [Entity.setIntent] to set an intent, which clears any existing intents.
/// Cleared automatically at end of tick (extends AfterTick).
@MappableClass()
abstract class IntentComponent extends AfterTick
    with IntentComponentMappable
    implements Component {
  IntentComponent() : super();

  @override
  String get componentType => "IntentComponent";
}

/// No-op intent for "skip turn" / waiting.
///
/// Clears any other intents on the entity without performing an action.
/// Useful for tactically waiting (e.g., for an enemy to approach).
@MappableClass()
class WaitIntent extends IntentComponent with WaitIntentMappable {
  WaitIntent();

  @override
  String get componentType => "WaitIntent";
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
class MoveByIntent extends IntentComponent with MoveByIntentMappable {
  final int dx, dy;

  /// If true, this is a strafe movement that should not change facing direction.
  final bool isStrafe;

  MoveByIntent({required this.dx, required this.dy, this.isStrafe = false});

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

/// Intent to change facing direction. Processed by DirectionSystem.
@MappableClass()
class DirectionIntent extends IntentComponent with DirectionIntentMappable {
  final CompassDirection direction;

  DirectionIntent(this.direction);

  @override
  String get componentType => "DirectionIntent";
}

/// Records a direction change that occurred without movement.
@MappableClass()
class DidChangeDirection extends BeforeTick
    with DidChangeDirectionMappable
    implements Component {
  final CompassDirection from;
  final CompassDirection to;

  DidChangeDirection({required this.from, required this.to}) : super(1);

  @override
  String get componentType => "DidChangeDirection";
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

/// Marker component identifying an entity as the player character.
/// Used to restore player control when exiting editor mode.
@MappableClass()
class Player with PlayerMappable implements Component {
  @override
  String get componentType => "Player";
}

@MappableClass()
class Behavior with BehaviorMappable implements Component {
  final Node behavior;

  Behavior(this.behavior);

  @override
  String get componentType => "Behavior";
}

// ============================================================================
// Renderable Asset Types
// ============================================================================

/// Base class for renderable assets. Either an image or text.
@MappableClass()
sealed class RenderableAsset with RenderableAssetMappable {}

/// Image-based renderable asset with SVG/PNG path and transform options.
@MappableClass()
class ImageAsset extends RenderableAsset with ImageAssetMappable {
  final String svgAssetPath;
  final bool flipHorizontal;
  final bool flipVertical;
  final double rotationDegrees;

  ImageAsset(
    this.svgAssetPath, {
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.rotationDegrees = 0,
  });
}

/// Text-based renderable asset for in-world text display.
@MappableClass()
class TextAsset extends RenderableAsset with TextAssetMappable {
  final String text;
  final double fontSize;
  final int color; // ARGB int for serialization

  TextAsset({
    required this.text,
    this.fontSize = 16,
    this.color = 0xFFFFFFFF, // White default
  });
}

/// Component that provides visual rendering for an entity.
/// Contains either an ImageAsset or TextAsset.
@MappableClass()
class Renderable with RenderableMappable implements Component {
  final RenderableAsset asset;

  Renderable(this.asset);

  @override
  String get componentType => "Renderable";
}

/// Optional component that provides an alternate visual for editor mode.
/// When present and in GameMode.editing, this is displayed instead of Renderable.
/// Useful for distinguishing illusionary walls from real walls, etc.
@MappableClass()
class EditorRenderable with EditorRenderableMappable implements Component {
  final RenderableAsset asset;

  EditorRenderable(this.asset);

  @override
  String get componentType => "EditorRenderable";
}

@MappableClass()
class Health with HealthMappable implements Component {
  int current;
  int max;

  Health(int current, int max) 
    : max = max < 0 ? 0 : max,
      current = current < 0 ? 0 : (current > max ? max : current);

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
class AttackIntent extends IntentComponent with AttackIntentMappable {
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
class PickupIntent extends IntentComponent with PickupIntentMappable {
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
class UsePortalIntent extends IntentComponent with UsePortalIntentMappable {
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
class WantsControlIntent extends IntentComponent with WantsControlIntentMappable {
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
class ReleasesControlIntent extends IntentComponent
    with ReleasesControlIntentMappable {
  ReleasesControlIntent();

  @override
  String get componentType => "ReleasesControlIntent";
}

/// Intent to dock/land the entity.
@MappableClass()
class DockIntent extends IntentComponent with DockIntentMappable {
  DockIntent();

  @override
  String get componentType => "DockIntent";
}

/// Intent to undock/takeoff the entity.
@MappableClass()
class UndockIntent extends IntentComponent with UndockIntentMappable {
  UndockIntent();

  @override
  String get componentType => "UndockIntent";
}

// ============================================================================
// Openable System Components
// ============================================================================

/// Component for entities that can be opened/closed (doors, gates, chests, etc.).
///
/// When closed, the entity can optionally block movement and/or vision.
/// An OpenableSystem handles state changes and synchronizes the Renderable,
/// BlocksMovement, and BlocksSight components based on the current state.
@MappableClass()
class Openable with OpenableMappable implements Component {
  final bool isOpen;
  final String openRenderablePath;
  final String closedRenderablePath;
  final bool blocksMovementWhenClosed;
  final bool blocksVisionWhenClosed;

  Openable({
    this.isOpen = false,
    required this.openRenderablePath,
    required this.closedRenderablePath,
    this.blocksMovementWhenClosed = true,
    this.blocksVisionWhenClosed = true,
  });

  @override
  String get componentType => "Openable";
}

/// Intent to open an openable entity.
@MappableClass()
class OpenIntent extends IntentComponent with OpenIntentMappable {
  final int targetEntityId;

  OpenIntent({required this.targetEntityId});

  @override
  String get componentType => "OpenIntent";
}

/// Intent to close an openable entity.
@MappableClass()
class CloseIntent extends IntentComponent with CloseIntentMappable {
  final int targetEntityId;

  CloseIntent({required this.targetEntityId});

  @override
  String get componentType => "CloseIntent";
}

/// Component added when an entity was successfully opened.
@MappableClass()
class DidOpen extends BeforeTick with DidOpenMappable implements Component {
  final int targetEntityId;

  DidOpen({required this.targetEntityId}) : super(1);

  @override
  String get componentType => "DidOpen";
}

/// Component added when an entity was successfully closed.
@MappableClass()
class DidClose extends BeforeTick with DidCloseMappable implements Component {
  final int targetEntityId;

  DidClose({required this.targetEntityId}) : super(1);

  @override
  String get componentType => "DidClose";
}

// ============================================================================
// Dialog System Components
// ============================================================================

/// Component that stores a dialog tree for an NPC.
///
/// Entities with this component can be talked to by the player.
/// The dialog tree defines the conversation flow, including branching
/// choices, conditions, and effects.
@MappableClass()
class Dialog with DialogMappable implements Component {
  /// The root node of the dialog tree.
  final DialogNode root;

  Dialog(this.root);

  @override
  String get componentType => "Dialog";
}

/// Intent to start a dialog with an NPC.
@MappableClass()
class TalkIntent extends IntentComponent with TalkIntentMappable {
  final int targetEntityId;

  TalkIntent({required this.targetEntityId});

  @override
  String get componentType => "TalkIntent";
}

// ============================================================================
// Template System Components
// ============================================================================

/// Marker component identifying an entity as a template.
///
/// Template entities:
/// - Are not rendered in the game world (no position in normal gameplay)
/// - Appear in the template panel UI instead of the entity list
/// - Can be used by other entities via [FromTemplate] for component inheritance
/// - Can themselves have [FromTemplate] for template inheritance chains
@MappableClass()
class IsTemplate with IsTemplateMappable implements Component {
  /// User-friendly display name shown in the template panel.
  /// Distinct from the [Name] component which is used for in-game display.
  final String displayName;

  IsTemplate({required this.displayName});

  @override
  String get componentType => "IsTemplate";
}

/// Component that links an entity to a template for component inheritance.
///
/// When an entity has this component, calls to `has<C>()` and `get<C>()`
/// will check the template entity if the component is not found locally,
/// unless the component type is in [excludedTypes].
///
/// Templates can themselves have [FromTemplate] (up to 3 levels deep).
@MappableClass()
class FromTemplate with FromTemplateMappable implements Component {
  /// The entity ID of the template this entity inherits from.
  final int templateEntityId;

  /// Set of component type names excluded from template inheritance.
  /// When a type is in this set:
  /// - `has<T>()` returns false (for that type)
  /// - `get<T>()` returns null (for that type)
  /// - The template's component of that type is not inherited
  final Set<String> excludedTypes;

  FromTemplate(this.templateEntityId, {this.excludedTypes = const {}});

  @override
  String get componentType => "FromTemplate";
}
