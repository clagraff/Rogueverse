import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';

import '../../main.dart';
import '../engine/ecs.dart' as esc;
import 'svg_component.dart';
import 'agent.dart';

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

class PlayerControlledAgent extends Agent with KeyboardHandler {
  Effect? effect;

  PlayerControlledAgent({
    required super.chunk,
    required super.entity,
    required super.svgAssetPath,
    super.position,
    super.size
  });

  static const movementDistance = 1; // ECS units, not pixels!

  final _inputToDelta = {
    LogicalKeyboardKey.keyA: Vector2(-1, 0),
    LogicalKeyboardKey.keyD: Vector2(1, 0),
    LogicalKeyboardKey.keyW: Vector2(0, -1),
    LogicalKeyboardKey.keyS: Vector2(0, 1),
  };

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      var check = metaControls.resolve(keysPressed, event.logicalKey);
      if (check != null && check == Meta.paused) {
        print("Ticking!");
        (parent?.findGame() as MyGame).tickEcs();
        return true;
      }


      var result = movementControls.resolve(keysPressed, event.logicalKey);
      if (result == null) {
        return false;
      }

      switch (result) {
        case Movement.up:
          entity.set(esc.MoveByIntent(dx: 0, dy: -1));
          break;
        case Movement.right:
          entity.set(esc.MoveByIntent(dx: 1, dy: 0));
          break;
        case Movement.down:
          entity.set(esc.MoveByIntent(dx: 0, dy: 1));
          break;
        case Movement.left:
          entity.set(esc.MoveByIntent(dx: -1, dy: 0));
          break;
      }
      (parent?.findGame() as MyGame).tickEcs(); // Run tick after input
    }
    return true;
  }
}
