import 'package:flame/components.dart' hide World;
import 'package:flame/effects.dart' show OpacityEffect, EffectController;
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/components/svg_component.dart' show SvgTileComponent;


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
    var hasFocus = focusNode.hasFocus;

    if (!hasFocus) {
      focusNode.requestFocus();
      Logger("FocusOnTapComponent").info("requested focus");

      if (onFocus != null) {
       onFocus!();
      }
    }
  }
}