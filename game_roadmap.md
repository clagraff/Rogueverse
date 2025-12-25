# 🎮 Rogueverse Development Roadmap

This roadmap tracks completed features and outlines the next steps for building a turn-based roguelike with ECS architecture, vision systems, and AI behaviors.

---

## ✅ Completed Features

### Core ECS Architecture
- [x] **Entity-Component-System foundation** – Full ECS with dart_mappable serialization
- [x] **Component lifecycle** – BeforeTick/AfterTick components with automatic cleanup
- [x] **World serialization** – Save/load game state to local storage
- [x] **Entity templating** – Create and edit reusable entity templates
- [x] **Change tracking** – Stream-based component change notifications

### Movement & Navigation
- [x] **Grid-based movement** – 8-directional movement with MoveByIntent
- [x] **Direction tracking** – CompassDirection component updated on movement attempts
- [x] **Collision system** – BlocksMovement component with collision detection
- [x] **Movement events** – DidMove and BlockedMove event components

### Vision System
- [x] **Vision radius** – Configurable vision range and field-of-view (FOV) degrees
- [x] **Line-of-sight** – Bresenham raycasting with BlocksSight obstacles
- [x] **Vision memory** – Persistent memory of previously seen entities and positions
- [x] **Vision-based rendering** – Entities rendered with opacity based on visibility:
  - Fully visible: 1.0 opacity + position updates
  - In memory: 0.3 opacity + frozen at last-seen position
  - Never seen: 0.0 opacity (invisible)
- [x] **Vision cone overlay** – Yellow gradient showing visible tiles from player perspective
- [x] **Observer tracking** – Global observer entity ID (defaults to player)

### Combat System
- [x] **Health component** – Current/max HP tracking
- [x] **Attack intents** – AttackIntent component for targeting
- [x] **Combat resolution** – Damage application and death handling
- [x] **Combat events** – DidAttack and WasAttacked event components
- [x] **Loot drops** – LootTable with probability-based drops on death
- [x] **Health bars** – Visual HP bars above agents

### Inventory System
- [x] **Inventory component** – Store list of entity IDs
- [x] **Inventory capacity** – InventoryMaxCount with overflow prevention
- [x] **Pickupable items** – Mark entities as collectible
- [x] **Pickup system** – PickupIntent with same-tile requirement
- [x] **Inventory events** – PickedUp and InventoryFullFailure components
- [x] **Inventory UI** – Tab-based overlay showing collected items

### AI & Behaviors
- [x] **Behavior tree system** – Node-based AI with Success/Failure/Running states
- [x] **Composite nodes** – Sequence and Selector for control flow
- [x] **Decorator nodes** – Inverter, Repeat, UntilFail for behavior modification
- [x] **Leaf nodes** – MoveRandomly, MoveTowards, and custom action nodes
- [x] **AI controller** – AiControlled component with BehaviorSystem execution

### Rendering & UI
- [x] **SVG rendering** – Vector graphics support for all entities
- [x] **Camera controls** – Zoom and pan with scroll/drag
- [x] **Entity inspector** – Debug panel showing all components
- [x] **Template panel** – UI for creating/editing entity templates
- [x] **Hover tooltips** – Entity names on mouse hover
- [x] **Grid visualization** – Click-to-inspect grid tiles

### Player Controls
- [x] **WASD movement** – Keyboard input for player movement
- [x] **E to interact** – Pickup items at player's position
- [x] **Tab for inventory** – Toggle inventory overlay
- [x] **Space to tick** – Manual turn advancement (for debugging)
- [x] **Click to inspect** – Select entities for inspector panel

---

## 🚧 Current Issues & Technical Debt

### Known Bugs
- [ ] **Dead entities linger** – Corpse rendering needs improvement (agent.dart:31)
- [ ] **Loot spawns without position** – Dropped loot doesn't get LocalPosition component
- [ ] **World.components direct mutation** – Bypasses change notifications (systems.dart:203)
- [ ] **No turn order system** – All AI acts simultaneously, not in speed-based order

### Code Quality
- [ ] **EventBus system commented out** – Old event system disabled, needs removal or restoration
- [ ] **Unused local variables** – Several analyzer warnings (game_screen.dart:139)
- [ ] **TODO comments** – Multiple TODOs in codebase need addressing

---

## 🎯 Phase 1: Vision & Rendering Polish

### High Priority
- [ ] **Fix loot drop positioning** – Dropped items should appear at dead entity's position
  - Modify CombatSystem to copy LocalPosition to spawned loot items
  - Test with mineral entities (which have LootTable)

- [ ] **Improve death handling** – Better corpse visualization
  - Option A: Fade out corpses over time
  - Option B: Replace with corpse sprite at reduced opacity
  - Option C: Remove from rendering but keep in ECS for looting

- [ ] **Vision memory decay** (optional enhancement)
  - Add timestamp to VisionMemory entries
  - Gradually fade out very old memories
  - Or: Keep permanent memory but add "staleness" visual indicator

### Medium Priority
- [ ] **Multi-entity vision cones** – Toggle between different entity perspectives
  - Add UI controls to switch observer entity
  - Useful for debugging AI vision

- [ ] **Vision-based AI reactions** – NPCs should react to what they see
  - Alert state when player enters vision
  - Chase behavior when target is visible
  - Return to patrol when target leaves vision

---

## 🎯 Phase 2: AI Behaviors & Combat Depth

