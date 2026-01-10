import 'package:flame/components.dart' hide World;
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';


class FocusOnTapComponent extends PositionComponent with TapCallbacks {
  final FocusNode focusNode;
  final VoidCallback? onFocus;

  FocusOnTapComponent(this.focusNode, [this.onFocus]);

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onTapDown(TapDownEvent event) {
    event.continuePropagation = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    event.continuePropagation = true;

    // Always request focus when game area is tapped.
    // This ensures focus is taken from any open panels.
    focusNode.requestFocus();
    Logger("FocusOnTapComponent").info("requested focus");

    if (onFocus != null) {
      onFocus!();
    }
  }
}