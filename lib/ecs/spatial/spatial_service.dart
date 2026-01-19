import 'dart:async';

import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'package:rogueverse/ecs/events.dart';
import 'package:rogueverse/ecs/spatial/spatial_index.dart';
import 'package:rogueverse/ecs/world.dart';

/// A service that maintains a shared spatial index for the world.
///
/// Listens to component changes and automatically keeps the spatial index
/// in sync with entity positions. Systems can query the index for efficient
/// position-based lookups without maintaining their own indices.
///
/// Usage:
/// ```dart
/// // Get entities at a specific position
/// final entities = world.spatial.getEntitiesAt(5, 10, parentId: roomId);
///
/// // Check if a position is blocked
/// final blocked = world.spatial.hasEntityAt(5, 10, parentId: roomId,
///   predicate: (id) => world.getEntity(id).has<BlocksMovement>());
/// ```
class SpatialService with Disposer {
  static final _logger = Logger('SpatialService');

  final World _world;
  final SpatialIndex index = SpatialIndex();

  StreamSubscription<Change>? _changeSubscription;
  bool _initialized = false;

  SpatialService(this._world);

  /// Lazily initialize the spatial index.
  /// Called automatically on first access to ensure index is ready.
  void ensureInitialized() {
    if (_initialized) return;

    _logger.fine('Initializing spatial index');

    // Build initial index from all existing LocalPosition components
    final positions = _world.get<LocalPosition>();
    for (final entry in positions.entries) {
      final entityId = entry.key;
      final pos = entry.value;
      final parentId =
          _world.getEntity(entityId).get<HasParent>()?.parentEntityId;

      index.add(entityId, pos.x, pos.y, parentId: parentId);
    }

    // Subscribe to component changes for reactive updates
    _changeSubscription = _world.componentChanges.listen(_handleChange);
    toDispose(_changeSubscription!.cancel.asDisposable());

    _initialized = true;
    _logger.fine('Spatial index initialized',
        {'positionCount': positions.length});
  }

  /// Handle component changes and update the spatial index accordingly.
  void _handleChange(Change change) {
    // Update spatial index for position changes
    if (change.componentType == 'LocalPosition') {
      _handlePositionChange(change);
    }

    // Handle HasParent changes (entity moving between hierarchy scopes)
    if (change.componentType == 'HasParent') {
      _handleParentChange(change);
    }
  }

  /// Update spatial index when LocalPosition changes.
  void _handlePositionChange(Change change) {
    final entity = _world.getEntity(change.entityId);
    final parentId = entity.get<HasParent>()?.parentEntityId;

    // Remove from old position
    if (change.oldValue != null) {
      final oldPos = change.oldValue as LocalPosition;
      index.remove(change.entityId, oldPos.x, oldPos.y, parentId: parentId);
    }

    // Add to new position
    if (change.kind == ChangeKind.added || change.kind == ChangeKind.updated) {
      final newPos = entity.get<LocalPosition>();
      if (newPos != null) {
        index.add(change.entityId, newPos.x, newPos.y, parentId: parentId);
      }
    }
  }

  /// Handle entity reparenting (moving between hierarchy scopes).
  void _handleParentChange(Change change) {
    final entity = _world.getEntity(change.entityId);
    final pos = entity.get<LocalPosition>();

    if (pos != null) {
      final oldParentId = (change.oldValue as HasParent?)?.parentEntityId;
      final newParentId = entity.get<HasParent>()?.parentEntityId;

      index.reparent(
        change.entityId,
        pos.x,
        pos.y,
        oldParentId: oldParentId,
        newParentId: newParentId,
      );
    }
  }

  /// Reset the spatial index and rebuild from current world state.
  ///
  /// Call this when the world is fully reloaded (e.g., loading a save file).
  void resetState() {
    _logger.fine('Resetting spatial index');

    index.clear();
    _changeSubscription?.cancel();
    _changeSubscription = null;
    _initialized = false;

    // Immediately rebuild
    ensureInitialized();
  }

  /// Dispose the service and clean up subscriptions.
  void dispose() {
    disposeAll();
    index.clear();
  }
}
