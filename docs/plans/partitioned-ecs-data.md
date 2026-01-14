# Partitioned ECS Data by Parent Entity

## Status: Draft / Planning

## Prerequisites

This plan assumes the **Layered Game State** plan (`docs/plans/layered-game-state.md`) is implemented first. That plan separates initial state from save state using JSON patches.

## Problem Statement

Currently, the entire world is loaded/saved as a single JSON blob. As the game grows, this causes:
1. Memory bloat from loading all entities regardless of player location
2. Slow saves (entire world serialized each time)
3. No streaming capability for large worlds

## Proposed Solution

Partition ECS data by parent entity (using `HasParent` component). Each "room" or container in the hierarchy becomes a separate partition that can be loaded/unloaded independently.

```
Galaxy (root partition)
├── StarSystem_15 (partition)
│   ├── Planet_42 (partition)
│   │   ├── Building_100 (partition)
│   │   │   └── Room_128 (partition) ← Player is here
│   │   └── Ship_99 (partition)
```

**Key insight**: Systems already scope by parent (CollisionSystem, VisionSystem check siblings only), so partitioning aligns with existing architecture.

## File Structure

```
game_state/
├── initial/                       # Base state (editor-managed)
│   ├── manifest.json              # Partition registry
│   └── partitions/
│       ├── _root.json             # Entities with no parent
│       ├── galaxy_1.json          # Entities with HasParent(1)
│       ├── ship_2.json            # Entities with HasParent(2)
│       └── ...
│
└── save/                          # Player changes (JSON patches)
    ├── manifest.json              # Which partitions are dirty
    └── patches/
        ├── galaxy_1.patch.json    # Changes to partition 1
        └── ship_2.patch.json      # Changes to partition 2
```

## Loading/Unloading Strategy

**Proximity = Tree Distance** (not spatial coordinates)

Since the hierarchy is a tree, "nearby" means graph distance from the player's current parent:

```
Load depth = 2 means:
- Always load: parent chain to root (required for hierarchy queries)
- Load: siblings at current level
- Load: children up to 2 levels deep
- Load: destinations of portals in loaded partitions

Unload depth = 4 means:
- Unload partitions more than 4 edges away from player
```

**Triggers:**
1. `ProximityLoadingSystem` runs each tick, queues load/unload operations
2. `PortalSystem` preloads destination partition before teleport

## Key Data Structures

### Manifest

```dart
class PartitionManifest {
  final Map<int?, PartitionMetadata> partitions;
  final int lastEntityId;  // Global ID counter
  final int lastTickId;
}

class PartitionMetadata {
  final int? parentEntityId;
  final String fileName;
  final int entityCount;
  final Set<int> childPartitions;  // For tree traversal
}
```

### Partition

```dart
class Partition {
  final int? parentEntityId;
  final Map<String, Map<int, Component>> components;
  final PartitionState state;  // unloaded, loading, loaded, unloading
  final bool isDirty;
}
```

### PartitionManager

```dart
class PartitionManager {
  Future<void> loadPartition(int? parentEntityId);
  Future<void> unloadPartition(int? parentEntityId);
  bool isLoaded(int? parentEntityId);
  Set<int?> get loadedPartitions;
  Set<int?> get dirtyPartitions;
}
```

## Cross-Partition References

Entities may reference IDs in unloaded partitions. Strategy:

1. **Entity IDs remain globally unique** - no translation needed
2. **Reference resolution returns null for unloaded** - `world.getEntityIfLoaded(id)`
3. **Parent stubs** - manifest contains minimal info (name, level) for unloaded parents so hierarchy UI works

## Changes Required

### World (`lib/ecs/world.dart`)
- Add `PartitionManager partitionManager`
- Add `Map<int, int?> _entityToPartition` tracking
- Add `isEntityLoaded(int entityId)` method
- Add `getEntityIfLoaded(int entityId)` method

### HierarchyCache (`lib/ecs/world.dart`)
- Track unloaded parent references
- `rebuild()` only processes loaded entities
- Add `isParentLoaded(int parentId)` method

### Query (`lib/ecs/query.dart`)
- Add `requireLoaded()` option (default true)
- Skip unloaded entities in matching

### VisionSystem (`lib/ecs/systems.dart`)
- Listen for partition load/unload events
- Clear spatial index for unloaded partitions
- Rebuild spatial index for loaded partitions

### PortalSystem (`lib/ecs/systems.dart`)
- Check if destination partition is loaded
- If not, trigger load and defer teleport to next tick

### SaveSystem (`lib/ecs/systems.dart`)
- Save only dirty partitions instead of entire world

### New: ProximityLoadingSystem
- Runs each tick
- Calculates partitions to load/unload based on player location
- Queues async operations

### WorldSaves (`lib/ecs/world.dart`)
- `loadPartition(parentEntityId, initialPath, patchPath)`
- `savePartition(parentEntityId, initialPath, patchPath)`
- Load = read initial JSON, apply patch, merge into World
- Save = diff against initial, write patch

## Implementation Phases

### Phase 1: Data Model
- [ ] Create `Partition`, `PartitionMetadata`, `PartitionManifest` classes
- [ ] Create `PartitionManager` class (load/unload methods)
- [ ] Add `PartitionManager` to `World` (initialized but unused)

### Phase 2: File I/O
- [ ] Implement `WorldSaves.loadPartition()`
- [ ] Implement `WorldSaves.savePartition()`
- [ ] Implement partition export tool (converts current monolithic format)
- [ ] Test with manual load/unload operations

### Phase 3: Integration with Layered Save System
- [ ] Per-partition JSON Patch generation
- [ ] Per-partition patch application on load
- [ ] Migrate file structure to partitioned format

### Phase 4: Proximity Loading
- [ ] Create `ProximityLoadingSystem`
- [ ] Add partition load/unload event streams
- [ ] Update `VisionSystem` for partition events
- [ ] Update `PortalSystem` for async loading

### Phase 5: Query & View Updates
- [ ] Add `requireLoaded()` to `Query`
- [ ] Update `View` to handle partition events
- [ ] Update `HierarchyCache` for partial data

### Phase 6: UI Integration
- [ ] Loading indicators in GameScreen
- [ ] Partition info in hierarchy panel
- [ ] Editor support for per-partition editing

## Verification

1. **Unit tests**: Load partition, unload partition, cross-partition reference resolution
2. **Integration test**: Player walks through portal, destination loads automatically
3. **Memory test**: Verify unloaded partitions are garbage collected
4. **Save test**: Dirty partition saves as patch, clean partitions untouched
5. **Round-trip test**: Save, quit, reload, verify state matches

## Resolved Questions

1. **Async loading**: Blocking. Game tick pauses until partition loads. Simpler implementation; optimize to non-blocking later if needed.

2. **Loading UI**: Deferred. Decide during implementation based on how noticeable the pause is.

## Open Questions

1. **Entity ID allocation**: With partitioned saves, how do we ensure entity IDs remain globally unique when editor creates new entities?

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Partition granularity | One per parent entity | Aligns with existing HasParent scoping |
| Entity ID scope | Globally unique | Avoids translation, cross-refs just work |
| Dirty tracking | Per-partition | Simpler than per-entity, acceptable at this scale |
| Loading trigger | Tree distance + portals | Natural fit for hierarchy structure |
