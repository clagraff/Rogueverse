import 'package:flame/components.dart' show PositionComponent, Vector2, KeyboardHandler;
import 'package:flame/events.dart' show TapCallbacks, DragCallbacks, SecondaryTapCallbacks, PointerMoveCallbacks, TapDownEvent, TapUpEvent, DragStartEvent, DragUpdateEvent, DragEndEvent, SecondaryTapDownEvent, SecondaryTapUpEvent, SecondaryTapCancelEvent, PointerMoveEvent;
import 'package:flutter/services.dart' show HardwareKeyboard, KeyEvent, LogicalKeyboardKey, KeyDownEvent;
import 'package:flutter/widgets.dart' show ValueNotifier;
import 'package:logging/logging.dart' show Logger;
import 'package:rogueverse/ecs/components.dart' show LocalPosition, Renderable;
import 'package:rogueverse/ecs/entity_template.dart' show EntityTemplate;
import 'package:rogueverse/ecs/world.dart' show World;
import 'package:rogueverse/game/components/placement_preview.dart' show PlacementPreview;
import 'package:rogueverse/game/utils/grid_coordinates.dart' show GridCoordinates;
import 'package:rogueverse/game/utils/placement_strategy.dart' show PlacementStrategy, PlacementMode;
import 'package:rogueverse/game/utils/entity_manipulator.dart' show EntityManipulator;

