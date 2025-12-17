import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart' hide Game;
import 'package:flutter/services.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/main.dart';
import 'package:rogueverse/app/widgets/overlays/overlay_helper.dart';
import 'package:rogueverse/app/widgets/overlays/player_inventory_widget.dart';
import 'package:rogueverse/game/components/agent.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ecs/entity.dart';

class KeyBindingMap<T> {
  final Map<Set<LogicalKeyboardKey>, T> _bindings = {};

  void bind(T action, List<LogicalKeyboardKey> keys) {
    _bindings[{...keys}] = action;
  }

  /// Tries to resolve the current keypress set to a mapped action.
  T? resolve(
      Set<LogicalKeyboardKey> keysPressed, LogicalKeyboardKey latestKey) {
    for (final entry in _bindings.entries) {
      if (entry.key.length == keysPressed.length &&
          entry.key.containsAll(keysPressed)) {
        return entry.value;
      }
    }
    return null;
  }
}

enum Movement { up, right, down, left }

final movementControls = KeyBindingMap<Movement>()
  ..bind(Movement.left, [LogicalKeyboardKey.keyA])
  ..bind(Movement.right, [LogicalKeyboardKey.keyD])
  ..bind(Movement.up, [LogicalKeyboardKey.keyW])
  ..bind(Movement.down, [LogicalKeyboardKey.keyS]);

enum Meta { paused, inventory }

final metaControls = KeyBindingMap<Meta>()
  ..bind(Meta.paused, [LogicalKeyboardKey.space])
  ..bind(Meta.inventory, [LogicalKeyboardKey.tab]);

enum Action { interactAtPosition }

final actionControls = KeyBindingMap<Action>()
  ..bind(Action.interactAtPosition, [LogicalKeyboardKey.keyE]);

class PlayerControlledAgent extends Agent with KeyboardHandler {
  Effect? effect;
  Function()? toggleInventoryOverlay;

  PlayerControlledAgent(
      {required super.world,
      required super.entity,
      required super.svgAssetPath,
      super.position,
      super.size});

  static const movementDistance = 1; // ECS units, not pixels!

  void showTable(FlameGame game) {
    var sourceContext = game.buildContext!;
    var player = world.getEntity(world.get<PlayerControlled>().keys.first);
    var itemIds = player.get<Inventory>()?.items ?? [];
    var items = itemIds.map((id) => world.getEntity(id)).toList();

    toggleInventoryOverlay = addOverlay(
        game: game,
        sourceContext: sourceContext,
        child: PlayerInventoryWidget(
          game: game,
          inventory: items,
          onClose: () {
            // Don't need to manually call toggleInventoryOverlay() as it will
            // already be closed when this onClose callback executes. Just clear
            // out the callback.
            toggleInventoryOverlay = null;
          },
        ));
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    var game = (parent?.findGame() as GameArea);

    if (event is KeyDownEvent) {
      var check = metaControls.resolve(keysPressed, event.logicalKey);
      if (check != null) {
        return handleMetaControls(check, game);
      }

      var action = actionControls.resolve(keysPressed, event.logicalKey);
      if (action != null) {
        if (handleActions(action, game)) {
          return false;
        }
      }

      var result = movementControls.resolve(keysPressed, event.logicalKey);
      if (result != null) {
        handleMovement(result, game); // Run tick after input
        return false;
      }
    }
    return true;
  }

  void handleMovement(Movement result, GameArea game) {
    var curr = entity.get<LocalPosition>()!;
    var dv = Vector2.zero();

    switch (result) {
      case Movement.up:
        dv.y = -1;
        // entity.set(MoveByIntent(dx: 0, dy: -1));
        break;
      case Movement.right:
        dv.x = 1;
        // entity.set(MoveByIntent(dx: 1, dy: 0));
        break;
      case Movement.down:
        dv.y = 1;
        // entity.set(MoveByIntent(dx: 0, dy: 1));
        break;
      case Movement.left:
        dv.x = -1;
        // entity.set(MoveByIntent(dx: -1, dy: 0));
        break;
    }


    var target2 = Query()
        .require<BlocksMovement>()
        .require<LocalPosition>((c) {
      return c.x == curr.x + dv.x && c.y == curr.y + dv.y;
    }).first(world);

    if (target2 == null) {
      // Nothing obstructing movement, so move
      entity.upsert(MoveByIntent(dx: dv.x.truncate(), dy: dv.y.truncate()));
    } else {
      var hasHealth = target2.get<Health>() != null;
      if (hasHealth) {
        entity.upsert<AttackIntent>(AttackIntent(target2.id));
      }
    }

    // Will always tick. This includes when movement isnt possible.
    game.tickEcs(); // Run tick after input
  }

  /// Attempt to handle any triggered interactions. Returns [true] if an interaction
  /// was handled, otherwise [false].
  bool handleActions(Action interaction, GameArea game) {
    switch (interaction) {
      case Action.interactAtPosition:
        var pos = entity.get<LocalPosition>()!;

        var firstItemAtFeet = Query()
            .require<LocalPosition>((c) {
              return c.x == pos.x && c.y == pos.y;
            })
            .require<Pickupable>()
            .first(world);

        if (firstItemAtFeet != null) {
          entity.upsert<PickupIntent>(PickupIntent(firstItemAtFeet.id));

          game.tickEcs();
          return true; // handled
        }
    }
    return false; // didnt handle
  }

  bool handleMetaControls(Meta check, GameArea game) {
    switch (check) {
      case Meta.paused:
        //game.overlays.toggle("inspectorPanel");
        game.tickEcs();
        break;
      case Meta.inventory:
        if (toggleInventoryOverlay == null) {
          showTable(game);
        } else {
          toggleInventoryOverlay!();
          toggleInventoryOverlay = null;
        }
    }
    return false;
  }
}
