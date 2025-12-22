import 'package:flame/components.dart' show PositionComponent, Vector2, KeyboardHandler;
import 'package:flame/events.dart' show TapCallbacks, DragCallbacks, SecondaryTapCallbacks, TapDownEvent, TapUpEvent, DragStartEvent, DragUpdateEvent, DragEndEvent, SecondaryTapUpEvent;
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
/// - Left-click/drag: Place entities (or remove if in removal mode)
/// - Right-click: Toggle removal mode (sets template to null)
/// - Ctrl: Filled rectangle mode
/// - Ctrl+Shift: Hollow rectangle mode
/// - ESC: Exit removal mode / deselect template
class TemplateEntitySpawner extends PositionComponent
    with TapCallbacks, DragCallbacks, SecondaryTapCallbacks, KeyboardHandler {

  final World world;
  final ValueNotifier<EntityTemplate?> templateNotifier;

  final _logger = Logger('TemplateEntitySpawner');

  PlacementPreview? _preview;
  LocalPosition? _dragStart;
  LocalPosition? _dragCurrent;

  TemplateEntitySpawner({
    required this.world,
    required this.templateNotifier,
  }) {
    priority = 100; // Before camera controls!
  }

  EntityTemplate? get _template => templateNotifier.value;
  bool get _isActive => _preview != null; // Active when preview exists (placement or removal mode)

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Listen to template changes to update preview
    templateNotifier.addListener(_onTemplateChanged);
    _onTemplateChanged(); // Initial setup
  }

  /// Updates preview component when template changes
  void _onTemplateChanged() {
    final template = _template;

    if (template != null) {
      // Template selected - create preview with entity's SVG
      if (_preview != null) {
        _preview!.removeFromParent();
        _preview = null;
      }

      final renderable = template.components.whereType<Renderable>().firstOrNull;
      if (renderable != null) {
        _preview = PlacementPreview(svgAssetPath: renderable.svgAssetPath);
        add(_preview!);
      }
    }
    // Note: When template becomes null, we don't automatically remove preview
    // It might be in removal mode (showing removal.svg)
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

  // === RIGHT-CLICK: TOGGLE REMOVAL MODE ===

  @override
  void onSecondaryTapUp(SecondaryTapUpEvent event) {
    // Right-click toggles removal mode by setting template to null
    // Remove old preview
    if (_preview != null) {
      _preview!.removeFromParent();
      _preview = null;
    }

    // Set template to null (signals removal mode)
    templateNotifier.value = null;

    // Create removal mode preview
    _preview = PlacementPreview(svgAssetPath: 'images/cross.svg');
    add(_preview!);

    event.handled = true;
  }

  // === KEYBOARD ===

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _logger.info('[ESC] onKeyEvent called - event type: ${event.runtimeType}, key: ${event.logicalKey}, _isActive: $_isActive');

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      _logger.info('[ESC] ESC key detected, _isActive: $_isActive, _preview: ${_preview != null}, _template: ${_template != null}');

      if (_isActive) {
        _logger.info('[ESC] Exiting editor mode');

        // Clear drag state
        _clearState();

        // Clear preview (exits removal mode or deselects template)
        if (_preview != null) {
          _preview!.removeFromParent();
          _preview = null;
        }

        // Clear template
        templateNotifier.value = null;

        _logger.info('[ESC] Editor mode exited successfully');
        return true; // Consumed ESC
      } else {
        _logger.info('[ESC] Not active, letting other handlers process ESC');
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

    // Show as removal if template is null (removal mode)
    final isRemoval = _template == null;
    _preview?.updatePreview(positions, isRemoval);
  }

  /// Executes placement or removal at calculated positions
  void _execute(LocalPosition start, LocalPosition end, {required bool isPlacement}) {
    final template = _template;
    final mode = _getPlacementMode();
    final positions = PlacementStrategy.calculate(
      start: start,
      end: end,
      mode: mode,
    );

    for (final pos in positions) {
      if (template == null) {
        // Removal mode - delete entities at position
        EntityManipulator.removeEntitiesAt(world, pos);
      } else {
        // Placement mode - place/replace entities
        EntityManipulator.placeEntity(world, template, pos);
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
    _preview?.clearPreview();
  }

  @override
  void onRemove() {
    templateNotifier.removeListener(_onTemplateChanged);
    super.onRemove();
  }
}
