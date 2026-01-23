import 'package:flame/components.dart' hide World;
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/components.dart' hide Component;
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/query.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/components/drag_select_component.dart';
import 'package:rogueverse/game/components/entity_tap_component.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/game/utils/grid_coordinates.dart';

/// Manages entity selection input components (tap and drag-select).
///
/// Responsibilities:
/// - Creates and manages EntityTapComponent for single-entity selection
/// - Creates and manages DragSelectComponent for multi-entity selection
/// - Enables/disables selection based on game mode (editing vs gameplay)
class SelectionManager extends Component {
  static final _logger = Logger('SelectionManager');

  final FocusNode focusNode;
  final ValueNotifier<Set<Entity>> selectedEntitiesNotifier;
  final ValueNotifier<int?> viewedParentNotifier;
  final ValueNotifier<int?> observerEntityIdNotifier;
  final ValueNotifier<GameMode> gameModeNotifier;
  final World world;

  late EntityTapComponent _entityTapComponent;
  late DragSelectComponent _dragSelectComponent;

  SelectionManager({
    required this.focusNode,
    required this.selectedEntitiesNotifier,
    required this.viewedParentNotifier,
    required this.observerEntityIdNotifier,
    required this.gameModeNotifier,
    required this.world,
  });

  @override
  Future<void> onLoad() async {
    // Create entity tap component for single-entity selection
    _entityTapComponent = EntityTapComponent(
      32,
      selectedEntitiesNotifier,
      world,
      observerEntityIdNotifier: observerEntityIdNotifier,
      viewedParentNotifier: viewedParentNotifier,
    );
    parent!.add(_entityTapComponent);
    parent!.add(EntityTapVisualizerComponent(selectedEntitiesNotifier));

    // Create drag-select component for multi-select in editing mode
    _dragSelectComponent = DragSelectComponent(
      isEnabled: false, // Starts disabled, enabled in editing mode
      focusNode: focusNode, // Ensure focus stays on game area after drag
      onSelectionComplete: _onDragSelectionComplete,
    );
    parent!.add(_dragSelectComponent);

    // Listen to game mode changes to enable/disable selection
    gameModeNotifier.addListener(_onGameModeChanged);
  }

  void _onDragSelectionComplete(Rect rect) {
    // Query all entities with LocalPosition in the viewed parent
    var query = Query().require<LocalPosition>();
    final viewedParentId = viewedParentNotifier.value;
    if (viewedParentId != null) {
      query = query.require<HasParent>((hp) => hp.parentEntityId == viewedParentId);
    } else {
      query = query.exclude<HasParent>();
    }

    final selected = <Entity>{};
    for (final entity in query.find(world)) {
      final lp = entity.get<LocalPosition>()!;
      final screenPos = GridCoordinates.gridToScreen(lp);
      // Check if entity center is within selection rectangle
      final entityCenter = screenPos + Vector2.all(16); // Half of 32px tile
      if (rect.contains(Offset(entityCenter.x, entityCenter.y))) {
        selected.add(entity);
      }
    }

    if (selected.isNotEmpty) {
      selectedEntitiesNotifier.value = selected;
      _logger.fine('drag-selected entities', {'count': selected.length});
    }
  }

  void _onGameModeChanged() {
    final isGameplay = gameModeNotifier.value == GameMode.gameplay;
    // Selection components are enabled in editing mode only
    _entityTapComponent.isEnabled = !isGameplay;
    _dragSelectComponent.isEnabled = !isGameplay;
  }

  @override
  void onRemove() {
    gameModeNotifier.removeListener(_onGameModeChanged);
  }
}
