import 'dart:developer';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/systems/behavior_system.dart';
import 'package:rogueverse/ecs/systems/system.dart';
import 'package:rogueverse/ecs/world.dart';

part 'portal_system.mapper.dart';

/// System that processes portal usage intents.
///
/// Handles both PortalToPosition (fixed destination) and PortalToAnchor
/// (dynamic destination based on anchor entities) portal types.
@MappableClass()
class PortalSystem extends System with PortalSystemMappable {
  static final _logger = Logger('PortalSystem');

  @override
  Set<Type> get runAfter => {BehaviorSystem};

  @override
  void update(World world) {
    Timeline.timeSync("PortalSystem: update", () {
      final portalIntents = world.get<UsePortalIntent>();
      if (portalIntents.isEmpty) return;

      // Create copy to allow modification during iteration
      final components = Map.from(portalIntents);

      components.forEach((travelerId, intent) {
        final traveler = world.getEntity(travelerId);
        final portalIntent = intent as UsePortalIntent;

        _processPortalIntent(world, traveler, portalIntent);

        // Always remove intent after processing
        traveler.remove<UsePortalIntent>();
      });
    });
  }

  void _processPortalIntent(
      World world, Entity traveler, UsePortalIntent intent) {
    _logger.finest("processing portal intent", {"traveler": traveler, "intent": intent});

    final portal = world.getEntity(intent.portalEntityId);
    final travelerPos = traveler.get<LocalPosition>();

    // Validation: Check if traveler has required components
    if (travelerPos == null) {
      _logger.warning("traveler missing local position", {"traveler": traveler});
      _fail(traveler, intent.portalEntityId,
          PortalFailureReason.missingComponents);
      return;
    }

    // Validation: Check if traveler and portal share the same parent
    final travelerParentId = traveler.get<HasParent>()?.parentEntityId;
    final portalParentId = portal.get<HasParent>()?.parentEntityId;

    if (travelerParentId != portalParentId) {
      _logger.warning("mismatched parentId between traveler and portal", {"traveler": traveler, "travelerParentId": travelerParentId, "portalParentId": portalParentId});
      _fail(traveler, intent.portalEntityId, PortalFailureReason.notSameParent);
      return;
    }

    // Check for PortalToPosition or PortalToAnchor
    final toPosition = portal.get<PortalToPosition>();
    final toAnchor = portal.get<PortalToAnchor>();

    if (toPosition != null) {
      _handlePortalToPosition(world, traveler, portal, toPosition, travelerPos);
    } else if (toAnchor != null) {
      _handlePortalToAnchor(world, traveler, portal, toAnchor, travelerPos,
          intent.specificAnchorId);
    } else {
      _logger.warning("portal missing PortalToPosition/PortalToAnchor component", {"portal": portal});
      _fail(traveler, intent.portalEntityId, PortalFailureReason.portalNotFound);
    }
  }

  void _handlePortalToPosition(
    World world,
    Entity traveler,
    Entity portal,
    PortalToPosition portalConfig,
    LocalPosition travelerPos,
  ) {
    _logger.finest("portaling traveler", {"traveler": traveler, "destParentId": portalConfig.destParentId, "destLocalPosition": portalConfig.destLocation});
    final portalPos = portal.get<LocalPosition>();

    // Validation: Check interaction range
    if (!_isWithinRange(
        travelerPos, portalPos, portalConfig.interactionRange, traveler, portal, world)) {
      _logger.warning("traveler not in portal range", {"traveler": traveler, "portal": portal});
      _fail(traveler, portal.id, PortalFailureReason.outOfRange);
      return;
    }

    // Check if destination parent exists (check if any component exists for this entity ID)
    final destParentExists = world.components.values.any((componentMap) =>
        componentMap.containsKey(portalConfig.destParentId));
    if (!destParentExists) {
      _logger.warning("portal parent missing", {"portal": portal, "destParentId": portalConfig.destParentId});
      _fail(
          traveler, portal.id, PortalFailureReason.destinationParentNotFound);
      return;
    }

    // Check if destination is blocked
    // TODO: double-check this logic.
    if (_isDestinationBlocked(
        world, portalConfig.destParentId, portalConfig.destLocation, traveler.id)) {
      _logger.warning("portal destination blocked", {"traveler": traveler, "portal": portal, "portalConfig": portalConfig});
      _fail(traveler, portal.id, PortalFailureReason.destinationBlocked);
      return;
    }

    // Perform the portal!
    _teleport(
      world,
      traveler,
      portal.id,
      traveler.get<HasParent>()?.parentEntityId ?? -1,
      portalConfig.destParentId,
      travelerPos,
      portalConfig.destLocation,
      null, // No anchor used
    );
  }

