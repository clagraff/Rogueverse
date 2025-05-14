import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../mixins/scroll_callback.dart';
import '../../../main.dart';

class CameraControls extends PositionComponent
    with
        ScrollCallback,
        KeyboardHandler,
        DragCallbacks,
        HasGameReference<MyGame> {
  CameraControls() {
    // Set Very low priority, so other game component can receive (and potentially handle)
    // input events first.
    priority = -9999;
  }

  @override
  bool onScroll(PointerScrollInfo info) {
    final camera = game.camera;
    final viewfinder = camera.viewfinder;

    // Get world position under the cursor BEFORE zoom
    final worldBefore = camera.globalToLocal(info.eventPosition.global);

    // Zoom in or out
    final zoomChange = info.scrollDelta.global.y.sign * 0.1 * -1;
    viewfinder.zoom = (viewfinder.zoom + zoomChange).clamp(0.1, 4.0);

    // Get world position under the cursor AFTER zoom
    final worldAfter = camera.globalToLocal(info.eventPosition.global);

    // Compute the change and shift the camera to preserve cursor focus
    final shift = worldBefore - worldAfter;
    viewfinder.position += shift;

    return true;
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return true; // Always return true as this exists over the entire screen.
  }

  @override
  void onDragStart(DragStartEvent event) {
    // Stop propagation if event has not already been handled by this point.
    if (!event.handled) {
      super.onDragStart(event);
      event.continuePropagation = false;
    } else {
      event.continuePropagation = true;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Only move camera if the drag update event hasnt already been handled.
    if (!event.handled) {
      super.onDragUpdate(event);
      game.camera.moveBy(-event.localDelta);
      event.handled = true;
    }
  }
}
