# Rogueverse - Technical Features & Architecture

**Version**: 1.0  
**Last Updated**: December 2024  
**Purpose**: Technical roadmap aligned with game design pillars

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Core Innovation: Parent-Child Entity Hierarchy](#core-innovation-parent-child-entity-hierarchy)
3. [Implemented Features](#implemented-features)
4. [Feature Roadmap by Phase](#feature-roadmap-by-phase)
5. [Technical Milestones](#technical-milestones)
6. [System Dependencies](#system-dependencies)
7. [Performance Considerations](#performance-considerations)

---

## Architecture Overview

### Technology Stack
- **Language**: Dart 3.x
- **Framework**: Flutter (cross-platform: desktop, mobile, web)
- **Game Engine**: Flame (2D game engine for Flutter)
- **Serialization**: dart_mappable (component serialization/deserialization)
- **Architecture**: Entity-Component-System (ECS)

### ECS Implementation

**Core Classes**:
- `World` - Container for all entities, components, and systems
- `Entity` - Wrapper providing component access for a specific entity ID
- `Component` - Data-only structures implementing the `Component` interface
- `System` - Logic processors that operate on entities with specific components

**Key Design Decisions**:
1. **Intent-based components**: Actions are components (e.g., `MoveByIntent`, `AttackIntent`)
2. **Event components**: Temporary components for notifications (e.g., `DidMove`, `WasAttacked`)
3. **Lifetime management**: `BeforeTick` and `AfterTick` base classes auto-expire components
4. **Stream-based reactivity**: Component changes emit events via `World.onEntityChange()`
5. **Serializable everything**: All components use `@MappableClass()` for save/load

**System Execution Order** (critical for determinism):
```
1. BehaviorSystem      // AI decides actions
2. CollisionSystem     // Check for blocked movement
3. MovementSystem      // Execute movement, update Direction
4. VisionSystem        // Calculate FOV after movement
5. InventorySystem     // Process pickup/drop
6. CombatSystem        // Resolve attacks
```

---

## Core Innovation: Parent-Child Entity Hierarchy

This is the **defining architectural feature** of Rogueverse. It elegantly solves multiple complex problems:
- Ship interiors
- Scale transitions (walking → piloting → interstellar)
- Spatial containment
- Context-scoped rendering and interactions

### The ParentEntity Component

```dart
@MappableClass()
class ParentEntity implements Component {
  final int parentEntityId;  // Which entity contains this entity
  
  ParentEntity(this.parentEntityId);
  
  @override
  String get componentType => "ParentEntity";
}
```

### How It Works

**Fundamental Principle**: Every entity exists **within** another entity (except root entities like galaxies).

**Example Hierarchy**:
```
Galaxy (id: 1, no parent)
└─ StarSystem (id: 2, ParentEntity(1))
   ├─ Planet "Earth" (id: 10, ParentEntity(2))
   │  ├─ House (id: 100, ParentEntity(10), Immovable)
   │  │  ├─ Table (id: 1000, ParentEntity(100))
   │  │  └─ Chest (id: 1001, ParentEntity(100))
   │  ├─ Spaceship "Aurora" (id: 200, ParentEntity(10), Movable)
   │  │  ├─ Player (id: 5000, ParentEntity(200))
   │  │  ├─ Crafting Station (id: 5001, ParentEntity(200))
   │  │  └─ Cargo Crate (id: 5002, ParentEntity(200))
   │  └─ NPC "Merchant" (id: 3000, ParentEntity(10))
   └─ SpaceStation "Haven" (id: 20, ParentEntity(2))
```

### Key Properties

1. **LocalPosition is relative to parent**
   - Player at `LocalPosition(5, 3)` inside Ship means 5 tiles from ship's origin
   - Ship at `LocalPosition(100, 100)` on Planet means 100 tiles from planet's origin

2. **Rendering is scoped by parent**
   - Only render entities where `ParentEntity == currentParentId`
   - When player is on planet (parentId = 10), render all entities with `ParentEntity(10)`
   - When player enters ship (parentId = 200), render all entities with `ParentEntity(200)`

3. **Interactions are scoped by parent**
   - Entities can only see/attack/interact with others sharing the same parent
   - Ship at planet can see other ships at planet (both have `ParentEntity(planetId)`)
   - Player inside ship cannot interact with NPCs on planet (different parents)

4. **Parent changes = transitions**
   - Walking into a ship: `player.upsert(ParentEntity(shipId))`
   - Ship taking off: `ship.upsert(ParentEntity(starSystemId))`
   - This is the core mechanic for all scale transitions

5. **Position inheritance is NOT automatic**
   - When ship moves in space, children's `LocalPosition` within ship is **unchanged**
   - Children move "with" ship implicitly because their parent moved
   - No global position calculation needed (everything is relative)

### Movable vs Immovable Parents

**Movable Parent Entities** (can change their `ParentEntity`):
- Spaceships
- NPCs/Players
- Items (can be picked up, moved between containers)

**Immovable Parent Entities** (never change `ParentEntity` after creation):
- Planets
- Space Stations
- Buildings (houses, factories)
- Fixed structures

### The Autopilot Use Case

This hierarchy enables the signature gameplay feature:

```
1. Player on planet surface (ParentEntity = planetId)
2. Player walks to ship entrance → ParentEntity changes to shipId
3. Player walks to cockpit, activates autopilot
4. Ship.upsert(ParentEntity(starSystemId))  // Ship enters space
5. Autopilot component moves ship toward destination each tick
6. Meanwhile:
   - Player.ParentEntity is still shipId (inside ship)
   - Player walks to crafting station, crafts items
   - Both ship (autopilot) and player (crafting) process independently
7. Ship arrives at destination
8. Ship.upsert(ParentEntity(targetPlanetId))  // Ship lands
9. Player exits ship, back to planet surface
```

### System Implications

**Vision System**:
- Calculate FOV for entities within their parent context
- Ship with `VisionRadius(10)` can see other ships in same star system
- Player with `VisionRadius(5)` can see entities in current parent (ship interior OR planet)

**Movement System**:
- Process all `MoveByIntent` components globally
- But movement is relative to parent's coordinate space
- Collision only checks entities in same parent

**Combat System**:
- Attacks only succeed if attacker and target share parent
- Cannot shoot someone on planet from inside ship

**Rendering**:
- Query: `world.query<LocalPosition>().where((e) => e.get<ParentEntity>()?.parentEntityId == currentParentId)`
- Only draw entities in current context
- Naturally handles interior/exterior separation

---

## Implemented Features

### ✅ Core ECS Infrastructure

**File**: `lib/ecs/ecs.dart`, `lib/ecs/world.dart`, `lib/ecs/entity.dart`

- Entity creation and management
- Component storage with type-safe access
- System execution pipeline
- Change notification streams (`onEntityChange`, `onEntityOnComponent`)
- World serialization/deserialization

**Components**:
- Full component lifecycle management
- `@MappableClass()` annotation for all components
- Auto-generated mappers via `dart_mappable`

### ✅ Movement System

**File**: `lib/ecs/systems.dart` - `MovementSystem`, `CollisionSystem`

**Components**: `LocalPosition`, `MoveByIntent`, `DidMove`, `BlockedMove`, `Direction`, `BlocksMovement`

**Features**:
- Grid-based movement (8-directional)
- Collision detection with blocking entities
- Direction tracking (updates on movement attempts, even when blocked)
- Movement events for downstream systems

**Code Reference**:
```dart
// Movement intent (temporary component)
entity.upsert(MoveByIntent(dx: 1, dy: 0));

// After systems process:
// - If blocked: BlockedMove component added, MoveByIntent removed
// - If successful: LocalPosition updated, DidMove added, Direction updated
```

### ✅ Vision System

**File**: `lib/ecs/systems.dart` - `VisionSystem`

**Components**: `VisionRadius`, `VisibleEntities`, `VisionMemory`, `BlocksSight`

**Features**:
- Field-of-view calculation using Bresenham raycasting
- Directional vision (FOV degrees: 360 = omnidirectional, 90 = narrow cone)
- Line-of-sight blocked by `BlocksSight` entities
- Vision memory (permanent record of seen entities and their last positions)
- Vision-based rendering (see below)

**Code Reference**: `lib/ecs/components.dart:372-443`

### ✅ Vision-Based Rendering

**File**: `lib/game/components/agent.dart`

**Features**:
- Global observer tracking (`GameArea.observerEntityId`)
- Agent opacity based on visibility from observer's perspective:
  - **1.0 opacity**: Currently in observer's `VisibleEntities`
  - **0.3 opacity**: In observer's `VisionMemory` but not currently visible
  - **0.0 opacity**: Never seen by observer
- Position freezing for memory-only entities (render at last-seen position)
- Observer changes automatically update all agent visibility

**Implementation**:
- Agents subscribe to observer's `VisibleEntities` component changes
- Vision cone overlay renders visible tiles with gradient fade
- Fog of war effect for exploration

### ✅ Combat System

**File**: `lib/ecs/systems.dart` - `CombatSystem`

**Components**: `Health`, `AttackIntent`, `DidAttack`, `WasAttacked`, `Dead`, `LootTable`, `Loot`

**Features**:
- Turn-based combat (intent → resolution → events)
- Health pools with damage application
- Death triggers `Dead` component, removes `BlocksMovement`
- Loot generation on death with probability-based drops
- Combat events for UI feedback

**Limitation**: Current damage is hardcoded to 1. Needs `Damage` component and weapon stats.

### ✅ Inventory System

**File**: `lib/ecs/systems.dart` - `InventorySystem`

**Components**: `Inventory`, `InventoryMaxCount`, `Pickupable`, `PickupIntent`, `PickedUp`, `InventoryFullFailure`

**Features**:
- Entity-based items (items are entities with `Pickupable`)
- Container entities with capacity limits
- Same-tile pickup requirement
- Items lose `Renderable` and `LocalPosition` when picked up (removed from world)
- Inventory overflow prevention with failure events

**Code Reference**: `lib/ecs/systems.dart:110-166`

### ✅ AI Behavior System

**File**: `lib/ecs/ai/nodes.dart`, `lib/ecs/ai/behaviors.dart`, `lib/ecs/systems.dart` - `BehaviorSystem`

**Components**: `AiControlled`, `Behavior`

**Features**:
- Behavior tree implementation (Success/Failure/Running states)
- Composite nodes: `SequenceNode`, `SelectorNode`
- Decorator nodes: `InverterNode`, `RepeatNode`, `UntilFailNode`
- Leaf nodes: `MoveRandomlyNode`, `MoveTowardsNode`
- Extensible node system for custom behaviors

**Example**:
```dart
entity.add([
  AiControlled(),
  Behavior(MoveRandomlyNode()),
]);
```

### ✅ Entity Template System

**File**: `lib/ecs/entity_template.dart`, `lib/ecs/template_registry.dart`

**Features**:
- Reusable entity blueprints
- Template editor UI (inspector panel integration)
- Save/load templates
- Spawn entities from templates
- Auto-save on template edit

**UI Components**: `lib/app/widgets/overlays/template_panel/`

### ✅ Rendering & UI

**Files**: `lib/game/components/`, `lib/app/widgets/`

**Features**:
- SVG-based rendering for all entities
- Camera controls (zoom, pan)
- Entity inspector panel (shows all components, allows editing)
- Template panel (create/edit/spawn templates)
- Inventory overlay (tab to open)
- Health bars above agents
- Hover tooltips (entity names)
- Grid visualization (click to inspect tiles)

### ✅ Player Controls

**File**: `lib/game/components/player.dart`

**Keybindings**:
- WASD: Movement
- E: Interact (pickup items at current position)
- Tab: Toggle inventory
- Space: Manual tick (for debugging)
- Click: Select entity for inspector

---

## Feature Roadmap by Phase

### Phase 0: Foundation (COMPLETE)
Status: ✅ All features implemented

- [x] ECS architecture with dart_mappable serialization
- [x] World save/load system
- [x] Grid-based movement with collision
- [x] Vision system with FOV, line-of-sight, and memory
- [x] Vision-based rendering (opacity by visibility)
- [x] Turn-based combat
- [x] Inventory with pickup/drop
- [x] Behavior tree AI
- [x] Entity template system
- [x] Basic UI (inspector, inventory, health bars)

### Phase 1: Parent-Child Hierarchy 🎯 CURRENT PRIORITY

**Goal**: Implement the foundational parent-child entity system that enables all future spatial features.

**Components to Create**:
- [x] `ParentEntity(int parentEntityId)` - Already conceptualized, needs implementation
- [ ] `Immovable` - Marker component for entities that never change parent
- [ ] `Docked(int dockTargetId)` - For ships docked at stations/planets

**Systems to Modify**:
- [ ] **RenderingSystem** - Filter entities by current parent before rendering
  - Query: `entities.where((e) => e.get<ParentEntity>()?.parentEntityId == currentParentId)`
  - Add `GameArea.currentParentId` to track which context player is in

- [ ] **VisionSystem** - Scope vision calculations to same parent
  - Only calculate visibility for entities sharing parent
  - Ship sensors see other ships in star system
  - Player eyes see entities on planet/inside ship

- [ ] **MovementSystem** - Already works (LocalPosition is relative)
  - No changes needed! Movement is naturally relative to parent

- [ ] **CollisionSystem** - Only check collisions within same parent
  - Filter blocking entities by parent before collision check

- [ ] **CombatSystem** - Only allow attacks within same parent
  - Check attacker and target share `ParentEntity` value

- [ ] **InventorySystem** - Already works (items have no position when in inventory)

**New Systems**:
- [ ] **TransitionSystem** - Handles parent changes
  - Detect player entering "doorway" entities (ships, buildings)
  - Change player's `ParentEntity` and adjust `LocalPosition`
  - Example: Player walks onto ship entrance tile → `player.upsert(ParentEntity(shipId))`

**Features**:
- [ ] Create root entities (Galaxy, StarSystem, Planet)
- [ ] Player can transition between contexts (planet ↔ ship interior)
- [ ] Rendering switches based on player's current parent
- [ ] Camera tracks player in current context

**Testing Milestones**:
1. Player on planet, ship on planet (both `ParentEntity(planetId)`)
2. Player can see ship as external entity on planet
3. Player walks to ship entrance → enters ship (`ParentEntity(shipId)`)
4. Rendering switches to ship interior
5. Player can walk around inside ship
6. Player exits ship → back to planet surface

**File Changes**:
- `lib/ecs/components.dart` - Add new components
- `lib/ecs/systems.dart` - Modify existing systems, add TransitionSystem
- `lib/game/game_area.dart` - Add `currentParentId` tracking
- `lib/app/screens/game_screen.dart` - Update rendering logic

### Phase 2: Spaceships & Travel

**Goal**: Ships become movable parent entities with autopilot.

**Components to Create**:
- [ ] `ShipStats(speed, fuelCapacity, cargoCapacity)`
- [ ] `Fuel(current, max)`
- [ ] `Autopilot(targetParentId, targetPosition, active)`
- [ ] `ShipEngine(thrust, fuelConsumption)`
- [ ] `ShipSensors(sensorRange)` - Extends `VisionRadius` for ships
- [ ] `Cockpit` - Marker for "control seat" tile in ship
- [ ] `PilotingShip(shipId)` - Component on player when controlling ship

**Systems to Create**:
- [ ] **AutopilotSystem** - Moves ships with active autopilot
  - Generates `MoveByIntent` for ship entity
  - Checks fuel consumption
  - Handles arrival (deactivates autopilot)

- [ ] **ShipControlSystem** - Player input controls ship when piloting
  - When player on `Cockpit` tile, ship controls become active
  - Movement keys move ship instead of player
  - Exit cockpit to return to normal player control

**Features**:
- [ ] Ship entity template with interior layout
- [ ] Player can "pilot" ship (sit in cockpit, control ship movement)
- [ ] Autopilot: Set destination, ship moves autonomously
- [ ] While autopilot active, player can walk around ship interior
- [ ] Fuel system (movement consumes fuel)
- [ ] Ship takes off from planet (changes parent to star system)
- [ ] Ship lands on planet (changes parent to planet)

**Testing Milestones**:
1. Create ship entity on planet with interior (cockpit, storage, crafting station)
2. Player enters ship
3. Player sits in cockpit, pilots ship manually
4. Ship takes off (parent changes to star system)
5. Player sets autopilot to target destination
6. Player walks away from cockpit, crafts while ship travels
7. Ship arrives, player pilots it to land on target planet

**File Changes**:
- `lib/ecs/components.dart` - Ship-specific components
- `lib/ecs/systems.dart` - AutopilotSystem, ShipControlSystem
- Create ship entity templates with interior layouts

### Phase 3: Skills & Progression

**Goal**: Runescape-style skill system with use-based progression.

**Components to Create**:
- [ ] `Skills(Map<SkillType, SkillData>)` - Container for all skills
- [ ] `SkillData(level, xp, xpToNext)` - Per-skill data
- [ ] `SkillType` enum: Mining, Combat, Crafting, Stealth, Piloting, Trading, etc.
- [ ] `GainedXP(SkillType skill, int amount)` - Event component
- [ ] `LevelUp(SkillType skill, int newLevel)` - Event component

**Components to Modify**:
- [ ] `Mineable(resourceType, baseYield, requiredLevel)` - Mark ore nodes
- [ ] `Tool(toolType, skillBonus)` - Pickaxes, weapons, etc.
- [ ] `Recipe(requiredSkills, inputs, outputs)` - Crafting recipes

**Systems to Create**:
- [ ] **SkillSystem** - Processes XP gains and level-ups
  - Listens for skill-granting events (mined ore, killed enemy, crafted item)
  - Awards XP based on action
  - Checks for level-up, emits `LevelUp` event

- [ ] **MiningSystem** - Resource gathering
  - `MineIntent(targetId)` component
  - Check player has tool, target is `Mineable`, skill level sufficient
  - Generate resources, award Mining XP
  - Higher skill = better yield

- [ ] **CraftingSystem** - Combine items into new items
  - `CraftIntent(recipeId)` component
  - Check player has required items and skill level
  - Consume inputs, create outputs, award Crafting XP

**Features**:
- [ ] Mining ore nodes (asteroids, planetside ore)
- [ ] Crafting recipes (ore → bars, bars → equipment)
- [ ] Tool effectiveness based on skill level
- [ ] XP gains visible in UI
- [ ] Level-up notifications

**Testing Milestones**:
1. Player mines ore node → gains Mining XP
2. Mining skill levels up after sufficient XP
3. Higher level unlocks better ore yields
4. Player crafts ore into metal bars → gains Crafting XP
5. Skills persist through save/load

### Phase 4: Stealth & Social

**Goal**: Stealth mechanics leveraging vision system.

**Components to Create**:
- [ ] `Stealth(level)` - Player's stealth skill
- [ ] `Hidden` - Entity is attempting to hide
- [ ] `Alert(targetId, alertLevel)` - NPC awareness state
- [ ] `AlertLevel` enum: Unaware, Suspicious, Hostile
- [ ] `Lockpick(difficulty)` - Component on locked containers
- [ ] `LockpickIntent(targetId)` - Player attempting to pick lock

**Systems to Create**:
- [ ] **StealthSystem** - Modifies vision based on stealth
  - Entities with `Hidden` reduce their "visibility range"
  - NPCs may not see player if player's stealth > NPC's perception
  - Movement breaks stealth (removes `Hidden`)

- [ ] **AlertSystem** - NPC reaction to player
  - When NPC's `VisibleEntities` includes player → set `Alert(playerId, Suspicious)`
  - If player attacks → `Alert(playerId, Hostile)`
  - Hostile NPCs chase player using behavior tree
  - If player leaves vision for N ticks → return to Unaware

- [ ] **LockpickSystem** - Unlock containers
  - `LockpickIntent` component with target
  - Skill check: Stealth level vs lock difficulty
  - Success: Remove `Lockpick` component, grant access
  - Failure: Chance to alert nearby NPCs

**Features**:
- [ ] Crouch/hide mechanic (adds `Hidden` component)
- [ ] Sneak attacks (bonus damage when attacking from stealth)
- [ ] Pickpocketing (steal from NPC inventory when hidden)
- [ ] Lockpicking (open locked containers/doors)
- [ ] NPC alert states (patrol, investigate, hostile)

**Testing Milestones**:
1. Player enters stealth mode (hidden from NPC vision)
2. Player sneaks past NPC without being detected
3. Player performs sneak attack (extra damage)
4. NPC becomes alert, searches for player
5. Player escapes, NPC returns to patrol

### Phase 5: Economy & Trading

**Goal**: Merchant NPCs and player-driven economy.

**Components to Create**:
- [ ] `Currency(amount)` - Money component
- [ ] `Merchant(inventoryId, priceListId)` - NPC sells/buys items
- [ ] `Price(baseCost, sellMultiplier, buyMultiplier)`
- [ ] `TradeIntent(merchantId, action, itemId)` - Player trade action
- [ ] `Contract(title, description, reward, objectives)` - Mission data

**Systems to Create**:
- [ ] **TradingSystem** - Handle buy/sell transactions
  - `TradeIntent` with buy/sell action
  - Check player has currency (buy) or item (sell)
  - Transfer item and currency
  - Update merchant inventory

- [ ] **ContractSystem** - Mission objectives and rewards
  - Track contract progress (items delivered, enemies killed, etc.)
  - Award currency/XP/items on completion

**Features**:
- [ ] Merchant NPCs with inventory and prices
- [ ] Buy/sell items for currency
- [ ] Contracts/missions (deliver cargo, kill enemies, mine resources)
- [ ] Dynamic pricing (skill-based discounts, supply/demand - stretch goal)

### Phase 6: World Expansion

**Goal**: Procedural generation and multiple locations.

**Features**:
- [ ] Procedural cave generation (dungeons on planets)
- [ ] Asteroid field generation (mineable resources in space)
- [ ] Multiple planets in star system
- [ ] Space stations (with interiors, docking bays)
- [ ] Derelict ships to explore and salvage

**Systems**:
- [ ] **ProceduralGenerationSystem** - Creates dungeon layouts
- [ ] **RegionLoadingSystem** - Load/unload regions based on proximity

---

## Technical Milestones

### Milestone 1: Parent-Child MVP ✅ NEXT
**Target**: Demonstrate player entering/exiting ship

**Success Criteria**:
- Player on planet can see ship as entity
- Player walks to ship, transitions to ship interior
- Rendering switches context correctly
- Player exits ship, returns to planet

**Deliverables**:
- `ParentEntity` component implemented
- TransitionSystem functional
- Rendering filters by parent
- Test scene with planet + ship + interior

### Milestone 2: Space Travel
**Target**: Ship can fly between locations

**Success Criteria**:
- Ship takes off from planet (parent changes to star system)
- Autopilot moves ship through space
- Player can walk around inside ship while it's moving
- Ship lands on target planet

**Deliverables**:
- AutopilotSystem functional
- Ship entity templates
- Fuel system
- Test scene with planet → space → planet journey

### Milestone 3: Skills & Crafting
**Target**: Complete gameplay loop of gathering → processing → using

**Success Criteria**:
- Mine ore from asteroids
- Smelt ore into bars
- Craft bars into equipment
- Skills level up through use
- Equipment provides stat bonuses

**Deliverables**:
- SkillSystem, MiningSystem, CraftingSystem
- Skill UI showing levels/XP
- Recipe system
- Test progression from level 1 mining to level 10

### Milestone 4: Stealth Gameplay
**Target**: Sneak mission gameplay works

**Success Criteria**:
- Sneak past patrolling NPCs
- Perform sneak attack for bonus damage
- Pickpocket NPC without detection
- Pick lock on secure container
- Escape when detected

**Deliverables**:
- StealthSystem, AlertSystem, LockpickSystem
- NPC behavior trees for patrol/investigate/chase
- Stealth UI indicators
- Test stealth mission scenario

### Milestone 5: Economy Loop
**Target**: Trade and contracts create gameplay incentive

**Success Criteria**:
- Accept contract from station
- Gather required resources/complete objectives
- Return to station, complete contract
- Receive payment and reputation
- Use currency to buy better equipment/ship upgrades

**Deliverables**:
- TradingSystem, ContractSystem
- Merchant NPCs at stations
- Contract board UI
- Test full economy loop

---

## System Dependencies

This diagram shows which systems depend on others:

```
ParentEntity Component (Phase 1)
├─ TransitionSystem
├─ RenderingSystem (modified)
├─ VisionSystem (modified)
├─ CollisionSystem (modified)
└─ CombatSystem (modified)

VisionSystem
├─ StealthSystem (Phase 4)
├─ AlertSystem (Phase 4)
└─ Vision-based rendering (Phase 0) ✅

MovementSystem
├─ AutopilotSystem (Phase 2)
└─ ShipControlSystem (Phase 2)

InventorySystem
├─ TradingSystem (Phase 5)
├─ CraftingSystem (Phase 3)
└─ MiningSystem (Phase 3)

Skills Component (Phase 3)
├─ All skill-granting systems
├─ MiningSystem
├─ CraftingSystem
└─ StealthSystem

Behavior Trees (Phase 0) ✅
├─ AlertSystem (Phase 4)
└─ All NPC behaviors
```

**Critical Path**: Phase 1 (ParentEntity) must be completed before Phase 2 (Spaceships), as ships rely on the parent-child hierarchy.

---

## Performance Considerations

### Current Architecture Strengths
- Component queries are fast (Map-based lookups)
- Systems only process relevant entities
- Serialization is efficient (dart_mappable)

### Potential Bottlenecks
1. **Large Entity Counts**
   - Star systems could have thousands of entities (asteroids, ships, stations)
   - Solution: Spatial partitioning (only process nearby entities)

2. **Vision Calculations**
   - Bresenham raycasting for every observer every tick
   - Solution: Cache results, only recalculate on movement

3. **Rendering All Entities**
   - Even with parent filtering, interiors could have 100+ entities
   - Solution: Frustum culling (only render visible screen area)

4. **Save/Load Performance**
   - Serializing entire world state could be slow
   - Solution: Incremental saves, region-based loading

### Optimization Strategies

**Phase 1-2 (No optimization needed)**:
- Small entity counts (< 1000 entities)
- Simple scenes (single planet, one ship)

**Phase 3-4 (Monitor performance)**:
- Profile entity counts
- Add metrics logging
- Identify slow systems

**Phase 5-6 (Optimize if needed)**:
- Spatial partitioning grid (query entities by region)
- Lazy loading (only load regions near player)
- Object pooling (reuse entity IDs)
- Incremental serialization (only save changed entities)

### Target Performance
- **Desktop**: 60 FPS with 5000 entities
- **Mobile**: 30 FPS with 2000 entities
- **Save/Load**: < 2 seconds for full world state

---

## Development Guidelines

### When Adding New Features

1. **Design the components first**
   - What data needs to be stored?
   - Is this a persistent or transient component?
   - Add `@MappableClass()` annotation

2. **Consider system execution order**
   - Which systems need to run before/after this one?
   - Update `GameArea` system list if needed

3. **Update GAME_DESIGN.md**
   - Does this feature align with core pillars?
   - Update relevant sections

4. **Add to this roadmap**
   - Document the new system
   - Note dependencies on other systems

5. **Write tests** (aspirational)
   - Unit tests for system logic
   - Integration tests for component interactions

### Code Organization

```
lib/
  ecs/               # Core ECS engine
    components.dart  # All component definitions
    systems.dart     # All system implementations
    world.dart       # World and entity management
    ai/              # Behavior tree nodes
  game/              # Flame-specific rendering
    components/      # Flame components (Agent, VisionCone, etc.)
    game_area.dart   # Main game coordinator
  app/               # UI and screens
    screens/         # Game screen, menus
    widgets/         # Inspector, inventory, overlays
```

### Component Naming Conventions

- **Data**: `Health`, `Position`, `VisionRadius`
- **Markers**: `PlayerControlled`, `Pickupable`, `Immovable`
- **Intents**: `MoveByIntent`, `AttackIntent`, `PickupIntent`
- **Events**: `DidMove`, `WasAttacked`, `GainedXP`

### System Naming Conventions

- **Processing**: `MovementSystem`, `CombatSystem`, `VisionSystem`
- **Management**: `SkillSystem`, `InventorySystem`
- **Special**: `BehaviorSystem` (runs AI), `TransitionSystem` (handles parent changes)

---

## Next Steps

**Immediate Priority**: Implement Phase 1 (Parent-Child Hierarchy)

1. Create `ParentEntity` component in `lib/ecs/components.dart`
2. Add `currentParentId` tracking to `GameArea`
3. Create simple test scene:
   - Root entity: Planet
   - Child entity: Ship (with interior layout)
   - Player entity (starts on planet)
4. Implement TransitionSystem for entering/exiting ship
5. Modify rendering to filter by parent
6. Test player transitioning between contexts

**Then**: Once Phase 1 works, proceed to Phase 2 (Spaceships & Autopilot)

---

## Questions for Future Consideration

- How many star systems? (Single system MVP vs multi-system)
- Procedural generation depth? (Simple caves vs complex dungeons)
- Ship customization? (Fixed layouts vs player-designed interiors)
- NPC simulation depth? (Simple behaviors vs complex needs/schedules)
- Multiplayer potential? (Design for single-player first, but keep it possible?)

These will be revisited as phases are completed and design evolves.
