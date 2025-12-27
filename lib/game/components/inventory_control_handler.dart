import 'package:flame/components.dart' hide World;
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:rogueverse/app/widgets/overlays/overlay_helper.dart';
import 'package:rogueverse/app/widgets/overlays/player_inventory_widget.dart';
import 'package:rogueverse/ecs/components.dart' hide Component;
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/game/utils/input_service.dart';

/// Handles inventory controls (Tab to toggle inventory) for the currently selected entity.
///
/// This component listens to keyboard input and shows/hides the inventory overlay for
/// whichever entity is currently selected. It only processes controls when the selected
/// entity has an Inventory component.
class InventoryControlHandler extends PositionComponent with KeyboardHandler {
  final ValueNotifier<Entity?> selectedEntityNotifier;
  final World world;

  Function()? _toggleInventoryOverlay;

  InventoryControlHandler({
    required this.selectedEntityNotifier,
    required this.world,
  });

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) return true;

    final entity = selectedEntityNotifier.value;
    if (entity == null || !entity.has<Inventory>()) {
      return true; // No entity selected or entity has no inventory
    }

    final game = (parent?.findGame() as GameArea);

    // Check for inventory controls
    final action = inventoryControls.resolve(keysPressed, event.logicalKey);
    if (action != null) {
      _handleInventoryAction(action, entity, game);
      return false;
    }

    return true;
  }

  /// Handles inventory action input (showing/hiding inventory overlay).
  void _handleInventoryAction(
      InventoryAction action, Entity entity, FlameGame game) {
    switch (action) {
      case InventoryAction.toggleInventory:
        if (_toggleInventoryOverlay == null) {
          _showInventoryOverlay(entity, game);
        } else {
          _toggleInventoryOverlay!();
          _toggleInventoryOverlay = null;
        }
        break;
    }
  }

  /// Shows the inventory overlay for the given entity.
  void _showInventoryOverlay(Entity entity, FlameGame game) {
    final sourceContext = game.buildContext!;
    final itemIds = entity.get<Inventory>()?.items ?? [];
    final items = itemIds.map((id) => world.getEntity(id)).toList();

    _toggleInventoryOverlay = addOverlay(
        game: game,
        sourceContext: sourceContext,
        child: PlayerInventoryWidget(
          game: game,
          inventory: items,
          onClose: () {
            // Don't need to manually call _toggleInventoryOverlay() as it will
            // already be closed when this onClose callback executes. Just clear
            // out the callback.
            _toggleInventoryOverlay = null;
          },
        ));
  }
}
