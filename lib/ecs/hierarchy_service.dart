import 'dart:async';
import 'package:logging/logging.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/disposable.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/events.dart';
import 'package:rogueverse/ecs/world.dart';

/// Reactive service that maintains parent-child hierarchy indices.
///
/// Subscribes to HasParent component changes and updates indices incrementally
/// rather than rebuilding each tick. Replaces the combination of HierarchyCache
/// and HierarchySystem.
class HierarchyService with Disposer {
  static final _logger = Logger('HierarchyService');

  final World _world;

  /// Maps child entity ID to parent entity ID
  final Map<int, int> _childToParent = {};

  /// Maps parent entity ID to set of child entity IDs
  final Map<int, Set<int>> _parentToChildren = {};

  /// Subscription to component changes
  StreamSubscription<Change>? _subscription;

  /// Flag to ensure initialization happens only once
  bool _initialized = false;

  HierarchyService(this._world);

  /// Lazily initializes the service by building the initial index
  /// and subscribing to changes.
  void ensureInitialized() {
    if (_initialized) return;

    _logger.fine('HierarchyService initializing');

    // Build initial index from existing HasParent components
    _buildInitialIndex();

    // Subscribe to HasParent changes
    _subscription = _world.componentChanges.listen(_handleChange);
    toDispose(_subscription!.cancel.asDisposable());

    _initialized = true;
    _logger.fine('HierarchyService initialized', {
      'childCount': _childToParent.length,
      'parentCount': _parentToChildren.length,
    });
  }

  /// Builds the initial index from all existing HasParent components.
  void _buildInitialIndex() {
    final parents = _world.get<HasParent>();
    for (final entry in parents.entries) {
      final childId = entry.key;
      final parentId = entry.value.parentEntityId;
      _addRelationship(childId, parentId);
    }
  }

  /// Handles HasParent component changes.
  void _handleChange(Change change) {
    if (change.componentType != 'HasParent') return;

    final childId = change.entityId;
    final oldParent = change.oldValue as HasParent?;
    final newParent = change.newValue as HasParent?;

    // Remove old relationship if existed
    if (oldParent != null) {
      _removeRelationship(childId, oldParent.parentEntityId);
    }

    // Add new relationship if exists
    if (newParent != null) {
      _addRelationship(childId, newParent.parentEntityId);
    }

    _logger.finest('hierarchy updated', {
      'childId': childId,
      'oldParentId': oldParent?.parentEntityId,
      'newParentId': newParent?.parentEntityId,
    });
  }

  /// Adds a parent-child relationship to the indices.
  void _addRelationship(int childId, int parentId) {
    _childToParent[childId] = parentId;
    _parentToChildren.putIfAbsent(parentId, () => {}).add(childId);
  }

  /// Removes a parent-child relationship from the indices.
  void _removeRelationship(int childId, int parentId) {
    _childToParent.remove(childId);
    _parentToChildren[parentId]?.remove(childId);
    // Clean up empty sets
    if (_parentToChildren[parentId]?.isEmpty ?? false) {
      _parentToChildren.remove(parentId);
    }
  }

  /// Resets the service state. Call when world is reloaded.
  void resetState() {
    _childToParent.clear();
    _parentToChildren.clear();
    _subscription?.cancel();
    _subscription = null;
    _initialized = false;
    // Re-initialize to rebuild from new world state
    ensureInitialized();
  }

  // Query methods (same interface as HierarchyCache)

  /// Get all children of a parent entity.
  Set<int> getChildren(int parentId) {
    ensureInitialized();
    return _parentToChildren[parentId] ?? {};
  }

  /// Get parent of a child entity (null if no parent).
  int? getParent(int childId) {
    ensureInitialized();
    return _childToParent[childId];
  }

  /// Get all children that have a specific component.
  List<Entity> getChildrenWith<C extends Component>(int parentId) {
    ensureInitialized();
    return getChildren(parentId)
        .map((id) => _world.getEntity(id))
        .where((e) => e.has<C>())
        .toList();
  }

  /// Get all sibling entities (entities with same parent).
  Set<int> getSiblings(int entityId) {
    ensureInitialized();
    final parentId = getParent(entityId);
    if (parentId == null) return {};
    return getChildren(parentId).where((id) => id != entityId).toSet();
  }

  /// Dispose the service and clean up subscriptions.
  void dispose() {
    disposeAll();
    _childToParent.clear();
    _parentToChildren.clear();
  }
}
