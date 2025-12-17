import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/app/application.dart';
import 'package:rogueverse/ecs/ecs.init.dart';
import 'package:rogueverse/ecs/template_registry.dart';
import 'package:window_manager/window_manager.dart';



void main() async {
  loggerSetup();
  initializeMappers(); // Required for the dart_mappable de/serialization.

  await TemplateRegistry.instance.load();

  if (!kIsWeb) {
    await setupWindow();
  }

  runApp(
    Application(gameAreaFocusNode: FocusNode(debugLabel: 'game')),
  );
}

/// Hardcode log level, setup log sinking.
void loggerSetup() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    var message = "[${record.level}: ${record.loggerName}] ${record.message}";
    if (record.error != null) {
      message += " ${record.error!.toString()}";
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
    size: Size(1290, 1080),
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