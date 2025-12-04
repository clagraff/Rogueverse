import 'dart:async';

import 'package:flame/components.dart' hide World;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/ecs.init.dart';
import 'package:rogueverse/ecs/systems.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ui/game_world.dart';
import 'package:rogueverse/ui/hud/camera_controls.dart';
import 'package:rogueverse/ui/mixins/scroll_callback.dart';
import 'package:window_manager/window_manager.dart';


class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, ScrollDetector {
  @override
  get debugMode => false;

  late World registry;
  late final ScrollDispatcher scrollDispatcher;

  MyGame() {
    world = GameWorld();
    var systems = [
      CollisionSystem(),
      MovementSystem(),
      InventorySystem(),
      CombatSystem(),
    ];

    registry = World(systems, {});
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
    await WorldSaves.writeSave(registry);
  }
}

void main() async {
  initializeMappers();

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
