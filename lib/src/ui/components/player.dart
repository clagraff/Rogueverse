import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:rogueverse/main.dart';
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

enum Meta { paused }

final metaControls = KeyBindingMap<Meta>()
  ..bind(Meta.paused, [LogicalKeyboardKey.space]);

enum Interactions { interactAtPosition }

final interactionControls = KeyBindingMap<Interactions>()
  ..bind(Interactions.interactAtPosition, [LogicalKeyboardKey.keyE]);


class PlayerControlledAgent extends Agent with KeyboardHandler, TapCallbacks  {
  Effect? effect;

  PlayerControlledAgent(
      {required super.chunk,
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

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    var game = (parent?.findGame() as MyGame);

    if (event is KeyDownEvent) {
      var check = metaControls.resolve(keysPressed, event.logicalKey);
      if (check != null && check == Meta.paused) {
        var health = entity.get<Health>()!;
        entity.set<Health>(health.cloneRelative(-1));
        game.tickEcs();
        return false;
      }

      var interaction =
          interactionControls.resolve(keysPressed, event.logicalKey);
      if (interaction != null) {
        switch (interaction) {
          case Interactions.interactAtPosition:
            var pos = entity.get<LocalPosition>()!;

            var firstItemAtFeet = Query()
                .require<LocalPosition>((c) {
                  return c.x == pos.x && c.y == pos.y;
                })
                .require<Pickupable>()
                .first(chunk);
            if (firstItemAtFeet != null) {
              entity.set<PickupIntent>(PickupIntent(firstItemAtFeet.id));

              game.tickEcs();
              return false;
            }
          default:
            break; // no-op
        }
      }

      var result = movementControls.resolve(keysPressed, event.logicalKey);
      if (result != null) {
        switch (result) {
          case Movement.up:
            entity.set(MoveByIntent(dx: 0, dy: -1));
            break;
          case Movement.right:
            entity.set(MoveByIntent(dx: 1, dy: 0));
            break;
          case Movement.down:
            entity.set(MoveByIntent(dx: 0, dy: 1));
            break;
          case Movement.left:
            entity.set(MoveByIntent(dx: -1, dy: 0));
            break;
        }
        game.tickEcs(); // Run tick after input
        return false;
      }
    }
    return true;
  }
}
