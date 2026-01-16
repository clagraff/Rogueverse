import 'package:flame/components.dart' show PositionComponent, Vector2, KeyboardHandler;
import 'package:flame/events.dart' show TapCallbacks, DragCallbacks, SecondaryTapCallbacks, HoverCallbacks, TapDownEvent, TapUpEvent, DragStartEvent, DragUpdateEvent, DragEndEvent, SecondaryTapUpEvent, PointerMoveEvent;
import 'package:flutter/services.dart' show HardwareKeyboard, KeyEvent, LogicalKeyboardKey, KeyDownEvent;
import 'package:flutter/widgets.dart' show ValueNotifier;
import 'package:logging/logging.dart' show Logger;
import 'package:rogueverse/ecs/components.dart' show LocalPosition, Renderable, ImageAsset, Name, HasParent;
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
/// - Hover: Show preview at current mouse position (when template selected)
/// - Left-click/drag: Place entities (or remove if in removal mode)
/// - Right-click: Toggle removal mode (sets template to null)
/// - Ctrl: Filled rectangle mode
/// - Ctrl+Shift: Hollow rectangle mode
/// - ESC: Exit removal mode / deselect template
class TemplateEntitySpawner extends PositionComponent
    with TapCallbacks, DragCallbacks, SecondaryTapCallbacks, KeyboardHandler, HoverCallbacks {

  final World world;
  final ValueNotifier<int?> templateIdNotifier;
  final ValueNotifier<bool> blankEntityModeNotifier;
  final ValueNotifier<int?> viewedParentNotifier;

  final _logger = Logger('TemplateEntitySpawner');

  PlacementPreview? _preview;
  LocalPosition? _dragStart;
  LocalPosition? _dragCurrent;
  LocalPosition? _hoverPosition;
  DateTime? _lastHoverUpdate;

  TemplateEntitySpawner({
    required this.world,
    required this.templateIdNotifier,
    required this.blankEntityModeNotifier,
    required this.viewedParentNotifier,
  }) {
    priority = 100; // Before camera controls!
  }

  int? get _templateId => templateIdNotifier.value;
  bool get _blankEntityMode => blankEntityModeNotifier.value;
  // Active when a template is selected or blank entity mode is active
  bool get _isActive => _templateId != null || _blankEntityMode;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Listen to template changes to update preview
    templateIdNotifier.addListener(_onTemplateChanged);
    blankEntityModeNotifier.addListener(_onBlankEntityModeChanged);
    _onTemplateChanged(); // Initial setup
  }

  /// Updates preview component when template changes
  void _onTemplateChanged() {
    final templateId = _templateId;

    if (templateId != null) {
      // Template selected - create preview with entity's SVG
      if (_preview != null) {
        _preview!.removeFromParent();
        _preview = null;
      }

      // Get the template entity and its Renderable component
      final templateEntity = world.getEntity(templateId);
      final renderable = templateEntity.get<Renderable>();
      if (renderable != null) {
        _preview = PlacementPreview(asset: renderable.asset);
        add(_preview!);
      }
    } else if (!_blankEntityMode) {
      // Template deselected and not in blank mode - exit placement/removal mode completely
      exitPlacementMode();
    }
  }

  /// Updates preview component when blank entity mode changes
  void _onBlankEntityModeChanged() {
    if (_blankEntityMode) {
      // Blank entity mode activated - create preview with default SVG
      if (_preview != null) {
        _preview!.removeFromParent();
        _preview = null;
      }

      _preview = PlacementPreview.fromPath('images/default.svg');
      add(_preview!);
    } else if (_templateId == null) {
      // Blank entity mode deactivated and no template - exit placement mode
      exitPlacementMode();
    }
  }

  /// Exits placement mode completely, clearing all state and preview
  void exitPlacementMode() {
    _clearState();
    _hoverPosition = null;
    _lastHoverUpdate = null;

    if (_preview != null) {
      _preview!.removeFromParent();
      _preview = null;
    }
  }

  /// Only intercept events when in placement or removal mode
  @override
  bool containsLocalPoint(Vector2 point) => _isActive;

  // === LEFT-CLICK PLACEMENT/REMOVAL ===

  @override
  void onTapDown(TapDownEvent event) {
    if (!_isActive) return;

    _dragStart = GridCoordinates.screenToGrid(event.localPosition);
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

    // Clear hover state during drag
    _hoverPosition = null;
    _lastHoverUpdate = null;

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

  // === RIGHT-CLICK: EXIT PLACEMENT MODE ===

  @override
  void onSecondaryTapUp(SecondaryTapUpEvent event) {
    if (!_isActive) return;

    // Right-click exits placement mode
    exitPlacementMode();
    templateIdNotifier.value = null;
    blankEntityModeNotifier.value = false;

    event.handled = true;
  }

  // === HOVER PREVIEW ===

  /// Debounce interval for hover updates (in milliseconds)
  static const int _hoverDebounceMs = 16; // ~60fps

  @override
  void onPointerMove(PointerMoveEvent event) {
    if (!_isActive) return;

    // Don't show hover preview while dragging
    if (_dragStart != null) return;

    // Debounce hover updates
    final now = DateTime.now();
    if (_lastHoverUpdate != null) {
      final elapsed = now.difference(_lastHoverUpdate!).inMilliseconds;
      if (elapsed < _hoverDebounceMs) {
        return;
      }
    }
    _lastHoverUpdate = now;

    final gridPos = GridCoordinates.screenToGrid(event.localPosition);

    // Only update if position changed
    if (_hoverPosition == gridPos) return;

    _hoverPosition = gridPos;

    // Show single-cell preview at hover position
    _preview?.updatePreview([gridPos], false);

    super.onPointerMove(event);
  }

  @override
  void onHoverExit() {
    // Clear hover state when mouse leaves the game area
    _hoverPosition = null;
    _lastHoverUpdate = null;
    _preview?.clearPreview();
  }

  // === KEYBOARD ===

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!_isActive) {
      return true;
    }

    _logger.info('onKeyEvent triggered: event_type=${event.runtimeType} key=${event.logicalKey} _isActive=$_isActive');

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      _logger.info('esc key detected: _isActive=$_isActive _preview=${_preview != null} _templateId=${_templateId != null}');

      if (_isActive) {
        _logger.info('exiting editor');

        // Exit placement mode and clear template/blank mode
        exitPlacementMode();
        templateIdNotifier.value = null;
        blankEntityModeNotifier.value = false;

        _logger.info('exited editor successfully');
        return false; // Consumed ESC
      } else {
        _logger.info('Escape key not active');
      }
    }
    return true; // Let others handle
  }

  // === INTERNAL LOGIC ===

  /// Updates preview to show where entities will be placed
  void _updatePreview(LocalPosition start, LocalPosition end, {required bool isPlacement}) {
    final mode = _getPlacementMode();
    final positions = PlacementStrategy.calculate(
      start: start,
      end: end,
      mode: mode,
    );

    _preview?.updatePreview(positions, false);
  }

  /// Executes entity placement at calculated positions
  void _execute(LocalPosition start, LocalPosition end, {required bool isPlacement}) {
    final templateId = _templateId;
    final mode = _getPlacementMode();
    final positions = PlacementStrategy.calculate(
      start: start,
      end: end,
      mode: mode,
    );

    for (final pos in positions) {
      if (templateId != null) {
        // Template placement mode - place entity with FromTemplate reference
        EntityManipulator.placeEntity(world, templateId, pos, viewedParentNotifier.value);
      } else if (_blankEntityMode) {
        // Blank entity mode - place a default entity
        _placeBlankEntity(pos);
      }
    }

    _preview?.clearPreview();
  }

  /// Places a blank entity with default components at the specified position.
  void _placeBlankEntity(LocalPosition pos) {
    final parentId = viewedParentNotifier.value;

    // Remove existing blocking entities at position
    EntityManipulator.removeEntitiesAt(world, pos, parentId);

    // Create new entity with default components
    final entity = world.add([
      pos,
      Renderable(ImageAsset('images/default.svg')),
      Name(name: 'Entity'),
    ]);

    // Set parent if viewing a specific parent
    if (parentId != null) {
      entity.upsertByName(HasParent(parentId));
    }
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
    // Note: Don't clear hover state here, as we want hover to resume after drag ends
    _preview?.clearPreview();
  }

  @override
  void onRemove() {
    templateIdNotifier.removeListener(_onTemplateChanged);
    blankEntityModeNotifier.removeListener(_onBlankEntityModeChanged);
    super.onRemove();
  }
}
