import 'package:flame/components.dart' show PositionComponent, Vector2;
import 'package:flame/events.dart' show DragCallbacks, DragStartEvent, DragUpdateEvent, DragEndEvent;
import 'package:flame/game.dart' show FlameGame;
import 'package:flutter/material.dart' show Colors, ValueNotifier;
import 'package:logging/logging.dart' show Logger;
import 'package:rogueverse/ecs/components.dart' show LocalPosition, Renderable, HasParent, ImageAsset;
import 'package:rogueverse/ecs/entity.dart' show Entity;
import 'package:rogueverse/ecs/query.dart' show Query;
import 'package:rogueverse/ecs/world.dart' show World;
import 'package:rogueverse/game/components/svg_visual_component.dart' show SvgVisualComponent;
import 'package:rogueverse/game/game_area.dart' show GameMode;
import 'package:rogueverse/game/utils/grid_coordinates.dart' show GridCoordinates;

/// Allows dragging entities to move them in two scenarios:
/// 1. When template panel is open but no template is selected (legacy behavior)
/// 2. When in editing mode with selected entities (multi-entity drag-move)
///
/// This component enables a "move mode" where users can click and drag entities
/// to reposition them on the grid.
///
/// **Design:**
/// - High priority (99) to intercept events before camera but after TemplateEntitySpawner
/// - Active when template panel open AND no template selected, OR in editing mode with selection
/// - Shows blue preview during drag operation for all dragged entities
/// - Commits the move on drag end (entities animate smoothly via Agent component)
/// - Multi-select drag: drag starts on a selected entity, all selected entities move together
class EntityDragMover extends PositionComponent with DragCallbacks {
  final World world;
  final ValueNotifier<int?> templateIdNotifier;
  final ValueNotifier<int?> viewedParentNotifier;
  final ValueNotifier<Set<Entity>> selectedEntitiesNotifier;
  final ValueNotifier<GameMode> gameModeNotifier;
  final FlameGame game;

  final _logger = Logger('EntityDragMover');

  // Multi-entity drag state
  Set<Entity> _draggedEntities = {};
  Map<int, LocalPosition> _originalPositions = {};  // entityId -> original position
  Map<int, SvgVisualComponent> _previewComponents = {};  // entityId -> preview
  LocalPosition? _dragStartGridPos;  // Grid position where drag started
  LocalPosition? _currentDragGridPos;  // Current grid position during drag

  EntityDragMover({
    required this.world,
    required this.templateIdNotifier,
    required this.game,
    required this.viewedParentNotifier,
    required this.selectedEntitiesNotifier,
    required this.gameModeNotifier,
  }) {
    priority = 99; // Just before TemplateEntitySpawner (100)
  }

  /// Intercept events in two scenarios:
  /// 1. Template panel is open and no template is selected (legacy single-entity drag)
  /// 2. In editing mode with selected entities (multi-entity drag-move)
  @override
  bool containsLocalPoint(Vector2 point) {
    // Original condition: template panel open, no template selected
    final isPanelOpen = game.overlays.isActive('templatePanel');
    final noTemplateSelected = templateIdNotifier.value == null;
    if (isPanelOpen && noTemplateSelected) return true;

    // New condition: editing mode with selected entities
    final isEditing = gameModeNotifier.value == GameMode.editing;
    final hasSelection = selectedEntitiesNotifier.value.isNotEmpty;
    return isEditing && hasSelection;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final gridPos = GridCoordinates.screenToGrid(event.localPosition);

    // Check if we're in multi-entity editing mode
    final isEditing = gameModeNotifier.value == GameMode.editing;
    final selectedEntities = selectedEntitiesNotifier.value;

    if (isEditing && selectedEntities.isNotEmpty) {
      // Multi-entity drag: check if drag started on a SELECTED entity
      Entity? startEntity;
      for (final entity in selectedEntities) {
        final lp = entity.get<LocalPosition>();
        if (lp != null && lp.x == gridPos.x && lp.y == gridPos.y) {
          startEntity = entity;
          break;
        }
      }

      if (startEntity == null) {
        // Didn't start on a selected entity - don't handle this drag
        _logger.fine('drag did not start on a selected entity at ${gridPos.x}, ${gridPos.y}');
        return;
      }

      // Store all selected entities and their original positions
      _draggedEntities = Set.from(selectedEntities);
      _dragStartGridPos = gridPos;
      _currentDragGridPos = gridPos;

      _logger.info('started multi-entity drag', {
        'entityCount': _draggedEntities.length,
        'startPos': '${gridPos.x}, ${gridPos.y}'
      });

      for (final entity in _draggedEntities) {
        final lp = entity.get<LocalPosition>();
        if (lp != null) {
          _originalPositions[entity.id] = LocalPosition(x: lp.x, y: lp.y);

          // Create preview for each entity with ImageAsset
          final renderable = entity.get<Renderable>();
          if (renderable != null && renderable.asset is ImageAsset) {
            final imageAsset = renderable.asset as ImageAsset;
            final preview = SvgVisualComponent(
              svgAssetPath: imageAsset.svgAssetPath,
              position: GridCoordinates.gridToScreen(lp),
              size: Vector2.all(GridCoordinates.tileSize),
            );
            preview.paint.color = Colors.blue.withValues(alpha: 0.6);
            add(preview);
            _previewComponents[entity.id] = preview;
          }
        }
      }

      event.handled = true;
      return;
    }

    // Legacy single-entity drag (template panel mode)
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
      _logger.info('no entity at ${gridPos.x}, ${gridPos.y}');
      return;
    }

