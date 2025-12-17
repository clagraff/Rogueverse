import 'package:rogueverse/ecs/components.dart' show LocalPosition;

/// Defines the different placement modes for entity placement.
enum PlacementMode {
  /// Line mode - draws a line from start to end (supports diagonals via Bresenham's algorithm).
  line,

  /// Filled rectangle mode - fills the entire rectangle between start and end.
  rectangle,

  /// Hollow rectangle mode - only the border of the rectangle.
  hollowRectangle,
}

/// Utility class for calculating placement positions based on different modes.
///
/// Centralizes shape calculation logic to eliminate duplication and make
/// it easy to add new placement modes.
class PlacementStrategy {
  /// Calculates the list of grid positions based on the placement [mode].
  ///
  /// Parameters:
  /// - [start]: Starting grid position
  /// - [end]: Ending grid position
  /// - [mode]: PlacementMode determining the shape
  ///
  /// Returns a list of [LocalPosition] objects representing grid cells to fill.
  static List<LocalPosition> calculate({
    required LocalPosition start,
    required LocalPosition end,
    required PlacementMode mode,
  }) {
    switch (mode) {
      case PlacementMode.line:
        return _bresenhamLine(start, end);
      case PlacementMode.rectangle:
        return _filledRectangle(start, end);
      case PlacementMode.hollowRectangle:
        return _hollowRectangle(start, end);
    }
  }

  /// Calculates line positions using Bresenham's line algorithm (supports diagonals).
  ///
  /// Bresenham's algorithm efficiently calculates which grid cells a line
  /// should pass through, supporting lines at any angle.
  static List<LocalPosition> _bresenhamLine(LocalPosition start, LocalPosition end) {
    final positions = <LocalPosition>[];

    int x0 = start.x;
    int y0 = start.y;
    int x1 = end.x;
    int y1 = end.y;

    final dx = (x1 - x0).abs();
    final dy = (y1 - y0).abs();
    final sx = x0 < x1 ? 1 : -1;
    final sy = y0 < y1 ? 1 : -1;
    var err = dx - dy;

    while (true) {
      positions.add(LocalPosition(x: x0, y: y0));

      if (x0 == x1 && y0 == y1) break;

      final e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x0 += sx;
      }
      if (e2 < dx) {
        err += dx;
        y0 += sy;
      }
    }

    return positions;
  }

  /// Calculates all positions within a filled rectangle.
  ///
  /// Returns all grid cells within the rectangle defined by [start] and [end].
  static List<LocalPosition> _filledRectangle(LocalPosition start, LocalPosition end) {
    final positions = <LocalPosition>[];

    final minX = start.x < end.x ? start.x : end.x;
    final maxX = start.x > end.x ? start.x : end.x;
    final minY = start.y < end.y ? start.y : end.y;
    final maxY = start.y > end.y ? start.y : end.y;

    for (var x = minX; x <= maxX; x++) {
      for (var y = minY; y <= maxY; y++) {
        positions.add(LocalPosition(x: x, y: y));
      }
    }

    return positions;
  }

  /// Calculates positions for a hollow rectangle (border only).
  ///
  /// Returns only the perimeter grid cells of the rectangle defined by
  /// [start] and [end], leaving the interior empty.
  static List<LocalPosition> _hollowRectangle(LocalPosition start, LocalPosition end) {
    final positions = <LocalPosition>[];

    final minX = start.x < end.x ? start.x : end.x;
    final maxX = start.x > end.x ? start.x : end.x;
    final minY = start.y < end.y ? start.y : end.y;
    final maxY = start.y > end.y ? start.y : end.y;

    // Top and bottom edges
    for (var x = minX; x <= maxX; x++) {
      positions.add(LocalPosition(x: x, y: minY)); // Top edge
      positions.add(LocalPosition(x: x, y: maxY)); // Bottom edge
    }

    // Left and right edges (excluding corners already added)
    for (var y = minY + 1; y < maxY; y++) {
      positions.add(LocalPosition(x: minX, y: y)); // Left edge
      positions.add(LocalPosition(x: maxX, y: y)); // Right edge
    }

    return positions;
  }
}
