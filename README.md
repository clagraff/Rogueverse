# ECS Game Engine

A minimal, extensible Entity-Component-System (ECS) game engine core written in Dart. Designed for use with Flame + Flutter, but platform-agnostic by nature.

## Features

* Intent-based, turn-oriented ECS architecture
* Transient components for one-off events (e.g. `MoveIntent`, `DidMove`, `BlockedMove`)
* Priority-ordered systems for deterministic updates
* Fluent entity access via `EntityRef`
* Pure Dart, no dependencies on serialization or Flame

## Project Structure

### Core Concepts

* **World**: Stores all entities and component data.
* **EntityRef**: Wrapper for accessing components of a specific entity.
* **ComponentStore**: Manages mapping of entity ID to a specific component type.
* **System**: Defines update behavior applied to matching entities each tick.

### Component Example

```dart
class LocalPosition {
  int x, y;
  LocalPosition({required this.x, required this.y});
}

class MoveIntent implements Transient {
  final int dx, dy;
  MoveIntent({required this.dx, required this.dy});
}
```

### System Example

```dart
class MovementSystem extends System {
  static const int priority = CollisionSystem.priority + 1;
  @override
  int get priority => MovementSystem.priority;

  @override
  void update(World world) {
    final moveIntents = world.store<MoveIntent>();
    for (final id in moveIntents.data.keys) {
      final e = world.entity(id);
      final pos = e.get<LocalPosition>();
      final intent = e.get<MoveIntent>();
      if (pos == null || intent == null) continue;
      pos.x += intent.dx;
      pos.y += intent.dy;
      e.set(DidMove(from: pos, to: LocalPosition(x: pos.x, y: pos.y)));
      e.remove<MoveIntent>();
    }
  }
}
```

## Transient Components

Components implementing `Transient` are automatically cleared at the end of each tick, perfect for:

* Intents
* Effects
* Events

## Engine Usage

```dart
final world = World();
final engine = GameEngine(world, [CollisionSystem(), MovementSystem()]);

final player = world.createEntity();
world.store<LocalPosition>().set(player, LocalPosition(x: 0, y: 0));
world.store<MoveIntent>().set(player, MoveIntent(dx: 1, dy: 0));

engine.tick();
```

## Next Steps

* Add AI behavior trees
* Support chunk/region loading
* Integrate with Flame for rendering
* Build command queue for intent batching

## License

