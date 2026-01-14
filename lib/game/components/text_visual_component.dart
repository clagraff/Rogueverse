import 'dart:ui' show Color;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextStyle;

import 'package:rogueverse/game/components/visual_component.dart';

/// Visual component for rendering text in the game world.
/// Text is centered at the component's position.
/// Follows the same visibility rules as image assets (opacity controlled by Agent).
class TextVisualComponent extends VisualComponent {
  final String text;
  final double fontSize;
  final Color color;

  late TextComponent _textComponent;
  double _currentOpacity = 1.0;

  TextVisualComponent({
    required this.text,
    required this.fontSize,
    required this.color,
    super.position,
    super.size,
  }) {
    // Center the component at its position
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _textComponent = TextComponent(
      text: text,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: fontSize,
          color: color.withValues(alpha: _currentOpacity),
        ),
      ),
    );

    add(_textComponent);
  }

  /// Override opacity to update text color when visibility changes.
  @override
  set opacity(double value) {
    super.opacity = value;
    _currentOpacity = value;
    _updateTextOpacity();
  }

  @override
  double get opacity => _currentOpacity;

  /// Updates the text renderer with the current opacity.
  void _updateTextOpacity() {
    if (!isMounted) return;
    _textComponent.textRenderer = TextPaint(
      style: TextStyle(
        fontSize: fontSize,
        color: color.withValues(alpha: _currentOpacity),
      ),
    );
  }
}
