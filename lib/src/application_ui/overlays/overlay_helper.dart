import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void addOverlay({
  String? overlayName,
  required Game game,
  required BuildContext sourceContext,
  required Widget child,
}) {
  overlayName ??= child.runtimeType.toString();

  game.overlays.addEntry(overlayName, (context, _) {
    return Theme(
      data: Theme.of(sourceContext),
      child: Center(
        child: Material(
          type: MaterialType.transparency,
          child: child,
        ),
      ),
    );
  });

  game.overlays.toggle(overlayName);
}