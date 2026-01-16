import 'package:flame/components.dart' hide World;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/ecs/components.dart' hide Component;
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/game_area.dart';

/// Handles positional controls (WASD movement) for the currently selected entity.
///
/// This component listens to keyboard input and applies movement/combat intents to whichever
/// entity is currently selected in the game. It only processes controls when the selected
/// entity has a LocalPosition component.
///
/// Note: E key interactions are handled by [InteractionControlHandler] which shows a context menu.
class PositionalControlHandler extends PositionComponent with KeyboardHandler {
  final ValueNotifier<Entity?> selectedEntityNotifier;
  final World world;
  final _keybindings = KeyBindingService.instance;

  /// Whether this handler is enabled. Disabled in editing mode.
  bool isEnabled = true;

  final Logger _logger = Logger("PositionControlHandler");

  PositionalControlHandler({
    required this.selectedEntityNotifier,
    required this.world,
  });

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Handle both initial key press and key repeat (for continuous movement while holding)
    if (!isEnabled || (event is! KeyDownEvent && event is! KeyRepeatEvent)) return true;

    final entity = selectedEntityNotifier.value;
    _logger.info("onKeyEvent: isEnabled=$isEnabled, entity=$entity, hasLocalPosition=${entity?.has<LocalPosition>()}");
    if (entity == null || !entity.has<LocalPosition>()) {
      _logger.warning("no entity or entity has no local position");
      return true; // No entity selected or entity can't move
    }
    _logger.finer("starting movement processing for entity=$entity");

    final game = (parent?.findGame() as GameArea);

    // Check for face-direction first (Shift+WASD takes priority)
    final faceDirection = _resolveDirection(keysPressed);
    if (faceDirection != null) {
      _logger.finer("entity=$entity setting DirectionIntent(direction: $faceDirection)");
      entity.setIntent(DirectionIntent(faceDirection));
      return false;
    }

    // Check for strafe movement (Ctrl+WASD - move without changing direction)
    final strafe = _resolveStrafe(keysPressed);
    if (strafe != null) {
      _handleStrafe(strafe, entity);
      return false;
    }

    // Check for movement controls
    final movement = _resolveMovement(keysPressed);
    if (movement != null) {
      _handleMovement(movement, entity, game);
      return false;
    }

    // Note: E key interactions are now handled by InteractionControlHandler
    // which shows a context menu for selecting interactions.