### High Priority
- [ ] **Implement flee behavior** – Low HP entities should run away
  - Create FleeFromNode behavior tree node
  - Finds entities with Health below threshold
  - Moves in opposite direction from threat

- [ ] **Implement chase behavior** – Pursue visible targets
  - Create ChaseTargetNode using VisibleEntities
  - Pathfinding to move toward target
  - Switch to attack when adjacent

- [ ] **Alert/patrol states** – More sophisticated NPC behaviors
  - Idle/Patrol: wander randomly
  - Alert: investigate last-seen position
  - Combat: chase and attack

### Medium Priority
- [ ] **Damage calculation** – More than just "-1 HP"
  - Add Damage component with amount
  - Add Weapon component with damage values
  - Add Attributes (Strength) to modify damage

- [ ] **Attack cooldowns** – Prevent attacking every turn
  - Add AttackCooldown component
  - Decrement each tick
  - Only allow AttackIntent when cooldown <= 0

- [ ] **Status effects** – Poison, slow, stun, etc.
  - Use BeforeTick/AfterTick lifetime system
  - Apply damage or movement penalties each tick

---

## 🎯 Phase 3: Skills & Progression

### Easy Wins
- [ ] **Add XP component** – Track experience points
- [ ] **Gain XP on combat** – Award XP when entities die
- [ ] **Add Attributes component** – Strength, Dexterity, Intelligence, etc.
- [ ] **Mining skill** – Add Mining component with level/XP

### Medium Priority
- [ ] **Level-up system** – Gain attribute points on level up
- [ ] **Skill checks** – Mining level affects ore yield
- [ ] **Equipment slots** – Weapon, armor, accessories
- [ ] **Stat bonuses from equipment** – Equipped items modify attributes

---

## 🎯 Phase 4: World Systems

### Crafting & Resources
- [ ] **Mineable component** – Tag ore nodes as minable
- [ ] **Tool component** – Pickaxes increase mining yield
- [ ] **Mining interaction** – E key to mine when adjacent
- [ ] **Smelter entity** – Convert ore to bars via interaction
- [ ] **Crafting recipes** – Combine items to create new ones

### Economy
- [ ] **Merchant component** – NPCs that buy/sell items
- [ ] **Currency component** – Gold/coins for trading
- [ ] **Price system** – Items have value
- [ ] **Trading UI** – Interface for buy/sell interactions
- [ ] **Dynamic prices** – Charisma affects prices

---

## 🎯 Phase 5: World Expansion

### Regions & Chunks
- [ ] **RegionId component** – Separate indoor/outdoor areas
- [ ] **Cell transitions** – Doors/stairs that change regions
- [ ] **Multi-region rendering** – Only render current region
- [ ] **Region persistence** – Keep non-active regions in memory

### Time & Simulation
- [ ] **Turn order system** – Speed attribute determines turn order
- [ ] **Action points** – Some actions cost more than others
- [ ] **Time passage** – Track game time (ticks → minutes → hours)
- [ ] **Day/night cycle** – Affects vision, NPC behaviors
- [ ] **Background simulation** – NPCs act even when off-screen

---

## 🛠 Technical Improvements

### Architecture
- [ ] **Event system cleanup** – Remove or restore commented EventBus code
- [ ] **System ordering** – Formalize system execution order dependencies
- [ ] **Query optimization** – Cache query results for performance
- [ ] **Spatial partitioning** – Grid-based entity lookup for large worlds

### Developer Experience
- [ ] **Automated tests** – Unit tests for systems and components
- [ ] **Behavior tree debugger** – Visualize AI decision-making
- [ ] **Performance profiling** – Identify bottlenecks
- [ ] **Hot reload support** – Better development iteration

### Code Quality
- [ ] **Remove all TODO comments** – Address or delete
- [ ] **Fix analyzer warnings** – Clean code
- [ ] **Documentation** – Add dartdoc comments to public APIs
- [ ] **Consistent naming** – Follow Dart conventions throughout

---

## 📝 Next Immediate Steps (Priority Order)

1. **Fix loot positioning bug** – Ensure dropped items spawn at correct position
2. **Improve death/corpse handling** – Better visual feedback for dead entities
3. **Implement flee behavior** – NPCs should run when low HP
4. **Add vision-based chase** – NPCs pursue visible targets
5. **Fix direct world.components mutation** – Use proper notification system

---

## 🎓 Learning Goals

This project demonstrates:
- ✅ ECS architecture in Dart/Flutter
- ✅ Turn-based game systems
- ✅ Vision/line-of-sight algorithms (Bresenham raycasting)
- ✅ Behavior trees for AI
- ✅ Component-based serialization
- 🚧 Pathfinding algorithms (A* for chase behavior)
- 🚧 Procedural generation (future: dungeon generation)
- 🚧 State machines (future: complex NPC states)

---

## 📊 Feature Completeness

| System | Status | Completeness |
|--------|--------|--------------|
| ECS Core | ✅ Complete | 95% |
| Movement | ✅ Complete | 100% |
| Vision | ✅ Complete | 90% |
| Combat | ⚠️ Functional | 60% |
| AI | ⚠️ Basic | 40% |
| Inventory | ✅ Complete | 85% |
| UI/Rendering | ⚠️ Functional | 70% |
| Progression | ❌ Not Started | 0% |
| Crafting | ❌ Not Started | 0% |
| World/Regions | ❌ Not Started | 0% |

**Overall Progress: ~45% toward full roguelike**
