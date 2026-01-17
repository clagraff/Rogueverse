import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart' hide World;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/events.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/components/vision_tile.dart';
import 'package:rogueverse/game/game_area.dart';

/// Renders a vision cone overlay showing which tiles an entity can see.
///
/// Updates automatically when the entity's VisibleEntities component changes.
/// Tiles farther from the observer have less prominent fill color (gradient fade).
/// Now dynamically updates based on GameArea.observerEntityId.
class VisionConeComponent extends PositionComponent {
  static final _logger = Logger('VisionCone');

  final World world;
  final ValueNotifier<int?> observerIdNotifier;

  StreamSubscription<Change>? _visionSubscription;
  VoidCallback? _observerChangeListener;
  VoidCallback? _gameModeChangeListener;
  int? _currentObserverId;

  // Component pool for animated tiles
  Set<LocalPosition> _previousVisibleTiles = {};
  final Map<LocalPosition, VisionTile> _activeTiles = {};
  final List<VisionTile> _pool = [];
  LocalPosition? _observerPosition;

  VisionConeComponent({
    required this.world,
    required this.observerIdNotifier,
  });

  @override
  Future<void> onLoad() async {
    final game = findGame() as GameArea?;

    // Listen for observer changes
    _observerChangeListener = () {
      final newObserverId = observerIdNotifier.value;
      if (newObserverId != _currentObserverId) {
        _currentObserverId = newObserverId;
        _attachToEntity(newObserverId);
      }
    };

    observerIdNotifier.addListener(_observerChangeListener!);

    // Listen for game mode changes - vision cone visibility is checked in render()
    if (game != null) {
      _gameModeChangeListener = () {
        // Listener ensures render() is called when mode changes
      };
      game.gameMode.addListener(_gameModeChangeListener!);
    }

    // Initial setup
    _currentObserverId = observerIdNotifier.value;
    _attachToEntity(_currentObserverId);

    return super.onLoad();
  }

  void _attachToEntity(int? observedEntityId) {
    // Cancel previous subscription
    _visionSubscription?.cancel();
    _visionSubscription = null;

    // Clear vision cone if no observer
    if (observedEntityId == null) {
      _fadeOutAllTiles();
      _observerPosition = null;
      return;
    }

    // Check if observer has VisionRadius - if not, don't show vision cone
    final entity = world.getEntity(observedEntityId);
    if (!entity.has<VisionRadius>()) {
      _fadeOutAllTiles();
      _observerPosition = null;
      return;
    }

    // Subscribe ONLY to VisibleEntities changes (which already includes position/direction)
    // VisionSystem updates VisibleEntities AFTER MovementSystem runs, so we always get
    // vision data that reflects the current position and direction.
    _visionSubscription = world.componentChanges
        .onEntityOnComponent<VisibleEntities>(observedEntityId)
        .listen(_onVisionChanged);

    // Initial render
    _regenerateVisionCone();
  }

  void _onVisionChanged(Change change) {
    _logger.fine('vision_changed: entity=$_currentObserverId, kind=${change.kind}');
    if (change.kind == ChangeKind.removed) {
      // Entity lost vision - fade out all tiles
      _fadeOutAllTiles();
      _observerPosition = null;
      return;
    }
    _regenerateVisionCone();
  }

  void _regenerateVisionCone() {
    if (_currentObserverId == null) {
      _fadeOutAllTiles();
      _observerPosition = null;
      return;
    }

    final entity = world.getEntity(_currentObserverId!);
    final visibleEntities = entity.get<VisibleEntities>();
    final position = entity.get<LocalPosition>();

    _logger.fine(
        'vision_regenerated: entity=$_currentObserverId, tiles=${visibleEntities?.visibleTiles.length ?? 0}, position=(${position?.x},${position?.y})');

    if (visibleEntities == null || position == null) {
      _fadeOutAllTiles();
      _observerPosition = null;
      return;
    }

    final newTiles = visibleEntities.visibleTiles;
    final oldPosition = _observerPosition;
    _observerPosition = position;

    // Hide vision cone in editing mode - fade out all tiles
    final game = findGame() as GameArea?;
    if (game != null && game.gameMode.value == GameMode.editing) {
      _fadeOutAllTiles();
      return;
    }

    // Check if we have NEW tiles (not just removed tiles)
    final addedTiles = newTiles.difference(_previousVisibleTiles);

    // Do a hard reset if:
    // 1. Position changed at all (handles world reloads with stale tile state)
    // 2. First render after re-attaching (oldPosition is null) - always start fresh
    // 3. New tiles are being added (e.g., door opened, revealing more area)
    //    This ensures proper max distance calculation for gradient consistency
    final positionChanged = oldPosition != null &&
        (position.x != oldPosition.x || position.y != oldPosition.y);
    final firstRenderAfterAttach = oldPosition == null;
    final newTilesAdded = addedTiles.isNotEmpty;

    if (positionChanged || firstRenderAfterAttach || newTilesAdded) {
      _hardResetTiles(newTiles);
      return;
    }

    // Tiles leaving visibility - fade out
    final leavingTiles = _previousVisibleTiles.difference(newTiles);
    for (final pos in leavingTiles) {
      final tile = _activeTiles[pos];
      if (tile != null) {
        tile.hide(onComplete: () => _releaseTile(tile, pos));
      }
    }

    // New tiles - acquire from pool, add as child, fade in
    final newlyVisible = newTiles.difference(_previousVisibleTiles);
    for (final pos in newlyVisible) {
      final tile = _acquireTile();
      _activeTiles[pos] = tile;
      final targetAlpha = _calculateTargetAlpha(pos);
      tile.show(
        gridPosition: Vector2(pos.x * 32.0, pos.y * 32.0),
        targetAlpha: targetAlpha,
      );
      add(tile);
    }

    // Existing tiles - update alpha if observer moved (distance changed)
    final existingTiles = newTiles.intersection(_previousVisibleTiles);
    for (final pos in existingTiles) {
      final tile = _activeTiles[pos];
      if (tile != null) {
        tile.updateTargetAlpha(_calculateTargetAlpha(pos));
      }
    }

    _previousVisibleTiles = Set.from(newTiles);
  }

