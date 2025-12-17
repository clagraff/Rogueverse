import 'dart:async';

import 'package:flame/components.dart' hide World;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/entity_template.dart';
import 'package:rogueverse/ecs/systems.dart';
import 'package:rogueverse/ecs/template_registry.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/app/screens/game_screen.dart';
import 'package:rogueverse/game/hud/camera_controls.dart';
import 'package:rogueverse/game/mixins/scroll_callback.dart';

/// The main game area component that manages the ECS world, camera controls,
/// and entity/template selection for the game editor.
class GameArea extends FlameGame
    with HasKeyboardHandlerComponents, ScrollDetector {
  /// The currently selected entity for inspection/editing in the inspector panel.
  final ValueNotifier<Entity?> selectedEntity = ValueNotifier(null);

  /// The currently selected entity template in the template panel.
  final ValueNotifier<EntityTemplate?> selectedTemplate = ValueNotifier(null);

  /// The current title displayed in the app bar.
  final ValueNotifier<String> title = ValueNotifier('');

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

  /// Used for dispatching scroll-related events, before otherwise controlling the camera.
  late final ScrollDispatcher scrollDispatcher;

  /// Creates a new game area with the specified focus node for keyboard input.
  ///
  /// Initializes the game world, ECS systems, and sets up the core game state.
  ///
  /// [gameFocusNode] - The focus node used to capture keyboard input for the game.
  GameArea(FocusNode gameFocusNode) {
    world = GameScreen(gameFocusNode);
    var systems = [
      BehaviorSystem(),
      CollisionSystem(),
      MovementSystem(),
      InventorySystem(),
      CombatSystem(),
    ];

    currentWorld = World(systems, {});
  }

  /// Initializes the game area by setting up the camera anchor, camera controls,
  /// and scroll dispatcher for handling scroll events.
  @override
  FutureOr<void> onLoad() {
    camera.viewfinder.anchor = Anchor.topLeft;

    // CameraControls could potentially conflict with other in-game controls. To
    // help alleviate this, we'll add CameraControls to the world, not the viewfinder, so it's in the same
    // component hierarchy and can be more easily worked around.
    world.add(CameraControls());

    // Setup the ScrollDispatcher so other components can use `ScrollCallback`.
    scrollDispatcher = ScrollDispatcher();
    add(scrollDispatcher);

    return super.onLoad();
  }

  /// Handles scroll events by delegating to the scroll dispatcher first,
  /// then zooming the camera if the event is not handled.
  ///
  /// The zoom level is clamped between 0.1 and 3.0.
  @override
  void onScroll(PointerScrollInfo info) {
    final handled = scrollDispatcher.dispatch(info);

    // If not handled (eg, by a component or something), then assume we are trying
    // to zoom in/out the camera.
    if (!handled) {
      camera.viewfinder.zoom += info.scrollDelta.global.y.sign * 0.02;
      camera.viewfinder.zoom = camera.viewfinder.zoom.clamp(0.1, 3.0);
    }
  }

  /// Processes one tick of the ECS world and saves the current world state.
  ///
  /// This should be called each game update to advance all systems and persist changes.
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
    overlays.add('inspector');
  }

  /// Sets up a listener to auto-save template changes.
  void _setupTemplateAutoSave() {
    if (_templateEditingWorld == null ||
        _templateEditingEntity == null ||
        _editingTemplateId == null) {
      return;
    }

    // Listen to all component changes on the temp entity
    _templateEditingWorld!
        .onEntityChange(_templateEditingEntity!.id)
        .listen((change) async {
      // Extract current components and save to template
      final template = EntityTemplate.fromEntity(
        id: _editingTemplateId!,
        displayName:
            TemplateRegistry.instance.getById(_editingTemplateId!)!.displayName,
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