# Layered Game State Architecture

## Status: Draft / Planning

## Problem Statement

The current save system conflates initial game state (authored level content) with save state (player progress). Both `SaveSystem` and `WorldSaves` treat the entire world as a single JSON blob, making it impossible to:

1. Distinguish designed content from runtime changes
2. Edit initial game state without affecting player saves
3. Support future modding (mods as patches to base content)

## Proposed Architecture

```
┌─────────────────────────────────────────┐
│         Current In-Memory State         │
└─────────────────────────────────────────┘
                    ▲
                    │ apply patch
┌───────────────────┴─────────────────────┐
│     Save State (JSON Patch file)        │
│     - Player position changes           │
│     - Inventory changes                 │
│     - Entity state modifications        │
└─────────────────────────────────────────┘
                    ▲
                    │ base
┌─────────────────────────────────────────┐
│     Initial State (complete JSON)       │
│     - Level design / authored content   │
│     - Editor operates ONLY on this      │
└─────────────────────────────────────────┘
```

### Key Behaviors

1. **Game load**: Read initial JSON → apply save patch → in-memory state
2. **Game save**: Diff(initial state, current state) → write patch file
3. **Enter Editor**: Stash current state temporarily, reload pure initial state
4. **Editor save**: Write directly to initial state JSON (complete file)
5. **Exit Editor**: Reload (newly saved initial state + existing save patch)

### File Structure

```
<app_support_dir>/
├── initial.json      # Complete world state (editor-managed)
├── save.patch.json   # JSON Patch (RFC 6902) of changes from initial
└── (future: saves/slot_1.patch.json, saves/slot_2.patch.json, etc.)
```

## Design Decisions

### Save Patch Invalidation

**Decision**: MVP approach - attempt to apply patch, error if it fails.

No fancy migration, recovery, or partial application. If the initial state changes in a way that makes the save patch invalid (e.g., references deleted entities), the load will fail and the player will need to start fresh.

Future consideration: Could warn user before editor save if a save patch exists.

### Multiple Save Slots

**Decision**: Single save slot for MVP, but architecture should not preclude multiple slots.

The save/load methods should accept an optional slot identifier that defaults to the single slot.

### Editor Preview Mode

**Decision**: Not implementing. Editor mode disables gameplay controls; this is sufficient.

### Mod Support

**Decision**: Keep in mind but don't implement yet.

Mods would be additional JSON patches applied in some order relative to save patches. The layering order (mods before saves? after? configurable?) is TBD.

Conceptual future flow:
```
initial.json → mod_1.patch.json → mod_2.patch.json → save.patch.json → in-memory
```

## Implementation Plan

### Phase 1: Add JSON Patch Dependency

- [ ] Add `json_patch: ^3.0.0` dependency to pubspec.yaml
- [ ] Verify integration with basic test

**Library Choice: `json_patch`** ([pub.dev](https://pub.dev/packages/json_patch), [GitHub](https://github.com/pikaju/dart-json-patch))

| Evaluated | Version | Diff | Apply | Status |
|-----------|---------|------|-------|--------|
| **json_patch** (chosen) | 3.0.0 | Yes | Yes | Stable, null-safe |
| rfc_6902 | 0.3.1 | No | Yes | Active |
| json_diff (Google) | 0.2.1 | Custom format | No | Archived |

Rationale: Only library supporting both `JsonPatch.diff(old, new)` and `JsonPatch.apply(json, patches)`. RFC 6902 is a stable standard unlikely to need updates. If issues arise, we can swap in `rfc_6902` for apply and write custom diff logic.

API usage:
```dart
// Compute diff (returns List of patch operations)
final ops = JsonPatch.diff(initialJson, currentJson);

// Apply patch
final patchedJson = JsonPatch.apply(initialJson, ops, strict: false);
```

### Phase 2: Refactor WorldSaves

- [ ] Rename current `save.json` to `initial.json` (or introduce new naming)
- [ ] Add method: `loadInitialState()` - loads only the initial.json
- [ ] Add method: `loadSaveWithPatch()` - loads initial + applies patch
- [ ] Add method: `writeSavePatch(World current, World initial)` - computes and writes diff
- [ ] Keep existing `writeSave()` for writing complete initial state (editor use)
- [ ] Store reference to initial state JSON (or parsed Map) in memory for diffing

### Phase 3: Update SaveSystem

- [ ] Modify `SaveSystem.update()` to use `writeSavePatch()` instead of full save
- [ ] Ensure initial state reference is available for diff computation

### Phase 4: Update Game Initialization

- [ ] Modify game startup to use `loadSaveWithPatch()` flow
- [ ] Handle case where save.patch.json doesn't exist (fresh game)
- [ ] Handle case where patch application fails (error/fallback to initial only)

### Phase 5: Editor Mode Integration

- [ ] On entering editor mode:
  - Auto-save current progress as patch (preserves player progress)
  - Reload pure initial state into World
- [ ] On editor save:
  - Write complete state to initial.json via existing `writeSave()`
- [ ] On exiting editor mode:
  - Reload initial.json
  - Apply existing save.patch.json (may fail if editor changes conflict)
  - Resume gameplay with merged state

### Phase 6: Testing & Edge Cases

- [ ] Test: Fresh game (no save patch exists)
- [ ] Test: Game with existing save patch
- [ ] Test: Editor modifies initial state, save patch still applies cleanly
- [ ] Test: Editor modifies initial state, save patch conflicts (expect error)
- [ ] Test: Round-trip - play, save, quit, reload, verify state matches

## Resolved Questions

1. **Initial state source**: No bundled initial state. On first run, if `initial.json` doesn't exist, start with an empty world state. The editor creates the initial content.

2. **Editor entry with unsaved changes**: Auto-save the patch before entering editor mode. This preserves player progress and ensures clean editor state.

## Open Questions

1. **Patch format details**: Should we store the patch as-is from the library, or wrap it with metadata (version, timestamp, etc.)?

2. **In-memory initial state**: Do we keep the parsed initial state in memory for fast diffing, or re-read from disk each save? (Memory vs I/O tradeoff)

## Dependencies

- **New**: `json_patch: ^3.0.0` - RFC 6902 diff and apply
- Existing: `dart_mappable` for serialization
- Existing: `path_provider` for file paths

## Future Considerations

- Multiple save slots (slot_1.patch.json, slot_2.patch.json, etc.)
- Mod support (mod patches applied between initial and save)
- Save patch versioning/migration
- Compressed patches for large worlds
- Cloud save sync (patches are smaller = faster sync)
