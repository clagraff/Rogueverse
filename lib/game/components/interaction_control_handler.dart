import 'package:flame/components.dart' hide World;
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/app/services/game_settings_service.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/app/widgets/overlays/interaction_context_menu.dart';
import 'package:rogueverse/ecs/components.dart' hide Component;
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/systems/vision_system.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/game/interaction/interaction_definition.dart';
import 'package:rogueverse/game/interaction/nearby_entity_finder.dart';
import 'package:rogueverse/game/utils/grid_coordinates.dart';

/// Handles interaction triggers (E key and right-click) and shows the context menu.
///
/// When triggered, this component:
/// 1. Finds nearby interactable entities
/// 2. Shows the context menu overlay
/// 3. Executes the selected interaction as an intent on the player entity
class InteractionControlHandler extends PositionComponent
    with KeyboardHandler, TapCallbacks, SecondaryTapCallbacks {
  final ValueNotifier<Entity?> selectedEntityNotifier;
  final World world;
  final _keybindings = KeyBindingService.instance;
  final _logger = Logger('InteractionControlHandler');

  /// Whether this handler is enabled. Disabled in editing mode.
  bool isEnabled = true;

  /// Current menu state for the overlay.
  final ValueNotifier<InteractionMenuState?> menuState = ValueNotifier(null);

  /// Currently highlighted entity (for visual feedback during menu navigation).
  final ValueNotifier<Entity?> highlightedEntity = ValueNotifier(null);

  InteractionControlHandler({
    required this.selectedEntityNotifier,
    required this.world,
  });

  /// Intercept tap events when enabled (gameplay mode).
  @override
  bool containsLocalPoint(Vector2 point) => isEnabled;

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!isEnabled || event is! KeyDownEvent) return true;

    // Check for interact keybinding (E key by default)
    if (_keybindings.matches('entity.interact', keysPressed)) {
      _showInteractionMenu(); // No position = appears near player
      return false;
    }

    return true;
  }

  @override
  void onSecondaryTapDown(SecondaryTapDownEvent event) {
    // Required to establish event chain for localPosition in onSecondaryTapUp
    if (!isEnabled) return;
    event.handled = true;
  }

  @override
  void onSecondaryTapUp(SecondaryTapUpEvent event) {
    if (!isEnabled) return;

    // Convert click position to grid coordinates to find clicked entity
    // Try localPosition first, fall back to canvasPosition if unavailable
    Vector2 clickPos;
    try {
      clickPos = event.localPosition;
    } catch (_) {
      // localPosition throws if no component chain - fall back to canvas
      clickPos = event.canvasPosition;
    }

    final gridPos = GridCoordinates.screenToGrid(clickPos);

    // Find entity at clicked position
    final clickedEntity = _findEntityAtPosition(gridPos.x, gridPos.y);

    // Show menu near player, filtered to clicked entity if found
    _showInteractionMenu(targetEntity: clickedEntity);

    // Mark event as handled so other components don't process it
    event.handled = true;
  }

  /// Finds an interactable entity at the given grid position.
  /// Only returns entities that are currently visible to the player.
  Entity? _findEntityAtPosition(int gridX, int gridY) {
    final playerEntity = selectedEntityNotifier.value;
    if (playerEntity == null) return null;

    final parentId = playerEntity.get<HasParent>()?.parentEntityId;
    final visibleEntities = playerEntity.get<VisibleEntities>();

    // Query entities at this position
    for (final entity in world.entities()) {
      final pos = entity.get<LocalPosition>();
      if (pos == null) continue;
      if (pos.x != gridX || pos.y != gridY) continue;

      // Check parent context matches
      final entityParent = entity.get<HasParent>()?.parentEntityId;
      if (parentId != entityParent) continue;

      // Skip the player entity itself
      if (entity.id == playerEntity.id) continue;

      // Only return if entity is currently visible
      if (visibleEntities != null && !visibleEntities.entityIds.contains(entity.id)) {
        continue;
      }

      return entity;
    }

    return null;
  }

  /// Shows the interaction menu for nearby entities and self-actions.
  ///
  /// [menuPosition] - Optional screen position for the menu. If not provided,
  /// the menu appears near the player sprite.
  /// [targetEntity] - Optional entity to filter interactions to. If provided,
  /// only interactions for this specific entity are shown (used for right-click).
  void _showInteractionMenu({Offset? menuPosition, Entity? targetEntity}) {
    final entity = selectedEntityNotifier.value;
    if (entity == null || !entity.has<LocalPosition>()) {
      _logger.fine('no entity selected or no position');
      return;
    }

    final pos = entity.get<LocalPosition>()!;
    final parentId = entity.get<HasParent>()?.parentEntityId;

    // Find all available interactions (target + self)
    final result = NearbyEntityFinder.findAllInteractions(
      world: world,
      origin: pos,
      parentId: parentId,
      playerEntity: entity,
    );

    // Filter to specific entity if provided (right-click context)
    var interactables = result.targetInteractions;
    if (targetEntity != null) {
      interactables = interactables
          .where((i) => i.entity.id == targetEntity.id)
          .toList();
    }

    // For right-click on specific entity, don't show menu if no interactions
    // For E key (no target), show menu if any interactions (including self-actions)
    final hasTargetInteractions = interactables.isNotEmpty;
    final hasSelfActions = result.selfActions.isNotEmpty;

    if (targetEntity != null && !hasTargetInteractions) {
      // Right-clicked on entity with no interactions available
      _logger.fine('no interactions available for clicked entity');
      return;
    }

    if (!hasTargetInteractions && !hasSelfActions) {
      _logger.fine('no interactions available');
      return;
    }

    // Calculate menu position if not provided
    final menuOffset = menuPosition ?? _getDefaultMenuPosition(pos);

    // Update menu state to show overlay
    // For right-click on specific entity, don't include self-actions
    menuState.value = InteractionMenuState(
      interactables: interactables,
      selfActions: targetEntity != null ? [] : result.selfActions,
      position: menuOffset,
    );

    // Show the overlay
    final game = findGame() as GameArea?;
    if (game != null) {
      game.overlays.add(InteractionContextMenu.overlayName);
    }
  }

  /// Gets the default menu position near the player sprite.
  Offset _getDefaultMenuPosition(LocalPosition pos) {
    final game = findGame() as GameArea?;
    if (game == null) {
      return Offset(pos.x * 32.0 + 40, pos.y * 32.0);
    }

    // Convert grid position to screen position via camera
    final worldPos = Vector2(pos.x * 32.0 + 40, pos.y * 32.0);
    final screenPos = game.camera.localToGlobal(worldPos);
    return Offset(screenPos.x, screenPos.y);
  }

  /// Executes an interaction by setting the intent on the player entity.
  ///
  /// For target interactions, [target] is the entity being interacted with.
  /// For self-actions, [target] should be the player entity itself (or null).
  /// [interactable] - Optional InteractableEntity with source info. If the entity
  /// is from memory (not currently visible), a macro is executed: turn → interact → turn back.
  void executeInteraction(
    Entity? target,
    InteractionDefinition interaction, {
    InteractableEntity? interactable,
  }) {
    final entity = selectedEntityNotifier.value;
    if (entity == null) {
      _logger.warning('no entity to execute interaction');
      return;
    }

    _logger.info('executing interaction', {
      'action': interaction.actionName,
      'isSelfAction': interaction.isSelfAction,
      'target': target?.id,
      'source': interactable?.source.name,
    });

    // Special handling for Talk interaction - open dialog directly without setting intent
    // This prevents a game tick from occurring when starting dialog
    if (interaction.actionName == 'Talk' && target != null) {
      dismissMenu();
      final game = findGame() as GameArea?;
      if (game?.dialogHandler != null) {
        game!.dialogHandler!.startDialog(target);
      }
      return;
    }

    // Check if this is a memory-based interaction requiring a macro
    if (target != null && interactable?.source == EntitySource.memory) {
      dismissMenu();
      _executeWithDirectionChange(target, interaction, interactable!);
      return;
    }

    // Create and set the intent
    // For self-actions, pass the player entity as the target
    final intent = interaction.createIntent(target ?? entity);
    entity.setIntent(intent);

    // Close the menu
    dismissMenu();
  }

  /// Executes an interaction with automatic direction changes for memory-based targets.
  /// Performs: turn to face → interact → turn back (up to 3 ticks total).
  void _executeWithDirectionChange(
    Entity target,
    InteractionDefinition interaction,
    InteractableEntity interactable,
  ) {
    final entity = selectedEntityNotifier.value;
    if (entity == null) return;

    final playerPos = entity.get<LocalPosition>();
    final targetPos = interactable.rememberedPosition;
    final originalDirection = entity.get<Direction>()?.facing;

    if (playerPos == null || targetPos == null) {
      _logger.warning('missing position for direction-change macro');
      return;
    }

    // Calculate direction to target
    final directionToTarget = _positionToDirection(playerPos, targetPos);

    _logger.fine('executing memory interaction macro', {
      'originalDirection': originalDirection?.name,
      'directionToTarget': directionToTarget.name,
    });

    // Step 1: Turn to face target (if not already facing)
    if (originalDirection != null && originalDirection != directionToTarget) {
      entity.setIntent(DirectionIntent(directionToTarget));
      entity.parentCell.tick();
    }

    // Step 2: Perform the interaction
    final intent = interaction.createIntent(target);
    entity.setIntent(intent);
    entity.parentCell.tick();

    // Force vision recalculation immediately after interaction
    // (VisionSystem is budgeted and would normally defer to next frame)
    // This ensures newly visible entities (e.g., behind opened door) are added to memory
    _forceVisionUpdate(entity);

    // Step 3: Turn back to original direction (only in lookBack mode)
    if (GameSettingsService.instance.interactionMacroMode ==
            InteractionMacroMode.lookBack &&
        originalDirection != null &&
        originalDirection != directionToTarget) {
      entity.setIntent(DirectionIntent(originalDirection));
      entity.parentCell.tick();

      // Force vision update again after turning back
      // This moves entities from VisibleEntities to VisionMemory
      _forceVisionUpdate(entity);
    }
  }

  /// Forces immediate vision recalculation for an entity.
  /// Needed because VisionSystem is budgeted and defers processing to next frame.
  void _forceVisionUpdate(Entity entity) {
    for (final system in entity.parentCell.systems) {
      if (system is VisionSystem) {
        system.updateVisionForObserver(entity.parentCell, entity.id);
        break;
      }
    }
  }

  /// Calculates the compass direction from one position to another.
  CompassDirection _positionToDirection(LocalPosition from, LocalPosition to) {
    final dx = (to.x - from.x).sign;
    final dy = (to.y - from.y).sign;

    return switch ((dx, dy)) {
      (0, -1) => CompassDirection.north,
      (0, 1) => CompassDirection.south,
      (1, 0) => CompassDirection.east,
      (-1, 0) => CompassDirection.west,
      (1, -1) => CompassDirection.northeast,
      (-1, -1) => CompassDirection.northwest,
      (1, 1) => CompassDirection.southeast,
      (-1, 1) => CompassDirection.southwest,
      _ => CompassDirection.north, // fallback for same position
    };
  }

  /// Executes a self-action (like Wait) on the player entity.
  void executeSelfAction(InteractionDefinition interaction) {
    executeInteraction(null, interaction);
  }

  /// Dismisses the interaction menu.
  void dismissMenu() {
    menuState.value = null;
    highlightedEntity.value = null;
    final game = findGame() as GameArea?;
    if (game != null) {
      game.overlays.remove(InteractionContextMenu.overlayName);
    }
  }

  /// Sets the currently highlighted entity (called from menu navigation).
  void setHighlightedEntity(Entity? entity) {
    highlightedEntity.value = entity;
  }
}

/// State for the interaction context menu.
class InteractionMenuState {
  /// Target interactions (on nearby entities).
  final List<InteractableEntity> interactables;

  /// Self-actions available to the player (e.g., Wait).
  final List<InteractionDefinition> selfActions;

  /// Screen position to display the menu.
  final Offset position;

  InteractionMenuState({
    required this.interactables,
    required this.selfActions,
    required this.position,
  });
}
