import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Adds and displays an overlay widget to a Flame game.
///
/// Parameters:
/// - [overlayName]: Optional name for the overlay. If not provided, uses the child widget's type name
/// - [game]: The Flame game instance to add the overlay to
/// - [sourceContext]: Build context from the source widget to inherit theme data
/// - [child]: The widget to display as an overlay
///
/// Returns a function that can be called to toggle the overlay's visibility
Function() addOverlay({
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

  // Immediately show overlay.
  game.overlays.toggle(overlayName);

  // Return the toggle function so caller can hide or show the overlay
  return () {
    game.overlays.toggle(overlayName!);
  };
}