    return true;
  }

  /// Resolves movement direction from currently pressed keys.
  Vector2? _resolveMovement(Set<LogicalKeyboardKey> keysPressed) {
    if (_keybindings.matches('movement.up', keysPressed)) {
      return Vector2(0, -1);
    }
    if (_keybindings.matches('movement.down', keysPressed)) {
      return Vector2(0, 1);
    }
    if (_keybindings.matches('movement.left', keysPressed)) {
      return Vector2(-1, 0);
    }
    if (_keybindings.matches('movement.right', keysPressed)) {
      return Vector2(1, 0);
    }
    return null;
  }

  /// Resolves face-direction from currently pressed keys (Shift+WASD).
  CompassDirection? _resolveDirection(Set<LogicalKeyboardKey> keysPressed) {
    if (_keybindings.matches('direction.up', keysPressed)) {
      return CompassDirection.north;
    }
    if (_keybindings.matches('direction.down', keysPressed)) {
      return CompassDirection.south;
    }
    if (_keybindings.matches('direction.left', keysPressed)) {
      return CompassDirection.west;
    }
    if (_keybindings.matches('direction.right', keysPressed)) {
      return CompassDirection.east;
    }
    return null;
  }

  /// Resolves strafe direction from currently pressed keys (Ctrl+WASD).
  /// Returns movement vector without changing facing direction.
  Vector2? _resolveStrafe(Set<LogicalKeyboardKey> keysPressed) {
    if (_keybindings.matches('strafe.up', keysPressed)) {
      return Vector2(0, -1);
    }
    if (_keybindings.matches('strafe.down', keysPressed)) {
      return Vector2(0, 1);
    }
    if (_keybindings.matches('strafe.left', keysPressed)) {
      return Vector2(-1, 0);
    }
    if (_keybindings.matches('strafe.right', keysPressed)) {
      return Vector2(1, 0);
    }
    return null;
  }

  /// Handles strafe input by moving without changing direction.
  /// Unlike regular movement, strafe does not emit a DirectionIntent.
  void _handleStrafe(Vector2 dv, Entity entity) {
    _logger.finer("handling strafe: entity=$entity dv=$dv");

    final curr = entity.get<LocalPosition>()!;
    final entityParentId = entity.get<HasParent>()?.parentEntityId;
    final visibleEntities = entity.get<VisibleEntities>();

    final targetX = curr.x + dv.x.truncate();
    final targetY = curr.y + dv.y.truncate();

    // Priority 1: Check for portal at target position
    if (_tryUsePortal(entity, entityParentId, targetX, targetY, curr.x, curr.y)) {
      return;
    }

    // Priority 2: Check for closed doors at target position
    final closedDoor = _findClosedDoorAtPosition(entityParentId, targetX, targetY);
    if (closedDoor != null) {
      // If we can't see the door, do nothing during strafe (no direction change)
      if (!_isEntityVisible(closedDoor, visibleEntities)) {
        _logger.finer("entity=$entity cannot see door during strafe, ignoring");
        return;
      }
      _logger.finer("entity=$entity opening door during strafe: closedDoor=$closedDoor");
      entity.setIntent(OpenIntent(targetEntityId: closedDoor.id));
      return;
    }

    // Priority 3: Check for other obstacles at target position
    final targetEntity = _findBlockingEntityAtPosition(entityParentId, targetX, targetY);

    if (targetEntity == null) {
      _logger.finer("entity=$entity setting StrafeIntent(dx: ${dv.x.truncate()}, dy:${dv.y.truncate()}) from $curr");
      // Use MoveByIntent with strafe flag to move without changing direction
      entity.setIntent(MoveByIntent(dx: dv.x.truncate(), dy: dv.y.truncate(), isStrafe: true));
    } else {
      _logger.finer("checking interactions for blocked strafe path: targetEntity=$targetEntity");

      // If we can't see the target entity, do nothing during strafe
      if (!_isEntityVisible(targetEntity, visibleEntities)) {
        _logger.finer("entity=$entity cannot see target during strafe, ignoring");
        return;
      }

      // Check if we can attack it
      final hasHealth = targetEntity.get<Health>() != null;
      if (hasHealth) {
        entity.setIntent(AttackIntent(targetEntity.id));
      }
    }
  }

  /// Handles movement input by checking for portals, obstacles, and applying appropriate intents.
  void _handleMovement(Vector2 dv, Entity entity, GameArea game) {
    _logger.finer("handling movement: entity=$entity dv=$dv");

    final curr = entity.get<LocalPosition>()!;
    final entityParentId = entity.get<HasParent>()?.parentEntityId;
    final visibleEntities = entity.get<VisibleEntities>();

    final targetX = curr.x + dv.x.truncate();
    final targetY = curr.y + dv.y.truncate();

    // Priority 1: Check for portal at target position
    if (_tryUsePortal(entity, entityParentId, targetX, targetY, curr.x, curr.y)) {
      return;
    }

    // Priority 2: Check for closed doors at target position (regardless of BlocksMovement)
    final closedDoor = _findClosedDoorAtPosition(entityParentId, targetX, targetY);
    if (closedDoor != null) {
      // If we can't see the door, just face that direction instead of opening
      if (!_isEntityVisible(closedDoor, visibleEntities)) {
        _logger.finer("entity=$entity cannot see door, facing direction instead");
        entity.setIntent(DirectionIntent(Direction.fromOffset(dv.x.truncate(), dv.y.truncate())));
        return;
      }
      _logger.finer("entity=$entity opening door: closedDoor=$closedDoor");
      entity.setIntent(OpenIntent(targetEntityId: closedDoor.id));
      return;
    }

    // Priority 3: Check for other obstacles at target position (same parent only)
    final targetEntity = _findBlockingEntityAtPosition(entityParentId, targetX, targetY);

    if (targetEntity == null) {
      _logger.finer("entity=$entity setting MoveByIntent(dx: ${dv.x.truncate()}, dy:${dv.y.truncate()}) from $curr");

      // Nothing obstructing movement, so move
      entity.setIntent(MoveByIntent(dx: dv.x.truncate(), dy: dv.y.truncate()));
    } else {
      _logger.finer("checking interactions for blocked path: targetEntity=$targetEntity");

      // If we can't see the target entity, just face that direction
      if (!_isEntityVisible(targetEntity, visibleEntities)) {
        _logger.finer("entity=$entity cannot see target, facing direction instead");
        entity.setIntent(DirectionIntent(Direction.fromOffset(dv.x.truncate(), dv.y.truncate())));
        return;
      }

      // Check if we can attack it
      final hasHealth = targetEntity.get<Health>() != null;
      if (hasHealth) {
        entity.setIntent(AttackIntent(targetEntity.id));
      }
    }
  }

  /// Checks if the target entity is visible to the observer.
  /// Returns true if observer has no vision system (always visible) or target is in visible entities.
  bool _isEntityVisible(Entity target, VisibleEntities? visibleEntities) {
    // If no vision system, everything is visible
    if (visibleEntities == null) return true;
    return visibleEntities.entityIds.contains(target.id);
  }

  /// Checks for a portal at the target position and attempts to use it if found.
  /// Returns true if a portal intent was created, false otherwise.
  bool _tryUsePortal(Entity entity, int? entityParentId, int targetX, int targetY, int currentX, int currentY) {
    // Find portal at target position (same parent only)
    final query = Query()
        .require<LocalPosition>((c) => c.x == targetX && c.y == targetY);
    _applyParentFilter(query, entityParentId);

    final portalsAtTarget = query
        .find(world)
        .where((e) => e.has<PortalToPosition>() || e.has<PortalToAnchor>());

    final portalAtTarget = portalsAtTarget.firstOrNull;
    if (portalAtTarget == null) return false;

    // Check interaction range
    final portalToPos = portalAtTarget.get<PortalToPosition>();
    final portalToAnchor = portalAtTarget.get<PortalToAnchor>();
    final interactionRange = portalToPos?.interactionRange ??
                             portalToAnchor?.interactionRange ?? 0;

    // Skip portals with range 0 (must be exactly on portal)
    if (interactionRange == 0) return false;

    final distance = (currentX - targetX).abs() + (currentY - targetY).abs();
    final canUse = interactionRange < 0 || distance <= interactionRange;

    if (canUse) {
      _logger.finer("Setting UsePortalIntent on entity=$entity for portalEntityId=${portalAtTarget.id}");
      entity.setIntent(UsePortalIntent(portalEntityId: portalAtTarget.id));
      return true;
    }

    return false;
  }

  /// Finds a closed Openable (door) at the specified position within the same parent.
  /// Returns null if no closed door is found.
  Entity? _findClosedDoorAtPosition(int? parentId, int x, int y) {
    final query = Query()
        .require<Openable>((o) => !o.isOpen)
        .require<LocalPosition>((c) => c.x == x && c.y == y);
    _applyParentFilter(query, parentId);
    return query.first(world);
  }

  /// Finds an entity with BlocksMovement at the specified position within the same parent.
  /// Returns null if no blocking entity is found.
  Entity? _findBlockingEntityAtPosition(int? parentId, int x, int y) {
    final query = Query()
        .require<BlocksMovement>()
        .require<LocalPosition>((c) => c.x == x && c.y == y);
    _applyParentFilter(query, parentId);
    return query.first(world);
  }

  /// Applies parent filtering to a query.
  ///
  /// If [parentId] is null, excludes entities with HasParent (root-level entities only).
  /// If [parentId] is not null, requires HasParent with matching parentEntityId.
  void _applyParentFilter(Query query, int? parentId) {
    if (parentId == null) {
      query.exclude<HasParent>();
    } else {
      query.require<HasParent>((p) => p.parentEntityId == parentId);
    }
  }

}
