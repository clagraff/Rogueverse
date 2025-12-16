import 'package:flame/components.dart' hide World;
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity_template.dart';
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/ui/components/svg_component.dart';

/// A Flame component that handles placing entities from templates by clicking in the game world.
///
/// Supports multiple placement modes:
/// - Single click: Place one entity
/// - Click + drag: Place a line of entities
/// - Ctrl + drag: Place a filled rectangle
/// - Ctrl + Shift + drag: Place a hollow rectangle
/// - ESC: Cancel current placement
///
/// Shows preview of where entities will be placed if template has a Renderable component.
///
/// When placing on a tile with an existing BlocksMovement entity, that entity is destroyed
/// and replaced with the new one (toggle behavior).
class TemplatePlacerComponent extends PositionComponent with DragCallbacks, TapCallbacks, KeyboardHandler, HoverCallbacks, PointerMoveCallbacks, SecondaryTapCallbacks {
  final World world;
  final EntityTemplate template;
  final double tileSize;

  Vector2? _dragStartScreen;
  LocalPosition? _dragStartGrid;
  LocalPosition? _dragUpdateGrid;
  LocalPosition? _currentHoverGrid;
  bool _isShiftDown = false;
  bool _isCtrlDown = false;

  // Right-click (removal) state
  LocalPosition? _rightDragStartGrid;
  LocalPosition? _rightDragUpdateGrid;

  // For rendering preview
  final List<SvgTileComponent> _previewComponents = [];
  String? _svgAssetPath;

  final _logger = Logger('TemplatePlacerComponent');

