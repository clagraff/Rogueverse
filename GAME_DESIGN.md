# Rogueverse - Game Design Document

**Version**: 1.0  
**Last Updated**: December 2024  
**Status**: Proof of Concept / Active Development

---

## Vision Statement

**Rogueverse** is a space exploration roguelike that merges the systemic depth of Dwarf Fortress with the ambitious scope of Star Citizen, presented through the lens of classic ASCII space sims like ASCII Sector. It's a living universe where every entity—from a single wrench to a massive space station—exists within an emergent parent-child hierarchy, enabling seamless transitions between piloting starships through asteroid fields, exploring alien caves, and crafting equipment in your ship's workshop.

The game prioritizes **systemic gameplay over scripted content**, where complex interactions emerge from simple, composable systems. Players carve their own path through a persistent universe: becoming a master craftsman, a notorious thief, a fearless explorer, or a cunning trader—or all of the above.

---

## Core Pillars

These fundamental design principles guide all features and decisions:

### 1. **Hierarchical Emergence**
Everything is an entity. Everything can contain other entities. A spaceship is not a special case—it's a movable container entity, just like a house is an immovable one. This parent-child hierarchy enables:
- Ships that are dungeons you can walk around inside
- Seamless transitions between scales (walking → piloting → interstellar travel)
- Nested complexity (a ship docked at a station orbiting a planet in a star system)
- Emergent gameplay from simple rules

### 2. **Systemic Depth**
Inspired by Runescape and Dwarf Fortress, gameplay emerges from interlocking systems rather than handcrafted content:
- Skills improve through use (mine ore → mining skill increases)
- Vision and information determine what's possible (can't steal what you can't see)
- Combat, stealth, crafting, trading all use the same underlying ECS
- Player choices create unique stories through system interaction

### 3. **Information as Power**
The vision system isn't just graphics—it's a core gameplay mechanic:
- Field-of-view and line-of-sight determine what you can interact with
- Vision memory creates the "fog of war" exploration experience
- Stealth mechanics (pickpocketing, lockpicking, sneak attacks) require obscured vision
- Ship sensors extend this to space (radar, scanners)

### 4. **Meaningful Progression**
Character growth is horizontal and vertical:
- **Skills**: Mining, crafting, combat, stealth, trading, piloting (Runescape-style)
- **Equipment**: Tools, weapons, ship upgrades affect capability
- **Knowledge**: Discovering locations, recipes, trade routes
- **Wealth**: Accumulating resources to afford better ships/equipment

### 5. **Respect Player Time**
While inspired by complex sims, we value player agency:
- Turn-based combat allows thoughtful decisions
- Autopilot and time-passing mechanics respect tedium
- Save/load system preserves progress
- Clear feedback on mechanics (no hidden random numbers)

---

## Gameplay Loops

### Minute-to-Minute (Core Loop)
**Explore → Discover → Interact → Progress**

1. **Movement & Perception**
   - Navigate tile-by-tile through environments
   - Vision reveals entities within field-of-view
   - Memory preserves previously explored areas (at reduced opacity)

2. **Interaction**
   - Mine ore from asteroids
   - Pick locks on secure containers
   - Attack hostile NPCs
   - Pick up items and manage inventory
   - Trade with merchants

3. **Combat** (when it occurs)
   - Turn-based tactical decisions
   - Position, line-of-sight, and equipment determine outcomes
   - Health management and risk assessment

4. **Immediate Feedback**
   - Skill XP gains visible
   - Loot drops from defeated enemies
   - Inventory updates
   - Health bars and status indicators

### Session-to-Session (Medium Loop)
**Accept Mission → Travel → Complete Objective → Return for Reward**

1. **Preparation**
   - Equip appropriate gear for the mission
   - Stock ship with supplies (fuel, food, ammo)
   - Plan route through star system

2. **Travel**
   - Pilot ship through space
   - Navigate hazards (asteroid fields, pirate patrols)
   - Dock at stations for refueling/trading

3. **Objective Completion**
   - Explore dungeons/caves/derelict ships
   - Combat encounters with NPCs/creatures
   - Resource gathering (mining, salvaging)
   - Stealth missions (infiltration, theft)

4. **Return & Reward**
   - Turn in missions for credits/reputation
   - Sell gathered resources
   - Repair/upgrade ship and equipment
   - Level up skills

### Long-Term (Aspirational Loop)
**Build Wealth → Acquire Better Ships → Access New Content → Repeat**

