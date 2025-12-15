import 'package:flame/components.dart' hide World;
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity_template.dart';
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/ecs/world.dart';

/// A Flame component that handles placing entities from templates by clicking in the game world.
///
/// Supports multiple placement modes:
/// - Single click: Place one entity
/// - Click + drag: Place a line of entities
/// - Shift + drag: Place a hollow rectangle
/// - Ctrl + Shift + drag: Place a filled rectangle
///
/// When placing on a tile with an existing BlocksMovement entity, that entity is destroyed
/// and replaced with the new one (toggle behavior).
class TemplatePlacerComponent extends PositionComponent with DragCallbacks, TapCallbacks {
  final World world;
  final EntityTemplate template;
  final double tileSize;

  Vector2? _dragStartScreen;
  LocalPosition? _dragStartGrid;
  LocalPosition? _dragUpdateGrid;
  bool _isShiftDown = false;
  bool _isCtrlDown = false;

  final _logger = Logger('TemplatePlacerComponent');

  TemplatePlacerComponent({
    required this.world,
    required this.template,
    this.tileSize = 32.0,
  }) {
    _logger.info('TemplatePlacerComponent created for template: ${template.displayName}');
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onDragStart(DragStartEvent event) {
    _dragStartScreen = event.localPosition;
    _dragStartGrid = _toGridPosition(_dragStartScreen!);
    _dragUpdateGrid = _toGridPosition(_dragStartScreen!);
    _updateModifierKeys();

    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _dragUpdateGrid = _toGridPosition(event.localEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _processPlacement(_dragStartGrid, _dragUpdateGrid!);

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

  /// Calculates the list of positions to place entities based on placement mode.
  List<LocalPosition> _calculatePositions(LocalPosition start, LocalPosition end) {
    final positions = <LocalPosition>[];

    if (_isShiftDown) {
      // Rectangle mode (hollow or filled)
      final minX = start.x < end.x ? start.x : end.x;
      final maxX = start.x > end.x ? start.x : end.x;
      final minY = start.y < end.y ? start.y : end.y;
      final maxY = start.y > end.y ? start.y : end.y;

      if (_isCtrlDown) {
        // Filled rectangle
        for (var x = minX; x <= maxX; x++) {
          for (var y = minY; y <= maxY; y++) {
            positions.add(LocalPosition(x: x, y: y));
          }
        }
      } else {
        // Hollow rectangle (border only)
        for (var x = minX; x <= maxX; x++) {
          positions.add(LocalPosition(x: x, y: minY)); // Top edge
          positions.add(LocalPosition(x: x, y: maxY)); // Bottom edge
        }
        for (var y = minY + 1; y < maxY; y++) {
          positions.add(LocalPosition(x: minX, y: y)); // Left edge
          positions.add(LocalPosition(x: maxX, y: y)); // Right edge
        }
      }
    } else {
      // Line mode (constrained to straight lines)
      if ((end.x - start.x).abs() > (end.y - start.y).abs()) {
        // Horizontal line
        for (var x = start.x;
            x != end.x + (start.x < end.x ? 1 : -1);
            x += (start.x < end.x ? 1 : -1)) {
          positions.add(LocalPosition(x: x, y: start.y));
        }
      } else {
        // Vertical line
        for (var y = start.y;
            y != end.y + (start.y < end.y ? 1 : -1);
            y += (start.y < end.y ? 1 : -1)) {
          positions.add(LocalPosition(x: start.x, y: y));
        }
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

  /// Converts screen position to grid coordinates.
  LocalPosition _toGridPosition(Vector2 screenPosition) {
    return LocalPosition(
      x: (screenPosition.x / tileSize).floor(),
      y: (screenPosition.y / tileSize).floor(),
    );
  }
}
