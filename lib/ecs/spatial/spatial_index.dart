/// A spatial index for fast position-based entity queries.
///
/// Provides O(1) lookups for entities at specific positions, organized by
/// parent scope. This enables efficient spatial queries for systems like
/// vision, collision, and other grid-based mechanics.
///
/// Structure: parentId -> (x, y) -> Set<entityId>
/// - null parentId = global entities without parent
/// - Entities are scoped to their parent's coordinate space
class SpatialIndex {
  /// The spatial index: parentId -> (x, y) -> Set of entityIds
  final Map<int?, Map<(int, int), Set<int>>> _index = {};

  /// Get all entities at a specific position within a parent scope.
  ///
  /// Returns an empty set if no entities exist at that position.
  /// Time complexity: O(1)
  Set<int> getEntitiesAt(int x, int y, {int? parentId}) {
    return _index[parentId]?[(x, y)] ?? const {};
  }

  /// Get all entities within a radius of a position.
  ///
  /// Uses Chebyshev distance (max of dx, dy) for square radius.
  /// Time complexity: O(r^2) where r is radius
  Set<int> getEntitiesInRadius(int centerX, int centerY, int radius,
      {int? parentId}) {
    final result = <int>{};
    final parentIndex = _index[parentId];
    if (parentIndex == null) return result;

    for (int dx = -radius; dx <= radius; dx++) {
      for (int dy = -radius; dy <= radius; dy++) {
        final entities = parentIndex[(centerX + dx, centerY + dy)];
        if (entities != null) {
          result.addAll(entities);
        }
      }
    }

    return result;
  }

  /// Get all entities within a circular radius using Euclidean distance.
  ///
  /// Time complexity: O(r^2) where r is radius
  Set<int> getEntitiesInCircularRadius(int centerX, int centerY, int radius,
      {int? parentId}) {
    final result = <int>{};
    final parentIndex = _index[parentId];
    if (parentIndex == null) return result;

    final radiusSquared = radius * radius;

    for (int dx = -radius; dx <= radius; dx++) {
      for (int dy = -radius; dy <= radius; dy++) {
        if (dx * dx + dy * dy <= radiusSquared) {
          final entities = parentIndex[(centerX + dx, centerY + dy)];
          if (entities != null) {
            result.addAll(entities);
          }
        }
      }
    }

    return result;
  }

  /// Check if any entity matching a predicate exists at a position.
  ///
  /// More efficient than getEntitiesAt when you only need to check existence.
  /// Time complexity: O(k) where k is entities at that position
  bool hasEntityAt(
    int x,
    int y, {
    int? parentId,
    bool Function(int entityId)? predicate,
  }) {
    final entities = _index[parentId]?[(x, y)];
    if (entities == null || entities.isEmpty) return false;

    if (predicate == null) return true;
    return entities.any(predicate);
  }

  /// Add an entity to the spatial index at a position.
  void add(int entityId, int x, int y, {int? parentId}) {
    _index
        .putIfAbsent(parentId, () => {})
        .putIfAbsent((x, y), () => {})
        .add(entityId);
  }

  /// Remove an entity from the spatial index at a position.
  void remove(int entityId, int x, int y, {int? parentId}) {
    _index[parentId]?[(x, y)]?.remove(entityId);
  }

  /// Move an entity from one position to another within the same parent scope.
  void move(int entityId, int oldX, int oldY, int newX, int newY,
      {int? parentId}) {
    remove(entityId, oldX, oldY, parentId: parentId);
    add(entityId, newX, newY, parentId: parentId);
  }

  /// Move an entity between parent scopes (reparenting).
  void reparent(
    int entityId,
    int x,
    int y, {
    int? oldParentId,
    int? newParentId,
  }) {
    remove(entityId, x, y, parentId: oldParentId);
    add(entityId, x, y, parentId: newParentId);
  }

  /// Clear the entire spatial index.
  void clear() {
    _index.clear();
  }

  /// Get the number of parent scopes in the index.
  int get parentCount => _index.length;

  /// Get the total number of indexed positions across all parent scopes.
  int get positionCount {
    int count = 0;
    for (final parentMap in _index.values) {
      count += parentMap.length;
    }
    return count;
  }

  /// Get the total number of entity entries (an entity at multiple positions counts multiple times).
  int get entityEntryCount {
    int count = 0;
    for (final parentMap in _index.values) {
      for (final entitySet in parentMap.values) {
        count += entitySet.length;
      }
    }
    return count;
  }
}