1. **Capital Accumulation**
   - Optimize trade routes for profit
   - Complete high-value contracts
   - Discover rare resources

2. **Ship Progression**
   - Upgrade current ship (better engines, weapons, cargo)
   - Purchase larger/specialized ships
   - Customize ship interiors

3. **Access Expansion**
   - Unlock new star systems
   - Gain reputation with factions
   - Discover hidden locations (secret stations, ancient ruins)

4. **Mastery**
   - Max out key skills
   - Acquire legendary equipment
   - Establish trade empire or become feared pirate

---

## Player Experience Goals

What should players **feel** when playing Rogueverse?

### Primary Emotions

1. **Wonder & Discovery**
   - "What's behind that locked door?"
   - "I've never seen this type of asteroid before"
   - Fog of war creates suspense and reward for exploration

2. **Mastery & Growth**
   - "My mining skill just hit level 50!"
   - "I can finally afford that ship upgrade"
   - Tangible progress through visible skill gains

3. **Agency & Creativity**
   - "I'll sneak past the guards instead of fighting"
   - "What if I mine ore in my ship while traveling to save time?"
   - Systems support multiple solutions

4. **Immersion in a Living World**
   - NPCs patrol, trade, and live their lives
   - Ships dock, depart, and travel autonomously
   - Systems feel interconnected and reactive

### Anti-Goals (What to Avoid)

- ❌ **Tedium**: No mindless grinding for its own sake (autopilot helps)
- ❌ **Confusion**: Systems should be learnable, not opaque
- ❌ **Unfair Deaths**: Turn-based combat allows strategic retreat
- ❌ **Content Walls**: Skills gate capability, not arbitrary level requirements

---

## Core Systems

These are the foundational systems that create the gameplay:

### 1. **Entity Hierarchy System** ⭐ (Unique to Rogueverse)
- All entities exist within parent-child relationships
- Parent determines render context and interaction scope
- Enables seamless scale transitions (ship interior ↔ space ↔ planet surface)
- **Components**: `ParentEntity(int parentId)`, `LocalPosition(x, y)`

### 2. **Vision & Perception**
- Field-of-view calculation with line-of-sight
- Vision memory (fog of war with remembered entities at low opacity)
- Observer-based rendering (only see what current entity can see)
- Extends to ship sensors in space
- **Components**: `VisionRadius`, `VisibleEntities`, `VisionMemory`, `BlocksSight`

### 3. **Movement & Navigation**
- Grid-based tile movement (8 directions)
- Collision detection with `BlocksMovement` entities
- Relative positioning within parent entity
- Autopilot for ships (autonomous movement while player does other things)
- **Components**: `LocalPosition`, `MoveByIntent`, `Direction`, `BlocksMovement`

### 4. **Combat**
- Turn-based tactical combat
- Health pools with damage application
- Death triggers loot drops
- Combat events for feedback
- **Components**: `Health`, `AttackIntent`, `DidAttack`, `WasAttacked`, `Dead`

### 5. **Inventory & Items**
- Entity-based items (items are entities)
- Container entities with capacity limits
- Pickup/drop mechanics
- Loot tables with probability distributions
- **Components**: `Inventory`, `InventoryMaxCount`, `Pickupable`, `LootTable`

### 6. **Skills & Progression**
- Runescape-style skill system (use to improve)
- Mining, combat, crafting, stealth, piloting, etc.
- Skills unlock capabilities and improve outcomes
- **Components**: *To be implemented* - `Skills`, `Mining`, `Crafting`, etc.

### 7. **Stealth & Social**
- Stealth actions require obscured vision
- Pickpocketing, lockpicking, sneak attacks
- NPC awareness based on vision system
- **Components**: *To be implemented* - `Stealth`, `Lockpick`, `Alert`

### 8. **Crafting & Resources**
- Resource gathering (mining ore, salvaging parts)
- Crafting recipes combine items into new items
- Tool quality affects gathering yield
- **Components**: *To be implemented* - `Mineable`, `Tool`, `Recipe`

### 9. **Economy & Trading**
- NPC merchants buy/sell items
- Dynamic prices based on supply/demand (aspirational)
- Player-driven economy through resource gathering
- **Components**: *To be implemented* - `Merchant`, `Currency`, `Price`

### 10. **AI Behavior**
- Behavior tree system for NPCs and ships
- Autonomous entities perform actions (patrol, trade, attack)
- React to player presence via vision system
- **Components**: `AiControlled`, `Behavior` (with behavior tree nodes)