/// Spawns entities from templates based on mouse interactions.
///
/// This component bridges the gap between Flutter's template selection UI
/// and Flame's game world. It only intercepts events when a template is selected.
///
/// **Design:**
/// - High priority (100) runs before camera controls (priority -9999)
/// - `containsLocalPoint()` returns true only when template is selected
/// - Sets `event.handled = true` to prevent camera from seeing events
/// - Handles ESC to deselect template and exit placement mode
///
/// **Interactions:**
/// - Left-click/drag: Place entities
/// - Right-click/drag: Remove entities
/// - Ctrl: Filled rectangle mode
/// - Ctrl+Shift: Hollow rectangle mode
/// - ESC: Deselect template
class TemplateEntitySpawner extends PositionComponent
    with TapCallbacks, DragCallbacks, SecondaryTapCallbacks, PointerMoveCallbacks, KeyboardHandler {

  final World world;
  final ValueNotifier<EntityTemplate?> templateNotifier;

  final _logger = Logger('TemplateEntitySpawner');

  PlacementPreview? _preview;
  LocalPosition? _dragStart;
  LocalPosition? _dragCurrent;
  bool _isRightDragging = false;

  TemplateEntitySpawner({
    required this.world,
    required this.templateNotifier,
  }) {
    priority = 100; // Before camera controls!
  }

  EntityTemplate? get _template => templateNotifier.value;
  bool get _isActive => _template != null;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Listen to template changes to update preview
    templateNotifier.addListener(_onTemplateChanged);
    _onTemplateChanged(); // Initial setup
  }

  /// Updates preview component when template changes
  void _onTemplateChanged() {
    // Remove old preview
    if (_preview != null) {
      _preview!.removeFromParent();
      _preview = null;
    }

    // Create new preview if template has renderable
    final template = _template;
    if (template != null) {
      final renderable = template.components.whereType<Renderable>().firstOrNull;
      if (renderable != null) {
        _preview = PlacementPreview(svgAssetPath: renderable.svgAssetPath);
        add(_preview!);
        _logger.info('Template selected: ${template.displayName}');
      }
    } else {
      _logger.info('Template deselected');
    }
  }

  /// Only intercept events when a template is selected
  @override
  bool containsLocalPoint(Vector2 point) => _isActive;

  // === LEFT-CLICK PLACEMENT ===

  @override
  void onTapDown(TapDownEvent event) {
    if (!_isActive) return;

    _dragStart = GridCoordinates.screenToGrid(event.localPosition);
    _logger.info('Left tap down at: $_dragStart');
    event.handled = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!_isActive) return;

    final endPos = GridCoordinates.screenToGrid(event.localPosition);

    if (_dragStart != null) {
      _execute(_dragStart!, endPos, isPlacement: true);
    }

    _clearState();
    event.handled = true;
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (!_isActive) return;

    _dragStart = GridCoordinates.screenToGrid(event.localPosition);
    _dragCurrent = _dragStart;

    _logger.info('Left drag start at: $_dragStart');
    event.handled = true;
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_isActive) return;

    _dragCurrent = GridCoordinates.screenToGrid(event.localEndPosition);

    if (_dragStart != null && _dragCurrent != null) {
      _updatePreview(_dragStart!, _dragCurrent!, isPlacement: true);
    }

    event.handled = true;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (!_isActive) return;

    if (_dragStart != null && _dragCurrent != null) {
      _execute(_dragStart!, _dragCurrent!, isPlacement: true);
    }

    _clearState();
    event.handled = true;
    super.onDragEnd(event);
  }

  // === RIGHT-CLICK REMOVAL ===

  @override
  void onSecondaryTapDown(SecondaryTapDownEvent event) {
    if (!_isActive) return;

    _dragStart = GridCoordinates.screenToGrid(event.localPosition);
    _dragCurrent = _dragStart;
    _isRightDragging = true;

    _logger.info('Right tap down at: $_dragStart');
    // Don't set event.handled for secondary - can cause issues
  }

  @override
  void onSecondaryTapUp(SecondaryTapUpEvent event) {
    if (!_isActive) return;

    final endPos = GridCoordinates.screenToGrid(event.localPosition);

    if (_dragStart != null) {
      _execute(_dragStart!, endPos, isPlacement: false);
    }

    _clearState();
    // Don't set event.handled for secondary - can cause issues
  }

  @override
  void onSecondaryTapCancel(SecondaryTapCancelEvent event) {
    // Don't clear state - this fires during drag which is expected
    _logger.info('Secondary tap cancel (expected during drag)');
  }

  // === POINTER MOVE (for right-drag tracking) ===

  @override
  void onPointerMove(PointerMoveEvent event) {
    if (!_isActive) return;

    // Track mouse movement during right-drag (left-drag uses onDragUpdate instead)
    if (_isRightDragging && _dragStart != null) {
      _dragCurrent = GridCoordinates.screenToGrid(event.localPosition);
      _updatePreview(_dragStart!, _dragCurrent!, isPlacement: false);
    }
  }

  // === KEYBOARD ===

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      if (_isActive) {
        _logger.info('ESC pressed - deselecting template');
        _clearState();
        templateNotifier.value = null; // Deselect template
        return true; // Consumed ESC
      }
    }
    return false; // Let others handle
  }

  // === INTERNAL LOGIC ===

  /// Updates preview to show where entities will be placed/removed
  void _updatePreview(LocalPosition start, LocalPosition end, {required bool isPlacement}) {
    final mode = _getPlacementMode();
    final positions = PlacementStrategy.calculate(
      start: start,
      end: end,
      mode: mode,
    );

    _logger.info('Preview: ${positions.length} positions, mode: $mode, placement: $isPlacement');
    _preview?.updatePreview(positions, !isPlacement);
  }

  /// Executes placement or removal at calculated positions
  void _execute(LocalPosition start, LocalPosition end, {required bool isPlacement}) {
    final template = _template;
    if (template == null) return;

    final mode = _getPlacementMode();
    final positions = PlacementStrategy.calculate(
      start: start,
      end: end,
      mode: mode,
    );

    _logger.info('Execute ${isPlacement ? "placement" : "removal"}: ${positions.length} positions');

    for (final pos in positions) {
      if (isPlacement) {
        EntityManipulator.placeEntity(world, template, pos);
      } else {
        EntityManipulator.removeEntitiesAt(world, pos);
      }
    }

    _preview?.clearPreview();
  }

  /// Gets placement mode based on modifier keys
  PlacementMode _getPlacementMode() {
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final ctrl = HardwareKeyboard.instance.isControlPressed;

    if (ctrl && shift) {
      return PlacementMode.hollowRectangle;
    } else if (ctrl) {
      return PlacementMode.rectangle;
    } else {
      return PlacementMode.line;
    }
  }

  /// Clears drag state and preview
  void _clearState() {
    _dragStart = null;
    _dragCurrent = null;
    _isRightDragging = false;
    _preview?.clearPreview();
  }

  @override
  void onRemove() {
    templateNotifier.removeListener(_onTemplateChanged);
    super.onRemove();
  }
}
