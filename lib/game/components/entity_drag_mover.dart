import 'package:flame/components.dart' show PositionComponent, Vector2;
import 'package:flame/events.dart' show DragCallbacks, DragStartEvent, DragUpdateEvent, DragEndEvent;
import 'package:flame/game.dart' show FlameGame;
import 'package:flutter/material.dart' show Colors, ValueNotifier;
import 'package:logging/logging.dart' show Logger;
import 'package:rogueverse/ecs/components.dart' show LocalPosition, Renderable, HasParent;
import 'package:rogueverse/ecs/entity.dart' show Entity;
import 'package:rogueverse/ecs/entity_template.dart' show EntityTemplate;
import 'package:rogueverse/ecs/query.dart' show Query;
import 'package:rogueverse/ecs/world.dart' show World;
import 'package:rogueverse/game/components/svg_component.dart' show SvgTileComponent;
import 'package:rogueverse/game/utils/grid_coordinates.dart' show GridCoordinates;

/// Allows dragging entities to move them when template panel is open but no template is selected.
///
/// This component enables a "move mode" where users can click and drag entities
/// to reposition them on the grid. It only activates when the template panel overlay
/// is open and no entity template is currently selected for placement.
///
/// **Design:**
/// - High priority (99) to intercept events before camera but after TemplateEntitySpawner
/// - Only active when template panel is open AND no template selected
/// - Shows blue preview during drag operation
/// - Commits the move on drag end (entity animates smoothly via Agent component)
///
/// **Future Enhancement:**
/// Could temporarily hide the original entity's Agent component during drag for cleaner visuals
class EntityDragMover extends PositionComponent with DragCallbacks {
  final World world;
  final ValueNotifier<EntityTemplate?> templateNotifier;
  final ValueNotifier<int?> viewedParentNotifier;
  final FlameGame game;

  final _logger = Logger('EntityDragMover');

  Entity? _draggedEntity;
  LocalPosition? _originalPosition;
  LocalPosition? _currentDragPosition;
  SvgTileComponent? _previewComponent;

  EntityDragMover({
    required this.world,
    required this.templateNotifier,
    required this.game,
    required this.viewedParentNotifier,
  }) {
    priority = 99; // Just before TemplateEntitySpawner (100)
  }

  /// Only intercept events when template panel is open and no template is selected
  @override
  bool containsLocalPoint(Vector2 point) {
    // Check if template panel overlay is active
    final isPanelOpen = game.overlays.isActive('templatePanel');
    // Check if no template is selected
    final noTemplateSelected = templateNotifier.value == null;
    
    return isPanelOpen && noTemplateSelected;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final gridPos = GridCoordinates.screenToGrid(event.localPosition);
    
    // Find entity at this position
    var query = Query()
        .require<LocalPosition>((lp) => lp.x == gridPos.x && lp.y == gridPos.y)
        .require<Renderable>();

    if (viewedParentNotifier.value != null) {
      query = query.require<HasParent>((p) => p.parentEntityId == viewedParentNotifier.value!);
    } else {
      query = query.exclude<HasParent>();
    }

    final entities = query
        .find(world)
        .toList();

    if (entities.isEmpty) {
      _logger.info('No entity at ${gridPos.x}, ${gridPos.y}');
      return;
    }

    // Pick first entity (in case multiple at same position)
    _draggedEntity = entities.first;
    _originalPosition = _draggedEntity!.get<LocalPosition>()!;
    _currentDragPosition = _originalPosition;

    _logger.info('Started dragging entity ${_draggedEntity!.id} from (${_originalPosition!.x}, ${_originalPosition!.y})');

    // Create preview component
    final renderable = _draggedEntity!.get<Renderable>();
    if (renderable != null) {
      _previewComponent = SvgTileComponent(
        svgAssetPath: renderable.svgAssetPath,
        position: GridCoordinates.gridToScreen(_originalPosition!),
        size: Vector2.all(GridCoordinates.TILE_SIZE),
      );
      _previewComponent!.paint.color = Colors.blue.withValues(alpha: 0.6);
      add(_previewComponent!);
    }

    event.handled = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_draggedEntity == null) return;

    final gridPos = GridCoordinates.screenToGrid(event.localEndPosition);

    // Only update if position changed
    if (_currentDragPosition?.x == gridPos.x && _currentDragPosition?.y == gridPos.y) {
      return;
    }

    _currentDragPosition = gridPos;

    // Update preview position
    if (_previewComponent != null) {
      _previewComponent!.position = GridCoordinates.gridToScreen(gridPos);
    }

    _logger.fine('Dragging to (${gridPos.x}, ${gridPos.y})');

    event.handled = true;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (_draggedEntity == null) return;

    // Use the last drag position since DragEndEvent doesn't have localPosition
    final finalPos = _currentDragPosition ?? _originalPosition!;

    _logger.info('Dropped entity ${_draggedEntity!.id} at (${finalPos.x}, ${finalPos.y})');

    // Update entity's position
    _draggedEntity!.upsert<LocalPosition>(finalPos);

    // Clean up
    _clearState();

    event.handled = true;
  }

  /// Clears drag state and removes preview
  void _clearState() {
    _draggedEntity = null;
    _originalPosition = null;
    _currentDragPosition = null;

    if (_previewComponent != null) {
      _previewComponent!.removeFromParent();
      _previewComponent = null;
    }
  }

  @override
  void onRemove() {
    _clearState();
    super.onRemove();
  }
}