  TemplatePlacerComponent({
    required this.world,
    required this.template,
    this.tileSize = 32.0,
  }) {
    _logger.info('TemplatePlacerComponent created for template: ${template.displayName}');
    // Set high priority so this component receives events before camera controls
    priority = 100;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Get SVG path if template has a Renderable component
    final renderable = template.components.whereType<Renderable>().firstOrNull;
    if (renderable != null) {
      _svgAssetPath = renderable.svgAssetPath;
      _logger.info('Will use SVG for preview: $_svgAssetPath');
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onDragStart(DragStartEvent event) {
    _dragStartScreen = event.localPosition;
    _dragStartGrid = _toGridPosition(_dragStartScreen!);
    _dragUpdateGrid = _toGridPosition(_dragStartScreen!);
    _updateModifierKeys();

    // Mark event as handled so camera doesn't process it
    event.handled = true;
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _dragUpdateGrid = _toGridPosition(event.localEndPosition);
    _currentHoverGrid = _dragUpdateGrid;
    _updatePreview();
    // Mark event as handled so camera doesn't process it
    event.handled = true;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _processPlacement(_dragStartGrid, _dragUpdateGrid!);
    _clearPreview();

    // Mark event as handled so camera doesn't process it
    event.handled = true;
    super.onDragEnd(event);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _dragStartScreen = event.localPosition;
    _dragStartGrid = _toGridPosition(_dragStartScreen!);
    _updateModifierKeys();
    _logger.info('Tap down at grid position: (${_dragStartGrid!.x}, ${_dragStartGrid!.y})');
  }

  @override
  void onTapUp(TapUpEvent event) {
    final endGrid = _toGridPosition(event.localPosition);
    final start = _dragStartGrid;

    _logger.info('Tap up at grid position: (${endGrid.x}, ${endGrid.y})');
    _processPlacement(start, endGrid);
  }

  @override
  void onSecondaryTapDown(SecondaryTapDownEvent event) {
    _rightDragStartGrid = _toGridPosition(event.localPosition);
    _rightDragUpdateGrid = _rightDragStartGrid;
    _updateModifierKeys();
    _logger.info('Right tap down at grid position: (${_rightDragStartGrid!.x}, ${_rightDragStartGrid!.y})');
  }

  @override
  void onSecondaryTapUp(SecondaryTapUpEvent event) {
    final endGrid = _toGridPosition(event.localPosition);
    final start = _rightDragStartGrid;

    _logger.info('Right tap up at grid position: (${endGrid.x}, ${endGrid.y})');
    _processRemoval(start, endGrid);

    _rightDragStartGrid = null;
    _rightDragUpdateGrid = null;
  }

  @override
  void onSecondaryTapCancel(SecondaryTapCancelEvent event) {
    _rightDragStartGrid = null;
    _rightDragUpdateGrid = null;
  }

  @override
  void onHoverEnter() {
    // Component is being hovered
  }

  @override
  void onHoverExit() {
    _currentHoverGrid = null;
    _clearPreview();
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    // Update right-drag position if right button is down
    if (_rightDragStartGrid != null) {
      _rightDragUpdateGrid = _toGridPosition(event.localPosition);
      _updatePreview();
    }
    // Update hover position for preview when not dragging
    else if (_dragStartGrid == null) {
      _currentHoverGrid = _toGridPosition(event.localPosition);
      _updatePreview();
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Handle ESC to cancel current drag/preview
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      _logger.info('ESC pressed - cancelling placement/removal/preview');

      // Clear all state
      final hadState = _dragStartGrid != null ||
                       _rightDragStartGrid != null ||
                       _currentHoverGrid != null ||
                       _previewComponents.isNotEmpty;

      _dragStartGrid = null;
      _dragStartScreen = null;
      _dragUpdateGrid = null;
      _rightDragStartGrid = null;
      _rightDragUpdateGrid = null;
      _currentHoverGrid = null;
      _isShiftDown = false;
      _isCtrlDown = false;
      _clearPreview();

      if (hadState) {
        return true; // Event handled if we cleared something
      }
    }
    return false; // Event not handled
  }

  /// Updates preview components to show where entities will be placed/removed.
  void _updatePreview() {
    // Only show preview if we have an SVG path
    if (_svgAssetPath == null) return;

    // Calculate positions for preview
    final positions = <LocalPosition>[];
    bool isRemoval = false;

    if (_dragStartGrid != null && _dragUpdateGrid != null) {
      // During left-drag: show full preview of placement area
      positions.addAll(_calculatePositions(_dragStartGrid!, _dragUpdateGrid!));
    } else if (_rightDragStartGrid != null && _rightDragUpdateGrid != null) {
      // During right-drag: show preview of removal area
      positions.addAll(_calculatePositions(_rightDragStartGrid!, _rightDragUpdateGrid!));
      isRemoval = true;
    } else if (_currentHoverGrid != null) {
      // When hovering: show single preview at hover position
      positions.add(_currentHoverGrid!);
    }

    // Clear existing previews
    _clearPreview();

    // Create new preview components at each position
    for (final pos in positions) {
      final preview = SvgTileComponent(
        svgAssetPath: _svgAssetPath!,
        position: Vector2(pos.x * tileSize, pos.y * tileSize),
        size: Vector2.all(tileSize),
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
  void _clearPreview() {
    for (final preview in _previewComponents) {
      preview.removeFromParent();
    }
    _previewComponents.clear();
  }

  /// Updates the state of modifier keys (shift, ctrl).
  void _updateModifierKeys() {
    _isShiftDown = HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.shiftLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.shiftRight);
    _isCtrlDown = HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.controlLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.controlRight);
  }

  /// Processes entity placement based on start and end positions and modifier keys.
  void _processPlacement(LocalPosition? start, LocalPosition end) {
    if (start == null) {
      _logger.warning('processPlacement called with null start position');
      return;
    }

    _logger.info('Processing placement from (${start.x}, ${start.y}) to (${end.x}, ${end.y})');
    final positions = _calculatePositions(start, end);
    _logger.info('Calculated ${positions.length} positions to place');

    for (final pos in positions) {
      _placeOrToggleEntity(pos);
    }

    // Clear drag state
    _dragStartGrid = null;
    _dragStartScreen = null;
    _isShiftDown = false;
    _isCtrlDown = false;
  }

  /// Processes entity removal based on start and end positions and modifier keys.
  void _processRemoval(LocalPosition? start, LocalPosition end) {
    if (start == null) {
      _logger.warning('processRemoval called with null start position');
      return;
    }

    _logger.info('Processing removal from (${start.x}, ${start.y}) to (${end.x}, ${end.y})');
    final positions = _calculatePositions(start, end);
    _logger.info('Calculated ${positions.length} positions to remove');

    for (final pos in positions) {
      _removeEntity(pos);
    }

    // Clear drag state
    _isShiftDown = false;
    _isCtrlDown = false;
  }

  /// Calculates the list of positions to place entities based on placement mode.
  List<LocalPosition> _calculatePositions(LocalPosition start, LocalPosition end) {
    final positions = <LocalPosition>[];

    if (_isCtrlDown) {
      // Rectangle mode (hollow or filled)
      final minX = start.x < end.x ? start.x : end.x;
      final maxX = start.x > end.x ? start.x : end.x;
      final minY = start.y < end.y ? start.y : end.y;
      final maxY = start.y > end.y ? start.y : end.y;

      if (_isShiftDown) {
        // Hollow rectangle (border only)
        for (var x = minX; x <= maxX; x++) {
          positions.add(LocalPosition(x: x, y: minY)); // Top edge
          positions.add(LocalPosition(x: x, y: maxY)); // Bottom edge
        }
        for (var y = minY + 1; y < maxY; y++) {
          positions.add(LocalPosition(x: minX, y: y)); // Left edge
          positions.add(LocalPosition(x: maxX, y: y)); // Right edge
        }
      } else {
        // Filled rectangle
        for (var x = minX; x <= maxX; x++) {
          for (var y = minY; y <= maxY; y++) {
            positions.add(LocalPosition(x: x, y: y));
          }
        }
      }
    } else {
      // Line mode (supports diagonals using Bresenham's algorithm)
      positions.addAll(_bresenhamLine(start, end));
    }

    return positions;
  }

  /// Calculates line positions using Bresenham's line algorithm (supports diagonals).
  List<LocalPosition> _bresenhamLine(LocalPosition start, LocalPosition end) {
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

  /// Places an entity at the given position, or removes existing BlocksMovement entity (toggle).
  void _placeOrToggleEntity(LocalPosition pos) {
    _logger.info('Placing/toggling entity at (${pos.x}, ${pos.y})');

    // Check if there's already an entity with BlocksMovement at this position
    final matches = Query()
        .require<LocalPosition>((lp) => lp.x == pos.x && lp.y == pos.y)
        .require<BlocksMovement>()
        .find(world)
        .toList();

    if (matches.isNotEmpty) {
      // Remove existing blocking entities
      _logger.info('Found ${matches.length} existing entities at position, removing them');
      for (var entity in matches) {
        entity.destroy();
      }
    } else {
      // Place new entity from template
      _logger.info('Placing new entity from template: ${template.displayName}');
      _logger.info('Template has ${template.components.length} components');
      final entity = template.build(world, baseComponents: [pos]);
      _logger.info('Created entity with ID: ${entity.id}');

      // Log all components on the new entity
      final componentTypes = world.components.keys.toList();
      _logger.info('Available component types in world: $componentTypes');

      for (var componentType in componentTypes) {
        final componentMap = world.components[componentType];
        if (componentMap != null && componentMap.containsKey(entity.id)) {
          _logger.info('Entity ${entity.id} has component: $componentType');
        }
      }
    }
  }

  /// Removes entities at the given position (entities with BlocksMovement).
  void _removeEntity(LocalPosition pos) {
    _logger.info('Removing entity at (${pos.x}, ${pos.y})');

    // Find entities with BlocksMovement at this position
    final matches = Query()
        .require<LocalPosition>((lp) => lp.x == pos.x && lp.y == pos.y)
        .require<BlocksMovement>()
        .find(world)
        .toList();

    if (matches.isNotEmpty) {
      _logger.info('Found ${matches.length} entities at position, removing them');
      for (var entity in matches) {
        entity.destroy();
      }
    } else {
      _logger.info('No entities to remove at this position');
    }
  }

  /// Converts screen position to grid coordinates.
  LocalPosition _toGridPosition(Vector2 screenPosition) {
    return LocalPosition(
      x: (screenPosition.x / tileSize).floor(),
      y: (screenPosition.y / tileSize).floor(),
    );
  }
}
