import 'dart:ui' show Offset, Paint, PaintingStyle, Rect;

import 'package:flame/components.dart' show PositionComponent, RectangleComponent, Vector2;
import 'package:flame/events.dart' show DragCallbacks, DragStartEvent, DragUpdateEvent, DragEndEvent;
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart' show FocusNode;

/// A reusable drag-select component that draws a selection rectangle during drag
/// and reports the final selection area.
///
/// Enable/disable via [isEnabled] to control when drag-select is active.
/// Commonly disabled during gameplay mode and enabled during editing mode.
///
/// When a drag completes, [onSelectionComplete] is called with the selection [Rect].
class DragSelectComponent extends PositionComponent with DragCallbacks {
  /// Whether this component intercepts drag events.
  bool isEnabled = true;

  /// Called when drag ends with a valid selection rectangle.
  /// The rect is in screen coordinates (not grid coordinates).
  final void Function(Rect selectionRect)? onSelectionComplete;

  /// Optional focus node to request focus after drag completes.
  final FocusNode? focusNode;

  Vector2? _dragStart;
  Vector2? _dragEnd;
  RectangleComponent? _selectionRect;

  DragSelectComponent({
    this.onSelectionComplete,
    this.focusNode,
    this.isEnabled = true,
  }) {
    // Lower priority than EntityDragMover (99) and TemplateEntitySpawner (100)
    // so those can intercept first if needed
    priority = 98;
  }

  @override
  bool containsLocalPoint(Vector2 point) => isEnabled;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!isEnabled) return;

    _dragStart = event.localPosition.clone();
    _dragEnd = _dragStart!.clone();

    // Create the selection rectangle visual
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    _selectionRect = RectangleComponent(
      position: _dragStart!,
      size: Vector2.zero(),
      paint: paint,
    );
    add(_selectionRect!);

    event.handled = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_dragStart == null || _selectionRect == null) return;

    _dragEnd = event.localEndPosition.clone();
    _updateSelectionRect();

    event.handled = true;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    if (_dragStart != null && _dragEnd != null && onSelectionComplete != null) {
      // Create rect from the two corners (handles any drag direction)
      final rect = Rect.fromPoints(
        Offset(_dragStart!.x, _dragStart!.y),
        Offset(_dragEnd!.x, _dragEnd!.y),
      );
      // Only trigger if there's an actual selection area (not just a click)
      if (rect.width > 5 && rect.height > 5) {
        onSelectionComplete!(rect);
      }
    }

    // Request focus so keyboard events (like DEL) go to the game area
    focusNode?.requestFocus();

    _cleanup();
    event.handled = true;
  }

  void _updateSelectionRect() {
    if (_dragStart == null || _dragEnd == null || _selectionRect == null) return;

    // Calculate position and size (handles any drag direction)
    final minX = _dragStart!.x < _dragEnd!.x ? _dragStart!.x : _dragEnd!.x;
    final minY = _dragStart!.y < _dragEnd!.y ? _dragStart!.y : _dragEnd!.y;
    final width = (_dragEnd!.x - _dragStart!.x).abs();
    final height = (_dragEnd!.y - _dragStart!.y).abs();

    _selectionRect!.position = Vector2(minX, minY);
    _selectionRect!.size = Vector2(width, height);
  }

  void _cleanup() {
    _dragStart = null;
    _dragEnd = null;

    if (_selectionRect != null) {
      _selectionRect!.removeFromParent();
      _selectionRect = null;
    }
  }

  @override
  void onRemove() {
    _cleanup();
    super.onRemove();
  }
}
