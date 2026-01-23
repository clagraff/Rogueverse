import 'package:flame/components.dart' hide World;
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/app/widgets/overlays/character_screen_overlay.dart';
import 'package:rogueverse/app/widgets/overlays/overlay_helper.dart';
import 'package:rogueverse/ecs/components.dart' hide Component;
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/game_area.dart';

/// Handles inventory controls (Tab to toggle inventory) for the currently selected entity.
///
/// This component listens to keyboard input and shows/hides the inventory overlay for
/// whichever entity is currently selected. It only processes controls when the selected
/// entity has an Inventory component.
class InventoryControlHandler extends PositionComponent with KeyboardHandler {
  final ValueNotifier<Entity?> selectedEntityNotifier;
  final World world;
  final _keybindings = KeyBindingService.instance;

  /// Whether this handler is enabled. Disabled in editing mode.
  bool isEnabled = true;

  Function()? _toggleInventoryOverlay;

  InventoryControlHandler({
    required this.selectedEntityNotifier,
    required this.world,
  });

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!isEnabled || event is! KeyDownEvent) return true;

    final entity = selectedEntityNotifier.value;
    if (entity == null || !entity.has<Inventory>()) {
      return true; // No entity selected or entity has no inventory
    }

    final game = (parent?.findGame() as GameArea);

    // Check for inventory toggle
    if (_keybindings.matches('inventory.toggle', keysPressed)) {
      _toggleInventory(entity, game);
      return false;
    }

    return true;
  }

  /// Toggles the inventory overlay for the given entity.
  void _toggleInventory(Entity entity, FlameGame game) {
    if (_toggleInventoryOverlay == null) {
      _showInventoryOverlay(entity, game);
    } else {
      _toggleInventoryOverlay!();
      _toggleInventoryOverlay = null;
    }
  }

  /// Shows the character screen overlay for the given entity.
  void _showInventoryOverlay(Entity entity, FlameGame game) {
    final sourceContext = game.buildContext!;
    final itemIds = entity.get<Inventory>()?.items ?? [];
    final items = itemIds.map((id) => world.getEntity(id)).toList();

    _toggleInventoryOverlay = addOverlay(
        game: game,
        sourceContext: sourceContext,
        child: CharacterScreenOverlay(
          inventory: items,
          onClose: () {
            // Call the toggle function to actually close the overlay,
            // then clear the reference.
            _toggleInventoryOverlay?.call();
            _toggleInventoryOverlay = null;
          },
        ));
  }
}