  /// Get a tile from pool or create new one.
  VisionTile _acquireTile() {
    if (_pool.isNotEmpty) {
      return _pool.removeLast();
    }
    return VisionTile();
  }

  /// Return tile to pool after fade-out completes.
  void _releaseTile(VisionTile tile, LocalPosition pos) {
    tile.removeFromParent();
    _pool.add(tile);
    // Only remove from _activeTiles if this is still the tracked tile for this position.
    // Prevents race condition where a new tile was assigned to the same position
    // before this callback fired.
    if (_activeTiles[pos] == tile) {
      _activeTiles.remove(pos);
    }
  }

  /// Fade out all active tiles.
  void _fadeOutAllTiles() {
    for (final entry in _activeTiles.entries.toList()) {
      entry.value.hide(onComplete: () => _releaseTile(entry.value, entry.key));
    }
    _previousVisibleTiles = {};
  }

  /// Hard reset: immediately remove all tiles and create fresh ones.
  /// Use when position changes significantly (teleport, world reload).
  void _hardResetTiles(Set<LocalPosition> newTiles) {
    // Immediately remove all existing tiles (no fade animation)
    for (final tile in _activeTiles.values) {
      tile.removeFromParent();
    }
    _activeTiles.clear();
    _pool.clear(); // Clear pool too since those tiles may have stale state
    _previousVisibleTiles = {};

    // Pre-calculate max distance for proper alpha calculation
    final maxDistance = _calculateMaxDistanceFor(newTiles);

    // Create all new tiles fresh
    for (final pos in newTiles) {
      final tile = VisionTile();
      _activeTiles[pos] = tile;
      final targetAlpha = _calculateTargetAlphaWith(pos, maxDistance);
      tile.show(
        gridPosition: Vector2(pos.x * 32.0, pos.y * 32.0),
        targetAlpha: targetAlpha,
      );
      add(tile);
    }
    _previousVisibleTiles = Set.from(newTiles);
  }

  /// Calculate target alpha based on distance from observer.
  double _calculateTargetAlpha(LocalPosition tile) {
    if (_observerPosition == null) return 0.0;
    final maxDistance = _calculateMaxDistance();
    final distance = _calculateDistance(_observerPosition!, tile);
    final normalizedDistance = maxDistance > 0 ? distance / maxDistance : 0.0;
    return (0.4 - (normalizedDistance * 0.35)).clamp(0.05, 0.4);
  }

  /// Calculate Euclidean distance between two positions
  double _calculateDistance(LocalPosition from, LocalPosition to) {
    final dx = (to.x - from.x).toDouble();
    final dy = (to.y - from.y).toDouble();
    return sqrt(dx * dx + dy * dy);
  }

  /// Find the maximum distance in the active tiles set
  double _calculateMaxDistance() {
    if (_activeTiles.isEmpty || _observerPosition == null) return 0.0;

    double max = 0.0;
    for (final tile in _activeTiles.keys) {
      final distance = _calculateDistance(_observerPosition!, tile);
      if (distance > max) max = distance;
    }
    return max;
  }

  /// Find the maximum distance for a given set of tiles.
  /// Used by _hardResetTiles to pre-calculate before adding tiles.
  double _calculateMaxDistanceFor(Set<LocalPosition> tiles) {
    if (tiles.isEmpty || _observerPosition == null) return 0.0;

    double max = 0.0;
    for (final tile in tiles) {
      final distance = _calculateDistance(_observerPosition!, tile);
      if (distance > max) max = distance;
    }
    return max;
  }

  /// Calculate target alpha with a pre-computed maxDistance.
  /// Used by _hardResetTiles to avoid incremental calculation issues.
  double _calculateTargetAlphaWith(LocalPosition tile, double maxDistance) {
    if (_observerPosition == null) return 0.0;
    final distance = _calculateDistance(_observerPosition!, tile);
    final normalizedDistance = maxDistance > 0 ? distance / maxDistance : 0.0;
    return (0.4 - (normalizedDistance * 0.35)).clamp(0.05, 0.4);
  }

  @override
  void onRemove() {
    _visionSubscription?.cancel();
    if (_observerChangeListener != null) {
      observerIdNotifier.removeListener(_observerChangeListener!);
    }
    if (_gameModeChangeListener != null) {
      final game = findGame() as GameArea?;
      game?.gameMode.removeListener(_gameModeChangeListener!);
    }
    super.onRemove();
  }
}
