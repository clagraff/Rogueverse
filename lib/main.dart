import 'dart:async';

import 'package:flame/components.dart' hide World;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/ecs.init.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/entity_template.dart';
import 'package:rogueverse/ecs/systems.dart';
import 'package:rogueverse/ecs/template_registry.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/overlays/inspector/inspector_overlay.dart';
import 'package:rogueverse/overlays/navigation_menu.dart';
import 'package:rogueverse/overlays/template_panel/template_panel.barrel.dart';
import 'package:rogueverse/ui/game_world.dart';
import 'package:rogueverse/ui/hud/camera_controls.dart';
import 'package:rogueverse/ui/mixins/scroll_callback.dart';
import 'package:window_manager/window_manager.dart';

class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, ScrollDetector {
  final ValueNotifier<Entity?> selectedEntity = ValueNotifier(null);
  final ValueNotifier<EntityTemplate?> selectedTemplate = ValueNotifier(null);
  final ValueNotifier<String> hoveredEntityName = ValueNotifier('');

  /// Temporary world used for editing templates in the inspector.
  World? _templateEditingWorld;

  /// Temporary entity being edited for template creation/editing.
  Entity? _templateEditingEntity;

  /// ID of the template currently being edited.
  int? _editingTemplateId;

  @override
  get debugMode => false;

  /// The current <code>ECS</code> world instance being processed.
  late World currentWorld;
  late final ScrollDispatcher scrollDispatcher;

  MyGame(FocusNode gameFocusNode) {
    world = GameWorld(gameFocusNode);
    var systems = [
      BehaviorSystem(),
      CollisionSystem(),
      MovementSystem(),
      InventorySystem(),
      CombatSystem(),
    ];

    currentWorld = World(systems, {});
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
    currentWorld.tick();
    await WorldSaves.writeSave(currentWorld);
  }

  /// Starts creating a new template by showing a name dialog and setting up temp world.
  Future<void> startTemplateCreation(BuildContext context) async {
    // Show dialog to get template name
    final name = await _showTemplateNameDialog(context);
    if (name == null || name.trim().isEmpty) return;

    // Generate new ID
    final id = TemplateRegistry.instance.generateId();

    // Create temporary world and entity for editing
    _templateEditingWorld = World([], {});
    _templateEditingEntity = _templateEditingWorld!.add([]);
    _editingTemplateId = id;

    // Create empty template
    final template = EntityTemplate(
      id: id,
      displayName: name.trim(),
      components: [],
    );
    await TemplateRegistry.instance.save(template);

    // Set up auto-save listener
    _setupTemplateAutoSave();

    // Open inspector for editing
    selectedEntity.value = _templateEditingEntity;
    overlays.add('demoScreen');
  }

  /// Sets up a listener to auto-save template changes.
  void _setupTemplateAutoSave() {
    if (_templateEditingWorld == null || _templateEditingEntity == null || _editingTemplateId == null) {
      return;
    }

    // Listen to all component changes on the temp entity
    _templateEditingWorld!.onEntityChange(_templateEditingEntity!.id).listen((change) async {
      // Extract current components and save to template
      final template = EntityTemplate.fromEntity(
        id: _editingTemplateId!,
        displayName: TemplateRegistry.instance.getById(_editingTemplateId!)!.displayName,
        entity: _templateEditingEntity!,
      );

      await TemplateRegistry.instance.save(template);
    });
  }

  /// Shows a dialog to input a template name.
  Future<String?> _showTemplateNameDialog(BuildContext context) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Template'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Template Name',
            hintText: 'Enter a name for this template',
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

void main() async {
  initializeMappers();

  // Set up hierarchical logging
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

  // Initialize template registry
  await TemplateRegistry.instance.load();

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
  late FocusNode gameFocusNode;

  MyApp({super.key}) {
    gameFocusNode = FocusNode(debugLabel: 'game');
  }

  @override
  Widget build(BuildContext context) {
    final game = MyGame(gameFocusNode);
    var darkColorScheme = ColorScheme.dark();

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        dialogTheme: DialogThemeData(
          backgroundColor: darkColorScheme.surface,
          elevation: 6.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      // Root widget
      home: Scaffold(
        appBar: AppBar(
          title: ValueListenableBuilder<String>(
            valueListenable: game.hoveredEntityName,
            builder: (context, name, child) {
              return Text(name);
            },
          ),
          backgroundColor: darkColorScheme.surface,
          foregroundColor: darkColorScheme.onSurface,
          elevation: 2,
        ),
        drawer: NavigationDrawerContent(
          onEntityTemplatesPressed: () {
            game.overlays.add('templatePanel');
          },
        ),
        body: Stack(children: [
          GameWidget(
            focusNode: gameFocusNode,
            game: game,
            overlayBuilderMap: {
              // Inspector panel (right side)
              "demoScreen": (context, game) => Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 320,
                      child: InspectorOverlay(
                        entityNotifier: (game as MyGame).selectedEntity,
                      ),
                    ),
                  ),
              // Template panel (left side)
              "templatePanel": (context, game) => Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 320,
                      child: EntityTemplateOverlay(
                        selectedTemplateNotifier: (game as MyGame).selectedTemplate,
                        onCreateTemplate: () async {
                          await (game as MyGame).startTemplateCreation(context);
                        },
                        onClose: () {
                          game.overlays.remove('templatePanel');
                        },
                      ),
                    ),
                  ),
            },
          ),
        ]),
      ),
    );
  }
}
