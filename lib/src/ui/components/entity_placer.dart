import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import '../../ecs/ecs.barrel.dart' as ecs;

class EntityPlacer extends PositionComponent
    with DragCallbacks, TapCallbacks, ecs.Disposer {
  final ecs.World registry;
  final ecs.EntityTemplate archetype;

  Vector2? _dragStartScreen;
  ecs.LocalPosition? _dragStartGrid;
  ecs.LocalPosition? _dragUpdateGrid;
  bool _isShiftDown = false;
  bool _isCtrlDown = false;

  EntityPlacer({
    required this.registry,
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
    _isShiftDown = HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.shiftLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.shiftRight);
    _isCtrlDown = HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.controlLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.controlRight);

    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _dragUpdateGrid = _toGridPosition(event.localEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    process(_dragStartGrid, _dragUpdateGrid!);

    super.onDragEnd(event);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _dragStartScreen = event.localPosition;
    _dragStartGrid = _toGridPosition(_dragStartScreen!);
    _isShiftDown = HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.shiftLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.shiftRight);
  }

  @override
  void onTapUp(TapUpEvent event) {
    final endGrid = _toGridPosition(event.localPosition);
    final start = _dragStartGrid;

    process(start, endGrid);
  }

  void process(ecs.LocalPosition? start, ecs.LocalPosition endGrid) {
    if (start == null) return;

    final positions = <ecs.LocalPosition>[];

    if (_isShiftDown) {
      final minX = start.x < endGrid.x ? start.x : endGrid.x;
      final maxX = start.x > endGrid.x ? start.x : endGrid.x;
      final minY = start.y < endGrid.y ? start.y : endGrid.y;
      final maxY = start.y > endGrid.y ? start.y : endGrid.y;

      if (_isCtrlDown) {
        // Filled rectangle
        for (var x = minX; x <= maxX; x++) {
          for (var y = minY; y <= maxY; y++) {
            positions.add(ecs.LocalPosition(x: x, y: y));
          }
        }
      } else {
        // Border-only rectangle
        for (var x = minX; x <= maxX; x++) {
          positions.add(ecs.LocalPosition(x: x, y: minY)); // Top edge
          positions.add(ecs.LocalPosition(x: x, y: maxY)); // Bottom edge
        }
        for (var y = minY + 1; y < maxY; y++) {
          positions.add(ecs.LocalPosition(x: minX, y: y)); // Left edge
          positions.add(ecs.LocalPosition(x: maxX, y: y)); // Right edge
        }
      }
    } else {
      // constrain to straight line
      if ((endGrid.x - start.x).abs() > (endGrid.y - start.y).abs()) {
        for (var x = start.x;
            x != endGrid.x + (start.x < endGrid.x ? 1 : -1);
            x += (start.x < endGrid.x ? 1 : -1)) {
          positions.add(ecs.LocalPosition(x: x, y: start.y));
        }
      } else {
        for (var y = start.y;
            y != endGrid.y + (start.y < endGrid.y ? 1 : -1);
            y += (start.y < endGrid.y ? 1 : -1)) {
          positions.add(ecs.LocalPosition(x: start.x, y: y));
        }
      }
    }

    for (final pos in positions) {
      final matches = ecs.Query()
          .require<ecs.LocalPosition>((lp) => lp.x == pos.x && lp.y == pos.y)
          .require<ecs.BlocksMovement>()
          .find(registry)
          .toList();

      if (matches.isNotEmpty) {
        for (var m in matches) {
          m.destroy();
        }
      } else {
        var entity = archetype.build(registry);
        entity.upsert<ecs.LocalPosition>(pos);
      }
    }

    _dragStartGrid = null;
    _dragStartScreen = null;
    _isShiftDown = false;
  }

  ecs.LocalPosition _toGridPosition(Vector2 screenPosition) {
    return ecs.LocalPosition(
      x: (screenPosition.x / 32.0).floor(),
      y: (screenPosition.y / 32.0).floor(),
    );
  }
}