  void _handlePortalToAnchor(
    World world,
    Entity traveler,
    Entity portal,
    PortalToAnchor portalConfig,
    LocalPosition travelerPos,
    int? specificAnchorId,
  ) {
    final portalPos = portal.get<LocalPosition>();

    // Validation: Check interaction range
    if (!_isWithinRange(
        travelerPos, portalPos, portalConfig.interactionRange, traveler, portal, world)) {
      _fail(traveler, portal.id, PortalFailureReason.outOfRange);
      return;
    }

    // Determine which anchor to use
    int? targetAnchorId;

    if (specificAnchorId != null) {
      // Use the specifically requested anchor if it's in the list
      if (portalConfig.destAnchorEntityIds.contains(specificAnchorId)) {
        targetAnchorId = specificAnchorId;
      } else {
        _fail(traveler, portal.id, PortalFailureReason.anchorNotFound);
        return;
      }
    } else {
      // No specific anchor requested, try anchors in order until one works
      for (final anchorId in portalConfig.destAnchorEntityIds) {
        final anchor = world.getEntity(anchorId);

        if (!anchor.has<PortalAnchor>()) continue;

        final anchorPos = anchor.get<LocalPosition>();
        final anchorParent = anchor.get<HasParent>();

        if (anchorPos == null || anchorParent == null) continue;

        // Calculate destination position (anchor + offset)
        final destPos = LocalPosition(
          x: anchorPos.x + portalConfig.offsetX,
          y: anchorPos.y + portalConfig.offsetY,
        );

        // Check if destination is blocked
        if (!_isDestinationBlocked(
            world, anchorParent.parentEntityId, destPos, traveler.id)) {
          // Found a valid anchor!
          targetAnchorId = anchorId;
          break;
        }
      }

      if (targetAnchorId == null) {
        _fail(traveler, portal.id, PortalFailureReason.noValidAnchors);
        return;
      }
    }

    // We have a valid anchor, perform the teleport
    final anchor = world.getEntity(targetAnchorId);
    final anchorPos = anchor.get<LocalPosition>()!;
    final anchorParent = anchor.get<HasParent>()!;

    final destPos = LocalPosition(
      x: anchorPos.x + portalConfig.offsetX,
      y: anchorPos.y + portalConfig.offsetY,
    );

    // Final check if destination is blocked (in case specificAnchorId was provided)
    if (_isDestinationBlocked(
        world, anchorParent.parentEntityId, destPos, traveler.id)) {
      _fail(traveler, portal.id, PortalFailureReason.destinationBlocked);
      return;
    }

    // Perform the portal!
    _teleport(
      world,
      traveler,
      portal.id,
      traveler.get<HasParent>()?.parentEntityId ?? -1,
      anchorParent.parentEntityId,
      travelerPos,
      destPos,
      targetAnchorId,
    );
  }

  bool _isWithinRange(
    LocalPosition travelerPos,
    LocalPosition? portalPos,
    int interactionRange,
    Entity traveler,
    Entity portal,
    World world,
  ) {
    // Range < 0: any distance allowed
    if (interactionRange < 0) return true;

    // No portal position means we can't check range
    if (portalPos == null) return false;

    // Range == 0: must be at exact same position
    if (interactionRange == 0) {
      return travelerPos.sameLocation(portalPos);
    }

    // Range > 0: within Manhattan distance
    final dx = (travelerPos.x - portalPos.x).abs();
    final dy = (travelerPos.y - portalPos.y).abs();
    final distance = dx + dy; // Manhattan distance

    return distance <= interactionRange;
  }

  bool _isDestinationBlocked(
    World world,
    int destParentId,
    LocalPosition destPos,
    int travelerId,
  ) {
    // Get all children in destination parent
    final children = world.hierarchyCache.getChildren(destParentId);

    for (final childId in children) {
      if (childId == travelerId) continue; // Don't check against self

      final child = world.getEntity(childId);
      if (!child.has<BlocksMovement>()) continue;

      final childPos = child.get<LocalPosition>();
      if (childPos != null && childPos.sameLocation(destPos)) {
        return true; // Destination is blocked
      }
    }

    return false;
  }

  void _teleport(
    World world,
    Entity traveler,
    int portalId,
    int fromParentId,
    int toParentId,
    LocalPosition fromPos,
    LocalPosition toPos,
    int? usedAnchorId,
  ) {
    // Update position
    traveler.upsert(LocalPosition(x: toPos.x, y: toPos.y));

    // Update parent if changing
    if (fromParentId != toParentId) {
      traveler.upsert(HasParent(toParentId));
    } else {
      _logger.finest("traveler already in same parent", {"traveler": traveler, "destParentId": toParentId});
    }

    // Add success component
    traveler.upsert(DidPortal(
      portalEntityId: portalId,
      fromParentId: fromParentId,
      toParentId: toParentId,
      fromPosition: fromPos,
      toPosition: toPos,
      usedAnchorId: usedAnchorId,
    ));

    // TODO: set entity direction based on Portal component (as an optional field in there).

    _logger.finest("portaled traveler", {
      "traveler": traveler,
      "portalId": portalId,
      "fromParentId": fromParentId,
      "toParentId": toParentId,
      "fromPos": fromPos,
      "toPos": toPos,
      "usedAnchorId": usedAnchorId != null
    });
  }

  // TODO: uh do we need this? we already have log statements for most of the failure conditions at the place they happened.
  void _fail(Entity traveler, int portalId, PortalFailureReason reason) {
    traveler.upsert(FailedToPortal(
      portalEntityId: portalId,
      reason: reason,
    ));

    _logger.warning(
        'portal_failed: entity=${traveler.id}, portal=$portalId, reason=$reason');
  }
}
