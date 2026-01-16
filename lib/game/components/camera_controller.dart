import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/game/utils/grid_coordinates.dart';

/// Camera modes for the CameraController.
enum CameraMode {
  /// Camera automatically follows the player entity.
  follow,

  /// Camera is freely controlled by the user.
  free,
}

/// Controls camera behavior, supporting both player-following and free-form modes.
///
/// In follow mode, the camera automatically centers on the followed entity and
/// adjusts when the viewport resizes. In free mode, the user has full manual
/// control via panning and zooming.
///
/// Use Ctrl+F to toggle between modes. Manual camera movement (panning)
/// automatically switches from follow to free mode. Zooming in follow mode
/// stays centered on the followed entity.
class CameraController extends PositionComponent with KeyboardHandler {
  /// The entity to follow. Can be changed at runtime via the ValueNotifier.
  final ValueNotifier<Entity?> followedEntityNotifier;
  final _keybindings = KeyBindingService.instance;

  CameraMode _mode = CameraMode.follow;
  Vector2? _lastViewportSize;

  /// How quickly the camera follows the entity (higher = faster, 1.0 = instant).
  static const double _followSpeed = 8.0;

  /// The current camera mode.
  CameraMode get mode => _mode;

  /// The currently followed entity.
  Entity? get followedEntity => followedEntityNotifier.value;

  CameraController({required this.followedEntityNotifier});

  @override
  void update(double dt) {
    super.update(dt);

    if (_mode != CameraMode.follow || followedEntity == null) return;

    final game = parent?.findGame() as GameArea?;
    if (game == null) return;

    final currentViewportSize = game.camera.viewport.size;

    // Check for viewport size changes - snap immediately on resize
    final viewportChanged = _lastViewportSize == null ||
        currentViewportSize.x != _lastViewportSize!.x ||
        currentViewportSize.y != _lastViewportSize!.y;

    if (viewportChanged) {
      _centerOnFollowedEntity();
      _lastViewportSize = currentViewportSize.clone();
    } else {
      // Smoothly lerp towards followed entity position
      _smoothFollowEntity(game, dt);
    }
  }

  /// Returns the world position of the followed entity's tile center,
  /// or null if no entity is being followed or it has no position.
  Vector2? getFollowedEntityWorldCenter() {
    final entityPosition = followedEntity?.get<LocalPosition>();
    if (entityPosition == null) return null;

    return GridCoordinates.gridToScreen(entityPosition) +
        Vector2.all(GridCoordinates.tileSize / 2);
  }

  /// Smoothly moves the camera towards the followed entity's position.
  void _smoothFollowEntity(GameArea game, double dt) {
    final targetCenter = getFollowedEntityWorldCenter();
    if (targetCenter == null) return;

    // Convert viewport size from screen pixels to world units
    final viewportWorldSize = game.camera.viewport.size / game.camera.viewfinder.zoom;
    final targetCameraPos = targetCenter - viewportWorldSize / 2;

    final currentPos = game.camera.viewfinder.position;

    // Lerp factor based on dt for frame-rate independent smoothing
    final lerpFactor = (1.0 - (1.0 / (1.0 + _followSpeed * dt))).clamp(0.0, 1.0);

    game.camera.viewfinder.position = Vector2(
      currentPos.x + (targetCameraPos.x - currentPos.x) * lerpFactor,
      currentPos.y + (targetCameraPos.y - currentPos.y) * lerpFactor,
    );
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) return true;

    if (_keybindings.matches('camera.toggleFollow', keysPressed)) {
      toggleMode();
      return false;
    }

    return true;
  }

  /// Toggles between follow and free camera modes.
  void toggleMode() {
    if (_mode == CameraMode.follow) {
      _mode = CameraMode.free;
      // No toast for switching to free mode
    } else {
      _mode = CameraMode.follow;
      _centerOnFollowedEntity();
      // Show toast when starting to follow
      _showToast('Camera following player');
    }
  }

  /// Called when the user manually moves the camera (pan).
  /// Automatically switches to free mode if currently following.
  void onManualCameraMove() {
    if (_mode == CameraMode.follow) {
      _mode = CameraMode.free;
      // No toast for automatic switch to free mode
    }
  }

  /// Centers the camera on the followed entity's current tile.
  void _centerOnFollowedEntity() {
    final game = parent?.findGame() as GameArea?;
    final tileCenter = getFollowedEntityWorldCenter();
    if (game == null || tileCenter == null) return;

    // Convert viewport size from screen pixels to world units
    final viewportWorldSize = game.camera.viewport.size / game.camera.viewfinder.zoom;
    game.camera.viewfinder.position = tileCenter - viewportWorldSize / 2;
    _lastViewportSize = game.camera.viewport.size.clone();
  }

  /// Shows a toast message via the GameArea's toast notifier.
  void _showToast(String message) {
    final game = parent?.findGame() as GameArea?;
    game?.showToast(message);
  }
}
