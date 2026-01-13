import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/app/application.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/ecs/ecs.init.dart';
import 'package:rogueverse/ecs/template_registry.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:window_manager/window_manager.dart';



void main() async {
  loggerSetup();
  initializeMappers(); // Required for the dart_mappable de/serialization.

  await TemplateRegistry.instance.load();
  await KeyBindingService.instance.load();

  // Migrate existing save.json to initial.json if needed (layered save system)
  if (!kIsWeb) {
    await WorldSaves.migrateIfNeeded();
  }

  if (!kIsWeb) {
    await setupWindow();
  }

  runApp(
    Application(gameAreaFocusNode: FocusNode(debugLabel: 'game')),
  );
}

/// Hardcode log level, setup log sinking.
void loggerSetup() {
  // Map of log levels (as int) to ANSI color codes
  final levelColors = <Level, String>{
    Level.FINEST: '\x1B[96m', // Bright cyan (basic color)
    Level.FINER: '\x1B[36m', // Cyan (basic color)
    Level.FINE: '\x1B[94m', // Bright blue (basic color)
    Level.CONFIG: '\x1B[35m', // Magenta (basic color)
    Level.INFO: '\x1B[38;5;255m', // White
    Level.WARNING: '\x1B[38;5;221m', // Yellow
    Level.SEVERE: '\x1B[38;5;196m', // Red
    Level.SHOUT: '\x1B[38;5;201m', // Bright magenta
  };
  const resetCode = '\x1B[0m';

  String getColorForLevel(Level level) {
    return levelColors[level] ?? '';
  }

  final supportsColors = !kIsWeb;

  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    var message = "[${record.level}:${record.loggerName}] ${record.message}";
    if (record.error != null) {
      message += " ${record.error!.toString()}";
    }

    if (supportsColors) {
      final color = getColorForLevel(record.level);
      message = '$color$message$resetCode';
    }

    if (kDebugMode) {
      print(message);
    }
  });
}

/// Setup the desktop (non-web) window so it is centered and has a default size.
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