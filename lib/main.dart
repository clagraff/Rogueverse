import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'src/engine/ecs.dart';
import 'src/ui/game_world.dart';

class MyGame extends FlameGame    with HasKeyboardHandlerComponents {
  @override
  var debugMode = false;

  late final Chunk liveChunk;
  late final GameEngine engine;

  MyGame() {
    world = GameWorld();

    liveChunk = Chunk();
    liveChunk.register<Renderable>();
    liveChunk.register<LocalPosition>();
    liveChunk.register<PlayerControlled>();
    liveChunk.register<BlocksMovement>();
    liveChunk.register<DidMove>();
    liveChunk.register<BlockedMove>();
    liveChunk.register<MoveByIntent>();
    liveChunk.register<AiControlled>();

    engine = GameEngine([liveChunk], [
      CollisionSystem(),
      MovementSystem(),
    ]);
  }

  void tickEcs() {
    engine.tick();
  }
}

void main() {
  runApp(
    GameWidget(game: MyGame()),
  );
}