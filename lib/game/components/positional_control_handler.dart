import 'package:flame/components.dart' hide World;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/components.dart' hide Component;
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/game/utils/input_service.dart';

/// Handles positional controls (WASD movement, E for interact) for the currently selected entity.
///
/// This component listens to keyboard input and applies movement/combat intents to whichever
/// entity is currently selected in the game. It only processes controls when the selected
/// entity has a LocalPosition component.
class PositionalControlHandler extends PositionComponent with KeyboardHandler {
  final ValueNotifier<Entity?> selectedEntityNotifier;
  final World world;

  final Logger _logger = Logger("PositionControlHandler");

  PositionalControlHandler({
    required this.selectedEntityNotifier,
    required this.world,
  });

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) return true;

    final entity = selectedEntityNotifier.value;
    if (entity == null || !entity.has<LocalPosition>()) {
      _logger.warning("no entity or entity has no local position");
      return true; // No entity selected or entity can't move
    }
    _logger.finer("starting movement processing for entity=$entity");

    final game = (parent?.findGame() as GameArea);

    // Check for movement controls
    final movement = movementControls.resolve(keysPressed, event.logicalKey);
    if (movement != null) {
      _handleMovement(movement, entity, game);
      return false;
    }

    // Check for entity action controls
    final action = entityActionControls.resolve(keysPressed, event.logicalKey);
    if (action != null) {
      _handleAction(action, entity, game);
      return false;
    }

    return true;
  }

  /// Handles movement input by checking for portals, obstacles, and applying appropriate intents.
  void _handleMovement(Movement movement, Entity entity, GameArea game) {
    _logger.finer("handling movement: entity=$entity movement=$movement");

    final curr = entity.get<LocalPosition>()!;
    final entityParentId = entity.get<HasParent>()?.parentEntityId;
    final dv = Vector2.zero();

    switch (movement) {
      case Movement.up:
        dv.y = -1;
        break;
      case Movement.right:
        dv.x = 1;
        break;
      case Movement.down:
        dv.y = 1;
        break;
      case Movement.left:
        dv.x = -1;
        break;
    }

    final targetX = curr.x + dv.x.truncate();
    final targetY = curr.y + dv.y.truncate();

    // Priority 1: Check for portal at target position
    if (_tryUsePortal(entity, entityParentId, targetX, targetY, curr.x, curr.y)) {
      game.tickEcs();
      return;
    }

    // Priority 2: Check for obstacles at target position (same parent only)
    final targetEntity = _findEntityAtPosition(entityParentId, targetX, targetY);

    if (targetEntity == null) {
      _logger.finer("entity=$entity setting MoveByIntent(dx: ${dv.x.truncate()}, dy:${dv.y.truncate()}) from $curr");

      // Nothing obstructing movement, so move
      entity.upsert(MoveByIntent(dx: dv.x.truncate(), dy: dv.y.truncate()));
    } else {
      _logger.finer("checking if entity=$entity can attack: targetEntity=$targetEntity");

      // Something is blocking the path - check if we can attack it
      final hasHealth = targetEntity.get<Health>() != null;
      if (hasHealth) {
        entity.upsert<AttackIntent>(AttackIntent(targetEntity.id));
      }
    }

    // Always tick after movement input (even if movement was blocked)
    game.tickEcs();
  }

  /// Checks for a portal at the target position and attempts to use it if found.
  /// Returns true if a portal intent was created, false otherwise.
  bool _tryUsePortal(Entity entity, int? entityParentId, int targetX, int targetY, int currentX, int currentY) {
    // Find portal at target position (same parent only)
    final portalsAtTarget = Query()
        .require<LocalPosition>((c) => c.x == targetX && c.y == targetY)
        .require<HasParent>((p) => p.parentEntityId == entityParentId)
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
      entity.upsert(UsePortalIntent(portalEntityId: portalAtTarget.id));
      return true;
    }

    return false;
  }

  /// Finds an entity with BlocksMovement at the specified position within the same parent.
  /// Returns null if no blocking entity is found.
  Entity? _findEntityAtPosition(int? parentId, int x, int y) {
    return Query()
        .require<BlocksMovement>()
        .require<LocalPosition>((c) => c.x == x && c.y == y)
        .require<HasParent>((p) => p.parentEntityId == parentId)
        .first(world);
  }

  /// Handles entity action input (e.g., picking up items, taking control).
  void _handleAction(EntityAction action, Entity entity, GameArea game) {
    switch (action) {
      case EntityAction.interact:
        final pos = entity.get<LocalPosition>()!;
        final entityParentId = entity.get<HasParent>()?.parentEntityId;

        // Priority 1: Check for EnablesControl at same position
        final controlSeat = Query()
            .require<LocalPosition>((c) => c.x == pos.x && c.y == pos.y)
            .require<HasParent>((p) => p.parentEntityId == entityParentId)
            .require<EnablesControl>()
            .first(world);

        if (controlSeat != null) {
          _logger.finer("Found EnablesControl entity at position, adding WantsControlIntent");
          entity.upsert(WantsControlIntent(targetEntityId: controlSeat.id));
          game.tickEcs();
          return;
        }

        // Priority 2: Look for pickupable items at the entity's current position
        final firstItemAtFeet = Query()
            .require<LocalPosition>((c) {
              return c.x == pos.x && c.y == pos.y;
            })
            .require<Pickupable>()
            .first(world);

        if (firstItemAtFeet != null) {
          entity.upsert<PickupIntent>(PickupIntent(firstItemAtFeet.id));
          game.tickEcs();
          return;
        }

        _logger.warning("interaction triggered but nothing happened");
        break;
    }
  }
}