    // Pick first entity (in case multiple at same position)
    final draggedEntity = entities.first;
    final originalPos = draggedEntity.get<LocalPosition>()!;

    // Store as single-entity drag using multi-entity state
    _draggedEntities = {draggedEntity};
    _dragStartGridPos = gridPos;
    _currentDragGridPos = gridPos;
    _originalPositions[draggedEntity.id] = LocalPosition(x: originalPos.x, y: originalPos.y);

    _logger.info('started dragging entity', {"entityId": draggedEntity.id, "fromX": originalPos.x, "fromY": originalPos.y});

    // Create preview component (only for ImageAsset)
    final renderable = draggedEntity.get<Renderable>();
    if (renderable != null && renderable.asset is ImageAsset) {
      final imageAsset = renderable.asset as ImageAsset;
      final preview = SvgVisualComponent(
        svgAssetPath: imageAsset.svgAssetPath,
        position: GridCoordinates.gridToScreen(originalPos),
        size: Vector2.all(GridCoordinates.tileSize),
      );
      preview.paint.color = Colors.blue.withValues(alpha: 0.6);
      add(preview);
      _previewComponents[draggedEntity.id] = preview;
    }

    event.handled = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_draggedEntities.isEmpty || _dragStartGridPos == null) return;

    final gridPos = GridCoordinates.screenToGrid(event.localEndPosition);

    // Only update if position changed
    if (_currentDragGridPos?.x == gridPos.x && _currentDragGridPos?.y == gridPos.y) {
      return;
    }

    _currentDragGridPos = gridPos;

    // Calculate offset from drag start
    final offsetX = gridPos.x - _dragStartGridPos!.x;
    final offsetY = gridPos.y - _dragStartGridPos!.y;

    // Update preview positions for all dragged entities
    for (final entity in _draggedEntities) {
      final originalPos = _originalPositions[entity.id];
      final preview = _previewComponents[entity.id];
      if (originalPos != null && preview != null) {
        final newPos = LocalPosition(
          x: originalPos.x + offsetX,
          y: originalPos.y + offsetY,
        );
        preview.position = GridCoordinates.gridToScreen(newPos);
      }
    }

    _logger.finer('dragging to offset ($offsetX, $offsetY)');

    event.handled = true;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (_draggedEntities.isEmpty || _dragStartGridPos == null) return;

    // Calculate final offset from drag start
    final finalGridPos = _currentDragGridPos ?? _dragStartGridPos!;
    final offsetX = finalGridPos.x - _dragStartGridPos!.x;
    final offsetY = finalGridPos.y - _dragStartGridPos!.y;

    _logger.info('completed multi-entity drag', {
      'entityCount': _draggedEntities.length,
      'offset': '($offsetX, $offsetY)'
    });

    // Update all dragged entities' positions
    for (final entity in _draggedEntities) {
      final originalPos = _originalPositions[entity.id];
      if (originalPos != null) {
        final newPos = LocalPosition(
          x: originalPos.x + offsetX,
          y: originalPos.y + offsetY,
        );
        entity.upsert<LocalPosition>(newPos);
      }
    }

    // Clean up
    _clearState();

    event.handled = true;
  }

  /// Clears drag state and removes all preview components
  void _clearState() {
    _draggedEntities = {};
    _originalPositions = {};
    _dragStartGridPos = null;
    _currentDragGridPos = null;

    // Remove all preview components
    for (final preview in _previewComponents.values) {
      preview.removeFromParent();
    }
    _previewComponents = {};
  }

  @override
  void onRemove() {
    _clearState();
    super.onRemove();
  }
}
