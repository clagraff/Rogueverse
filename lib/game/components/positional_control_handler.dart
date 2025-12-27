import 'package:flame/components.dart' hide World;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

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

  PositionalControlHandler({
    required this.selectedEntityNotifier,
    required this.world,
  });

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) return true;

    final entity = selectedEntityNotifier.value;
    if (entity == null || !entity.has<LocalPosition>()) {
      return true; // No entity selected or entity can't move
    }

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

  /// Handles movement input by checking for obstacles and applying movement or attack intents.
  void _handleMovement(Movement movement, Entity entity, GameArea game) {
    final curr = entity.get<LocalPosition>()!;
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

    // Check for obstacles at target position
    final targetEntity =
        Query().require<BlocksMovement>().require<LocalPosition>((c) {
      return c.x == curr.x + dv.x && c.y == curr.y + dv.y;
    }).first(world);

    if (targetEntity == null) {
      // Nothing obstructing movement, so move
      entity.upsert(MoveByIntent(dx: dv.x.truncate(), dy: dv.y.truncate()));
    } else {
      // Something is blocking the path - check if we can attack it
      final hasHealth = targetEntity.get<Health>() != null;
      if (hasHealth) {
        entity.upsert<AttackIntent>(AttackIntent(targetEntity.id));
      }
    }

    // Always tick after movement input (even if movement was blocked)
    game.tickEcs();
  }

  /// Handles entity action input (e.g., picking up items).
  void _handleAction(EntityAction action, Entity entity, GameArea game) {
    switch (action) {
      case EntityAction.interact:
        final pos = entity.get<LocalPosition>()!;

        // Look for pickupable items at the entity's current position
        final firstItemAtFeet = Query()
            .require<LocalPosition>((c) {
              return c.x == pos.x && c.y == pos.y;
            })
            .require<Pickupable>()
            .first(world);

        if (firstItemAtFeet != null) {
          entity.upsert<PickupIntent>(PickupIntent(firstItemAtFeet.id));
          game.tickEcs();
        }
        break;
    }
  }
}
