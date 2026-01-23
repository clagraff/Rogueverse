import 'package:flame/components.dart' hide World;
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/components/dialog_control_handler.dart';
import 'package:rogueverse/game/components/editor_control_handler.dart';
import 'package:rogueverse/game/components/global_control_handler.dart';
import 'package:rogueverse/game/components/interaction_control_handler.dart';
import 'package:rogueverse/game/components/interaction_highlight.dart';
import 'package:rogueverse/game/components/inventory_control_handler.dart';
import 'package:rogueverse/game/components/positional_control_handler.dart';
import 'package:rogueverse/game/components/game_mode_toggle.dart';
import 'package:rogueverse/game/game_area.dart';

/// Coordinates all control handlers and manages switching between game modes.
///
/// Responsibilities:
/// - Creates and manages all control handler components
/// - Listens to game mode changes and enables/disables appropriate handlers
/// - Exposes handler references for GameArea access (interaction, dialog)
class ControlHandlerCoordinator extends Component {
  static final _logger = Logger('ControlHandlerCoordinator');

  final ValueNotifier<Set<Entity>> selectedEntitiesNotifier;
  final ValueNotifier<Entity?> selectedEntityNotifier;
  final ValueNotifier<int?> viewedParentIdNotifier;
  final ValueNotifier<GameMode> gameModeNotifier;
  final World world;

  // Handler references (publicly accessible for GameArea)
  late PositionalControlHandler positionalHandler;
  late GlobalControlHandler globalHandler;
  late InventoryControlHandler inventoryHandler;
  late InteractionControlHandler interactionHandler;
  late DialogControlHandler dialogHandler;
  late EditorControlHandler editorHandler;

  ControlHandlerCoordinator({
    required this.selectedEntitiesNotifier,
    required this.selectedEntityNotifier,
    required this.viewedParentIdNotifier,
    required this.gameModeNotifier,
    required this.world,
  });

  @override
  Future<void> onLoad() async {
    final game = findGame() as GameArea;

    // Create positional control handler (WASD/arrows movement)
    positionalHandler = PositionalControlHandler(
      selectedEntityNotifier: selectedEntityNotifier,
      world: world,
    );
    parent!.add(positionalHandler);

    // Create inventory control handler
    inventoryHandler = InventoryControlHandler(
      selectedEntityNotifier: selectedEntityNotifier,
      world: world,
    );
    parent!.add(inventoryHandler);

    // Create interaction control handler (E key for interactions)
    interactionHandler = InteractionControlHandler(
      selectedEntityNotifier: selectedEntityNotifier,
      world: world,
    );
    parent!.add(interactionHandler);
    // Store reference in GameArea for overlay access
    game.interactionHandler = interactionHandler;

    // Add interaction highlight circle (shows target during menu navigation)
    parent!.add(InteractionHighlight(
      highlightedEntityNotifier: interactionHandler.highlightedEntity,
    ));

    // Create dialog control handler
    dialogHandler = DialogControlHandler(
      selectedEntityNotifier: selectedEntityNotifier,
      world: world,
    );
    parent!.add(dialogHandler);
    // Store reference in GameArea for overlay access
    game.dialogHandler = dialogHandler;

    // Create global control handler
    globalHandler = GlobalControlHandler(selectedEntityNotifier: selectedEntitiesNotifier);
    parent!.add(globalHandler);

    // Create editor control handler (DEL to delete, etc.) - enabled in editing mode
    editorHandler = EditorControlHandler(
      selectedEntitiesNotifier: selectedEntitiesNotifier,
      viewedParentIdNotifier: viewedParentIdNotifier,
    );
    parent!.add(editorHandler);

    // Add game mode toggle (Ctrl+` to switch between gameplay and editing)
    parent!.add(GameModeToggle());

    // Listen to game mode changes and update handler enabled states
    gameModeNotifier.addListener(_onGameModeChanged);
  }

  void _onGameModeChanged() {
    final isGameplay = gameModeNotifier.value == GameMode.gameplay;
    // Gameplay mode handlers
    positionalHandler.isEnabled = isGameplay;
    globalHandler.isEnabled = isGameplay;
    inventoryHandler.isEnabled = isGameplay;
    interactionHandler.isEnabled = isGameplay;
    dialogHandler.isEnabled = isGameplay;
    // Editing mode handlers
    editorHandler.isEnabled = !isGameplay;
    _logger.info('game mode changed', {'mode': gameModeNotifier.value.name});
  }

  @override
  void onRemove() {
    gameModeNotifier.removeListener(_onGameModeChanged);
  }
}