### 11. **Space Travel** ⭐
- Ships are movable parent entities
- Piloting vs walking inside ship (different interaction modes)
- Docking at stations, landing on planets
- Autopilot during travel
- **Components**: *To be implemented* - `ShipStats`, `Autopilot`, `Docked`

---

## Key Features (Planned)

### Phase 1: Foundation (Current)
- ✅ ECS architecture with component serialization
- ✅ Grid-based movement with collision
- ✅ Vision system with FOV and memory
- ✅ Turn-based combat with health/damage
- ✅ Inventory system with pickup/drop
- ✅ Behavior tree AI
- ✅ Vision-based rendering (opacity by visibility)

### Phase 2: Hierarchy & Space
- 🔲 `ParentEntity` component and transition system
- 🔲 Ship entities with interiors
- 🔲 Entering/exiting ships
- 🔲 Basic space travel (ship movement in star system)
- 🔲 Autopilot system
- 🔲 Planet surface exploration

### Phase 3: Skills & Progression
- 🔲 Skill system framework (XP, levels)
- 🔲 Mining skill with ore gathering
- 🔲 Crafting system with recipes
- 🔲 Tool items that improve skill outcomes
- 🔲 Equipment slots and stat bonuses

### Phase 4: Stealth & Social
- 🔲 Stealth mechanics (sneak, hide)
- 🔲 Lockpicking mini-system
- 🔲 Pickpocketing from NPCs
- 🔲 NPC alert states (idle, suspicious, hostile)
- 🔲 Sneak attack damage bonuses

### Phase 5: Economy & Trading
- 🔲 Merchant NPCs with inventory
- 🔲 Currency system
- 🔲 Trading UI
- 🔲 Resource value and pricing
- 🔲 Contracts/missions system

### Phase 6: World Expansion
- 🔲 Multiple planets in star system
- 🔲 Space stations (dockable)
- 🔲 Procedural cave/dungeon generation
- 🔲 Derelict ships to explore
- 🔲 Asteroid fields with resources

---

## Scope & Constraints

### What's In Scope
- ✅ Single-player experience
- ✅ Turn-based gameplay
- ✅ PvE combat (no PvP initially)
- ✅ Desktop and mobile (Flutter supports both)
- ✅ Procedural content generation (dungeons, asteroids)
- ✅ Save/load game state
- ✅ Systemic interactions between systems

### What's Out of Scope (For Now)
- ❌ Multiplayer/MMO features
- ❌ Real-time combat
- ❌ Voice acting or complex narrative
- ❌ 3D graphics (staying with 2D/SVG)
- ❌ Galaxy-spanning scale (focus on single star system first)
- ❌ Faction reputation system (maybe later)

### Design Constraints
- **Performance**: Must run smoothly with hundreds of entities
- **Mobile-friendly**: Touch controls and UI must work on phones
- **Deterministic**: Turn-based allows save/load without desyncs
- **Moddable**: Component system should allow easy content addition

---

## Success Metrics

How do we know we're building the right game?

### Player Engagement
- Players naturally experiment with systems (stealth vs combat, trading vs mining)
- Players share emergent stories ("I snuck onto a pirate ship and stole their cargo")
- Players return for multiple sessions (compelling progression loop)

### System Validation
- Vision system creates meaningful stealth gameplay
- Parent-child hierarchy feels natural, not confusing
- Skills provide clear power progression
- Economy creates interesting decisions

### Technical Success
- ECS architecture scales to large entity counts
- Parent-child system handles all containment needs
- Save/load preserves full game state
- Mobile and desktop both playable

---

## Inspiration Reference

### Primary Influences
- **ASCII Sector**: Space trading/combat, ship interiors, missions
- **Dwarf Fortress**: Systemic depth, emergent gameplay, skill system
- **Star Citizen**: Ambitious scope, seamless ship interiors, living universe

### Secondary Influences
- **Runescape**: Skill system (use to improve), horizontal progression
- **NetHack/DCSS**: Turn-based tactics, item interactions
- **FTL**: Ship management, autopilot during travel
- **Escape Velocity**: Space trading, ship upgrades

---

## Living Document

This design document will evolve as the game develops. Key questions to revisit:

- How many star systems? (Single system MVP vs multi-system expansion)
- Procedural vs handcrafted content balance?
- How deep should crafting go? (simple recipes vs complex tech trees)
- Ship interior customization? (fixed layouts vs player-designed)
- NPC depth? (simple behaviors vs complex simulation)

**Next Review**: After Phase 2 (Hierarchy & Space) is implemented
