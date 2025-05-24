import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/src/application_ui/overlays/example.dart';

import 'src/ui/mixins/scroll_callback.dart';
import 'src/ui/hud/camera_controls.dart';
import 'src/engine/engine.gen.dart';
import 'src/ui/game_world.dart';

class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, ScrollDetector {
  @override
  var debugMode = false;

  late final Chunk liveChunk;
  late final GameEngine engine;
  late final ScrollDispatcher scrollDispatcher;

  MyGame() {
    world = GameWorld();

    liveChunk = Chunk();

    engine = GameEngine([
      liveChunk
    ], [
      CollisionSystem(),
      MovementSystem(),
      InventorySystem(),
      CombatSystem(),
    ]);
  }

  @override
  FutureOr<void> onLoad() {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.add(CameraControls());

    scrollDispatcher = ScrollDispatcher();
    //registerKey(scrollDispatcher.key!, scrollDispatcher);

    add(scrollDispatcher);

    return super.onLoad();
  }

  @override
  void onScroll(PointerScrollInfo info) {
    final handled = scrollDispatcher.dispatch(info);
    if (!handled) {
      // Default: zoom the camera
      camera.viewfinder.zoom += info.scrollDelta.global.y.sign * 0.02;
      camera.viewfinder.zoom = camera.viewfinder.zoom.clamp(0.1, 3.0);
    }
  }

  void tickEcs() {
    engine.tick();
  }
}

void main() {
  // Set up hierarchical logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // Convert to structured format (e.g., JSON)
    // final structuredLog = {
    //   'time': record.time.toIso8601String(),
    //   'level': record.level.name,
    //   'logger': record.loggerName,
    //   'content': record.message,
    //   if (record.error != null) 'error': record.error?.toString(),
    // };

    var message =
        "[ ${record.level} : ${record.loggerName} ] ${record.message}";
    if (record.error != null) {
      message += " ${record.error!.toString()}";
    }
    print(message);
  });
  final parentLogger = Logger('app');
  final childLogger = Logger('app.database');

  parentLogger.info('Application started');
  parentLogger.info({'notice': 'Hello world!'});
  childLogger.warning('Database connection slow', {'latency': '200ms'});

  // runApp(
  //   GameWidget(game: MyGame(), overlayBuilderMap: {
  //     'Example': (BuildContext context, MyGame game) {
  //       return Example();
  //     }
  //   }),
  // );
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      // Root widget
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My Home Page'),
        ),
        body: Stack(children: [
          GameWidget(game: MyGame()),
        ]),
      ),
    );
  }
}
