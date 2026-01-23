import 'package:collection/collection.dart';
import 'package:flame/components.dart' hide World;
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/components.dart' hide Component;
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/components/camera_controller.dart';
import 'package:rogueverse/game/game_area.dart';

/// Finds the player entity and sets up the initial view, selection, and camera.
///
/// This component runs once during game initialization and then removes itself.
/// It handles:
/// - Finding the player entity (entity with Player component)
/// - Setting the viewed parent to the player's location
/// - Selecting the player entity
/// - Setting the player as the vision observer
/// - Creating and configuring the camera controller
class PlayerInitializer extends Component {
  static final _logger = Logger('PlayerInitializer');

  final World world;
  final ValueNotifier<Set<Entity>> selectedEntitiesNotifier;
  final ValueNotifier<int?> observerEntityIdNotifier;
  final ValueNotifier<int?> viewedParentIdNotifier;

  PlayerInitializer({
    required this.world,
    required this.selectedEntitiesNotifier,
    required this.observerEntityIdNotifier,
    required this.viewedParentIdNotifier,
  });

  @override
  Future<void> onLoad() async {
    final game = findGame() as GameArea;

    // Find the player entity by checking for the Player component.
    // TODO: In the future, consider checking if the player has a Controlling component
    // and select the controlled entity instead (e.g., when piloting a ship). Could also
    // persist the "currently controlled entity ID" in the save file.
    final playerEntity = world.entities().firstWhereOrNull(
          (e) => e.has<Player>(),
        );

    if (playerEntity != null) {
      // Set the view to the player's parent FIRST (room/location)
      // This must be done before setting selectedEntities/observerEntityId because
      // the viewedParentId listener clears those values when the view changes
      final playerParent = playerEntity.get<HasParent>();
      if (playerParent != null) {
        viewedParentIdNotifier.value = playerParent.parentEntityId;
      }
      // Now set the player as the selected/controlled entity
      selectedEntitiesNotifier.value = {playerEntity};
      // Set the player as the vision observer
      observerEntityIdNotifier.value = playerEntity.id;
      // Add camera controller that follows the selected entity (defaults to follow mode)
      final cameraController = CameraController(
        followedEntityNotifier: game.selectedEntity,
      );
      parent!.add(cameraController);
      game.cameraController = cameraController;
      _logger.info('auto-selected player entity', {'id': playerEntity.id});
    }

    // Initialization complete, remove self
    removeFromParent();
  }
}
