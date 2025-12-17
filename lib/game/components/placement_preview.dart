import 'package:flame/components.dart' show PositionComponent, Vector2;
import 'package:flutter/material.dart' show Colors;
import 'package:rogueverse/ecs/components.dart' show LocalPosition;
import 'package:rogueverse/game/components/svg_component.dart' show SvgTileComponent;
import 'package:rogueverse/game/utils/grid_coordinates.dart' show GridCoordinates;

/// Component that manages preview visualization for entity placement.
///
/// Shows semi-transparent overlays at grid positions where entities will be
/// placed or removed, with color coding to indicate the operation type.
class PlacementPreview extends PositionComponent {
  /// The SVG asset path for the preview, or null if no preview available.
  final String? svgAssetPath;

  /// List of currently displayed preview components.
  final List<SvgTileComponent> _previewComponents = [];

  PlacementPreview({this.svgAssetPath});

  /// Updates the preview to show entities at the specified positions.
  ///
  /// Parameters:
  /// - [positions]: Grid positions where previews should appear
  /// - [isRemoval]: If true, shows red previews (removal), otherwise white (placement)
  ///
  /// Clears existing previews before creating new ones.
  void updatePreview(List<LocalPosition> positions, bool isRemoval) {
    // Can't show preview without an SVG asset
    if (svgAssetPath == null) return;

    // Clear existing previews first
    clearPreview();

    // Create new preview components at each position
    for (final pos in positions) {
      final preview = SvgTileComponent(
        svgAssetPath: svgAssetPath!,
        position: GridCoordinates.gridToScreen(pos),
        size: Vector2.all(GridCoordinates.TILE_SIZE),
      );

      // Set color: red for removal, white for placement
      if (isRemoval) {
        preview.paint.color = Colors.red.withValues(alpha: 0.5);
      } else {
        preview.paint.color = Colors.white.withValues(alpha: 0.5);
      }

      _previewComponents.add(preview);
      add(preview);
    }
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
