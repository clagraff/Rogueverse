import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../../main.dart';
import '../../application_ui/overlays/overlay_helper.dart';
import '../../application_ui/overlays/player_inventory_widget.dart';
import '../../ui/components/components.gen.dart';
import '../../engine/engine.gen.dart';

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

class PlayerControlledAgent extends Agent with KeyboardHandler, TapCallbacks {
  Effect? effect;
  Function()? toggleInventoryOverlay;

  PlayerControlledAgent(
      {required super.registry,
      required super.entity,
      required super.svgAssetPath,
      super.position,
      super.size});

  static const movementDistance = 1; // ECS units, not pixels!

  final _inputToDelta = {
    LogicalKeyboardKey.keyA: Vector2(-1, 0),
    LogicalKeyboardKey.keyD: Vector2(1, 0),
    LogicalKeyboardKey.keyW: Vector2(0, -1),
    LogicalKeyboardKey.keyS: Vector2(0, 1),
  };


  void showTable(FlameGame game) {
    var sourceContext = game.buildContext!;
    var player = registry.getEntity(registry.get<PlayerControlled>().keys.first);
    var itemIds = player.get<Inventory>()?.items ?? [];
    var items = itemIds.map((id) => registry.getEntity(id)).toList();

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
    var game = (parent?.findGame() as MyGame);

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

  void handleMovement(Movement result, MyGame game) {
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
    }).first(registry);

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
  bool handleActions(Action interaction, MyGame game) {
    switch (interaction) {
      case Action.interactAtPosition:
        var pos = entity.get<LocalPosition>()!;

        var firstItemAtFeet = Query()
            .require<LocalPosition>((c) {
              return c.x == pos.x && c.y == pos.y;
            })
            .require<Pickupable>()
            .first(registry);

        if (firstItemAtFeet != null) {
          entity.upsert<PickupIntent>(PickupIntent(firstItemAtFeet.id));

          game.tickEcs();
          return true; // handled
        }
    }
    return false; // didnt handle
  }

  bool handleMetaControls(Meta check, MyGame game) {
    switch (check) {
      case Meta.paused:
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
