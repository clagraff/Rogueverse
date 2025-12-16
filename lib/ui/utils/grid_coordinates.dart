import 'package:flame/components.dart' show Vector2;
import 'package:rogueverse/ecs/components.dart' show LocalPosition;

/// Utility class for converting between screen coordinates and grid coordinates.
///
/// Centralizes grid conversion logic to eliminate duplication across components.
class GridCoordinates {
  /// The size of each tile in pixels.
  static const double TILE_SIZE = 32.0;

  /// Converts screen coordinates to grid coordinates.
  ///
  /// Takes a [screen] position in pixels and returns the corresponding
  /// grid position, using floor division to snap to grid cells.
  static LocalPosition screenToGrid(Vector2 screen) {
    return LocalPosition(
      x: (screen.x / TILE_SIZE).floor(),
      y: (screen.y / TILE_SIZE).floor(),
    );
  }

  /// Converts grid coordinates to screen coordinates.
  ///
  /// Takes a [grid] position and returns the corresponding pixel position
  /// at the top-left corner of that grid cell.
  static Vector2 gridToScreen(LocalPosition grid) {
    return Vector2(grid.x * TILE_SIZE, grid.y * TILE_SIZE);
  }
}
