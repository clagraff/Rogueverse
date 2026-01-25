import 'dart:ui' show Color;

import 'package:flame/components.dart' show PositionComponent, Vector2;
import 'package:flutter/material.dart' show Colors;

import 'package:rogueverse/ecs/components.dart' show LocalPosition, RenderableAsset, ImageAsset, TextAsset;
import 'package:rogueverse/game/components/svg_visual_component.dart' show SvgVisualComponent;
import 'package:rogueverse/game/components/text_visual_component.dart' show TextVisualComponent;
import 'package:rogueverse/game/components/visual_component.dart' show VisualComponent;
import 'package:rogueverse/game/utils/grid_coordinates.dart' show GridCoordinates;

/// Component that manages preview visualization for entity placement.
///
/// Shows semi-transparent overlays at grid positions where entities will be
/// placed or removed, with color coding to indicate the operation type.
/// Supports both image assets (SVG) and text assets.
class PlacementPreview extends PositionComponent {
  /// The asset to preview, or null if no preview available.
  final RenderableAsset? asset;

  /// List of currently displayed preview components.
  final List<VisualComponent> _previewComponents = [];

  /// Current rotation in degrees for direction-based placement.
  double _rotationDegrees = 0;

  PlacementPreview({this.asset});

  /// Legacy constructor for SVG path (used by removal mode).
  PlacementPreview.fromPath(String svgAssetPath) : asset = ImageAsset(svgAssetPath);

  /// Sets the rotation for all preview components.
  ///
  /// Used for direction-based placement where entities can be rotated
  /// before placing (e.g., doors facing different directions).
  void setRotation(double degrees) {
    _rotationDegrees = degrees;
    // Re-render any existing previews with new rotation
    if (_previewComponents.isNotEmpty) {
      // Store current positions and re-create previews
      // Note: This is a simple approach - we just clear and let next hover/drag recreate them
      clearPreview();
    }
  }

  /// Updates the preview to show entities at the specified positions.
  ///
  /// Parameters:
  /// - [positions]: Grid positions where previews should appear
  /// - [isRemoval]: If true, shows red previews (removal), otherwise white (placement)
  ///
  /// Clears existing previews before creating new ones.
  void updatePreview(List<LocalPosition> positions, bool isRemoval) {
    // Can't show preview without an asset
    if (asset == null) return;

    // Clear existing previews first
    clearPreview();

    // Create new preview components at each position
    for (final pos in positions) {
      final preview = _createPreviewComponent(pos, isRemoval);
      if (preview != null) {
        _previewComponents.add(preview);
        add(preview);
      }
    }
  }

  /// Creates a preview component based on the asset type.
  VisualComponent? _createPreviewComponent(LocalPosition pos, bool isRemoval) {
    final previewAsset = asset;
    if (previewAsset == null) return null;

    final position = GridCoordinates.gridToScreen(pos);
    final previewColor = isRemoval
        ? Colors.red.withValues(alpha: 0.5)
        : Colors.white.withValues(alpha: 0.5);

    return switch (previewAsset) {
      ImageAsset img => _createImagePreview(img, position, previewColor),
      TextAsset txt => _createTextPreview(txt, position, previewColor),
    };
  }

  /// Creates an SVG-based preview component.
  SvgVisualComponent _createImagePreview(ImageAsset img, Vector2 position, Color color) {
    // Use direction-based rotation if set, otherwise fall back to asset's rotation
    final effectiveRotation = _rotationDegrees != 0 ? _rotationDegrees : img.rotationDegrees;

    // Position at center of tile for proper rotation (VisualComponent uses Anchor.center)
    final centeredPosition = position + Vector2.all(GridCoordinates.tileSize / 2);

    final preview = SvgVisualComponent(
      svgAssetPath: img.svgAssetPath,
      position: centeredPosition,
      size: Vector2.all(GridCoordinates.tileSize),
      rotationDegrees: effectiveRotation,
    );
    preview.paint.color = color;
    return preview;
  }

  /// Creates a text-based preview component.
  TextVisualComponent _createTextPreview(TextAsset txt, Vector2 position, Color color) {
    // Offset position to center text in the tile
    final centeredPosition = position + Vector2.all(GridCoordinates.tileSize / 2);
    return TextVisualComponent(
      text: txt.text,
      fontSize: txt.fontSize,
      color: color,
      position: centeredPosition,
    );
  }

  /// Clears all preview components.
  ///
  /// Removes all preview components from the component tree and clears
  /// the internal list.
  void clearPreview() {
    for (final preview in _previewComponents) {
      preview.removeFromParent();
    }
    _previewComponents.clear();
  }

  @override
  void onRemove() {
    clearPreview();
    super.onRemove();
  }
}
