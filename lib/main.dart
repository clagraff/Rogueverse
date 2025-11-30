import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:window_manager/window_manager.dart';

import 'src/ui/mixins/scroll_callback.dart';
import 'src/ui/hud/camera_controls.dart';
import 'src/ui/game_world.dart';
import 'src/ecs/ecs.barrel.dart' as ecs;


class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, ScrollDetector {
  @override
  get debugMode => false;

  late ecs.World registry;
  late final ScrollDispatcher scrollDispatcher;

  MyGame() {
    world = GameWorld();
    var systems = [
      ecs.CollisionSystem(),
      ecs.MovementSystem(),
      ecs.InventorySystem(),
      ecs.CombatSystem(),
    ];

    registry = ecs.World(systems, {});
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

  Future<void> tickEcs() async {
    registry.tick();
    await ecs.WorldSaves.writeSave(registry);
  }
}

void main() async {
  ecs.initializeMappers();

  // Set up hierarchical logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    var message =
        "[${record.level}: ${record.loggerName}] ${record.message}";
    if (record.error != null) {
      message += " ${record.error!.toString()}";
    }
    if (kDebugMode) {
      print(message);
    }
  });

  if (!kIsWeb) {
    await setupWindow();
  }

  runApp(
    MyApp(),
  );
}

Future<void> setupWindow() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var darkColorScheme = ColorScheme.dark();
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        dialogTheme: DialogThemeData(
          backgroundColor: darkColorScheme.surface,
          elevation: 6.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      // Root widget
      home: Scaffold(
        // appBar: AppBar(
        //   title: const Text('My Home Page'),
        // ),
        body: Stack(children: [
          GameWidget(game: MyGame()),
        ]),
      ),
    );
  }
}
