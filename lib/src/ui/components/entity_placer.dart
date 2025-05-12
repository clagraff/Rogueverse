import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:rogueverse/src/engine/ecs.dart' as esc;

class EntityPlacer extends PositionComponent with DragCallbacks, TapCallbacks, esc.Disposer {
  final esc.Chunk chunk;
  final esc.Archetype archetype;

  Vector2? _dragStartScreen;
  esc.LocalPosition? _dragStartGrid;
  esc.LocalPosition? _dragUpdateGrid;
  bool _isShiftDown = false;
  bool _isCtrlDown = false;

  EntityPlacer({
    required this.chunk,
    required this.archetype,
  });

  @override
  void onRemove() {
    disposeAll();
    super.onRemove();
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;


  @override
  void onDragStart(DragStartEvent event) {
    _dragStartScreen = event.localPosition;
    _dragStartGrid = _toGridPosition(_dragStartScreen!);
    _dragUpdateGrid = _toGridPosition(_dragStartScreen!);
    _isShiftDown = HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight);
    _isCtrlDown = HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight);
  }


  @override
  void onDragUpdate(DragUpdateEvent event) {
    _dragUpdateGrid = _toGridPosition(event.localEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    process(_dragStartGrid, _dragUpdateGrid!);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _dragStartScreen = event.localPosition;
    _dragStartGrid = _toGridPosition(_dragStartScreen!);
    _isShiftDown = HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight);
  }

  @override
  void onTapUp(TapUpEvent event) {
    final endGrid = _toGridPosition(event.localPosition);
    final start = _dragStartGrid;

    process(start, endGrid);
  }


  void process(esc.LocalPosition? start, esc.LocalPosition endGrid) {
    if (start == null) return;

    final positions = <esc.LocalPosition>[];

    if (_isShiftDown) {
      final minX = start.x < endGrid.x ? start.x : endGrid.x;
      final maxX = start.x > endGrid.x ? start.x : endGrid.x;
      final minY = start.y < endGrid.y ? start.y : endGrid.y;
      final maxY = start.y > endGrid.y ? start.y : endGrid.y;

      if (_isCtrlDown) {
        // Filled rectangle
        for (var x = minX; x <= maxX; x++) {
          for (var y = minY; y <= maxY; y++) {
            positions.add(esc.LocalPosition(x: x, y: y));
          }
        }
      } else {
        // Border-only rectangle
        for (var x = minX; x <= maxX; x++) {
          positions.add(esc.LocalPosition(x: x, y: minY)); // Top edge
          positions.add(esc.LocalPosition(x: x, y: maxY)); // Bottom edge
        }
        for (var y = minY + 1; y < maxY; y++) {
          positions.add(esc.LocalPosition(x: minX, y: y)); // Left edge
          positions.add(esc.LocalPosition(x: maxX, y: y)); // Right edge
        }
      }
    } else {
      // constrain to straight line
      if ((endGrid.x - start.x).abs() > (endGrid.y - start.y).abs()) {
        for (var x = start.x; x != endGrid.x + (start.x < endGrid.x ? 1 : -1); x += (start.x < endGrid.x ? 1 : -1)) {
          positions.add(esc.LocalPosition(x: x, y: start.y));
        }
      } else {
        for (var y = start.y; y != endGrid.y + (start.y < endGrid.y ? 1 : -1); y += (start.y < endGrid.y ? 1 : -1)) {
          positions.add(esc.LocalPosition(x: start.x, y: y));
        }
      }
    }

    for (final pos in positions) {
      final matches = esc.Query()
          .require<esc.LocalPosition>((lp) => lp.x == pos.x && lp.y == pos.y)
          .require<esc.BlocksMovement>()
          .find(chunk)
          .toList();

      if (matches.isNotEmpty) {
        for (var m in matches) {
          m.destroy();
        }
      } else {
        var entity = archetype.build(chunk);
        entity.set<esc.LocalPosition>(pos);
      }
    }

    _dragStartGrid = null;
    _dragStartScreen = null;
    _isShiftDown = false;
  }

  esc.LocalPosition _toGridPosition(Vector2 screenPosition) {
    return esc.LocalPosition(
      x: (screenPosition.x / 32.0).floor(),
      y: (screenPosition.y / 32.0).floor(),
    );
  }
}
