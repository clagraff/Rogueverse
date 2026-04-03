# Rogueverse

A space exploration roguelike blending the systemic depth of Dwarf Fortress with the ambitious scope of Star Citizen, presented through the lens of classic ASCII space sims like ASCII Sector.

**Status**: Proof of Concept / Active Development  
**Platform**: Desktop & Mobile (Flutter)  
**Genre**: Turn-based Space Roguelike

---

## What Is This?

Rogueverse is a living universe where every entity—from a single wrench to a massive space station—exists within an emergent parent-child hierarchy. Pilot starships through asteroid fields, explore alien caves, craft equipment in your ship's workshop, and carve your own path through a persistent universe as a craftsman, thief, explorer, or trader.

### Core Features

- **Hierarchical Entities**: Ships, planets, stations—everything is an entity containing other entities
- **Seamless Transitions**: Walk around your ship, pilot it through space, land on planets, explore interiors
- **Systemic Gameplay**: Complex interactions emerge from simple, composable ECS systems
- **Vision-Based Mechanics**: Fog of war, stealth, and line-of-sight aren't just graphics—they're gameplay
- **Skill Progression**: Runescape-style skills that improve through use (mining, crafting, combat, stealth)
- **Turn-Based Tactics**: Thoughtful decisions over twitch reflexes

---

## Architecture

Built on a custom Entity-Component-System (ECS) architecture using Dart and Flutter/Flame:

- **Entity-Component-System**: Pure data-driven design with intent-based components
- **Parent-Child Hierarchy**: Revolutionary approach to spatial containment and scale transitions
- **Serializable Everything**: Full game state save/load via `dart_mappable`
- **Behavior Trees**: Flexible AI system for NPCs and autonomous ships
- **Stream-Based Reactivity**: Component changes emit events for downstream processing

### Technology Stack

- **Language**: Dart 3.x
- **Framework**: Flutter (cross-platform)
- **Game Engine**: Flame (2D game engine)
- **Serialization**: dart_mappable

---

## Current Features (Phase 0: Complete ✅)

### Core Systems
- ✅ Full ECS implementation with component lifecycle
- ✅ World serialization (save/load)
- ✅ Grid-based movement with collision detection
- ✅ Vision system with FOV, line-of-sight, and memory
- ✅ Vision-based rendering (entities fade by visibility)
- ✅ Turn-based combat with health and damage
- ✅ Inventory system with pickup/drop
- ✅ Loot tables with probability-based drops
- ✅ Behavior tree AI for NPCs
- ✅ Entity template system

### Player Experience
- ✅ WASD movement, E to interact, Tab for inventory
- ✅ Entity inspector (debug panel)
- ✅ Template editor (create reusable entity blueprints)
- ✅ Health bars, hover tooltips, grid visualization
- ✅ Fog of war with memory (see previously explored areas at low opacity)

---

## Roadmap

### Phase 1: Parent-Child Hierarchy 🎯 NEXT
Implement the core parent-entity system enabling ships, interiors, and scale transitions.

**Key Deliverables**:
- `ParentEntity` component for spatial containment
- Transition system (enter/exit ships and buildings)
- Rendering scoped by parent context
- Test scene: Player on planet → enters ship → sees ship interior

### Phase 2: Spaceships & Travel
Ships become movable parent entities with autopilot and interiors.

**Key Deliverables**:
- Ship entity templates with interior layouts
- Autopilot system (set destination, ship moves autonomously)
- Piloting mechanics (sit in cockpit, control ship)
- Takeoff/landing (ship changes parent between planet and star system)
- Player can walk around ship while autopilot is active

### Phase 3: Skills & Progression
Runescape-style skill system with mining, crafting, and equipment.

### Phase 4: Stealth & Social
Leverage vision system for stealth, lockpicking, pickpocketing, and NPC awareness.

### Phase 5: Economy & Trading
Merchant NPCs, contracts/missions, and player-driven economy.

### Phase 6: World Expansion
Procedural generation, multiple planets, space stations, asteroid fields.

**Full details**: See `TECHNICAL_FEATURES.md`

---

## Design Philosophy

Read `GAME_DESIGN.md` for the complete vision, but in short:

### Core Pillars

1. **Hierarchical Emergence** - Everything is an entity containing other entities
2. **Systemic Depth** - Complex gameplay from simple, interlocking systems
3. **Information as Power** - Vision determines what's possible
4. **Meaningful Progression** - Skills, equipment, knowledge, wealth
5. **Respect Player Time** - Autopilot, save/load, clear feedback

### Inspirations

- **ASCII Sector**: Space sim framework, ship interiors, missions
- **Dwarf Fortress**: Emergent gameplay, systemic simulation
- **Star Citizen**: Ambitious scope, seamless ship interiors
- **Runescape**: Skill-based progression through use
- **NetHack/DCSS**: Turn-based tactics, item interactions

---

## Project Structure

```
lib/
├── ecs/                    # Core ECS engine
│   ├── components.dart     # All component definitions
│   ├── systems.dart        # System implementations
│   ├── world.dart          # World and entity management
│   ├── entity.dart         # Entity wrapper
│   └── ai/                 # Behavior tree nodes
├── game/                   # Flame rendering layer
│   ├── components/         # Renderable components (Agent, VisionCone)
│   └── game_area.dart      # Main game coordinator
└── app/                    # UI and Flutter widgets
    ├── screens/            # Game screen, menus
    └── widgets/            # Inspector, inventory, overlays
```

---

## Getting Started

### Prerequisites
- Dart 3.x SDK
- Flutter SDK
- An IDE (VS Code, Android Studio, IntelliJ)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/rogueverse.git
cd rogueverse

# Install dependencies
flutter pub get

# Generate code (for dart_mappable)
dart run build_runner build

# Run the game
flutter run
```

### Development Commands

```bash
# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Generate barrel exports
dart tools/barrel_generator.dart

# Generate mappers (after adding/modifying components)
dart run build_runner build
```

### Bundled Assets & Developer Saves

The game ships with a base world state and optional developer saves bundled as Flutter assets in `assets/saves/`. On first launch, these are copied into the user's app support directory.

**How it works:**
- `assets/saves/initial.json` — The base game state (all templates, authored world content). This is the foundation every save builds on.
- `assets/saves/*.patch.json` — Save patches bundled with the app. On first launch, they're seeded into the user's saves directory if not already present.

**Developer saves** use a dot-prefix naming convention (e.g., `.vision-test.patch.json`). This distinguishes them from player saves in the Load Game screen, where they appear in a separate "Developer Saves" section with a restore-to-default option.

**To create a new developer save:**
1. Start a new game in the app and build your test scenario (place entities, configure the scene)
2. The save auto-persists to your app support `saves/` directory
3. Copy the `.patch.json` file from there into `assets/saves/`, renaming it with a `.` prefix (e.g., `.combat-test.patch.json`)
4. The save will now ship with the app on future builds

**To update `initial.json`:**
1. Edit the world in-game using the editor (editing the "initial" target)
2. Copy the `initial.json` from your app support directory into `assets/saves/`

Player saves cannot start with a dot — the New Game dialog enforces this to prevent collisions with the developer save convention.

---

## Contributing

This is a personal learning/POC project, but design feedback and architectural discussions are welcome! See `GAME_DESIGN.md` and `TECHNICAL_FEATURES.md` for the vision and technical roadmap.

### Design Documents

- **GAME_DESIGN.md** - Game vision, pillars, gameplay loops, player experience
- **TECHNICAL_FEATURES.md** - Architecture deep-dive, feature roadmap, system dependencies
- **game_roadmap.md** - Deprecated (replaced by above documents)

---

## Architecture Highlights

### The Parent-Child Entity Hierarchy

The defining innovation of Rogueverse is its parent-child entity system:

```
Galaxy Entity (id: 1)
└─ StarSystem Entity (id: 2, ParentEntity(1))
   ├─ Planet "Earth" (id: 10, ParentEntity(2))
   │  ├─ House (id: 100, ParentEntity(10))
   │  │  └─ Table (id: 1000, ParentEntity(100))
   │  ├─ Spaceship "Aurora" (id: 200, ParentEntity(10))
   │  │  ├─ Player (id: 5000, ParentEntity(200))
   │  │  └─ Crafting Station (id: 5001, ParentEntity(200))
   │  └─ NPC (id: 3000, ParentEntity(10))
   └─ SpaceStation (id: 20, ParentEntity(2))
```

**Key Properties**:
- All positions are relative to parent entity
- Rendering shows only entities in current parent context
- Interactions scoped to entities sharing parent
- Transitions = changing `ParentEntity` component
- Enables seamless interiors, ships, and scale transitions

This simple pattern elegantly solves:
- Ship interiors (ship is a parent entity)
- Scale transitions (planet → space → galaxy)
- Autopilot while player walks around ship (both entities process independently)
- Spatial containment (buildings, containers, cargo holds)

See `TECHNICAL_FEATURES.md` for full architectural details.

---

## ECS Component Examples

```dart
// Movement intent (temporary component)
entity.upsert(MoveByIntent(dx: 1, dy: 0));

// Vision system
entity.add([
  VisionRadius(radius: 7, fieldOfViewDegrees: 90),
  Direction(CompassDirection.north),
]);

// AI behavior
entity.add([
  AiControlled(),
  Behavior(MoveRandomlyNode()),
]);

// Parent-child hierarchy (future)
player.upsert(ParentEntity(shipId));  // Player enters ship
ship.upsert(ParentEntity(starSystemId));  // Ship enters space
```

---

## License

[License TBD]

---

## Development Status

**Current Phase**: Phase 0 Complete ✅  
**Next Milestone**: Phase 1 - Parent-Child Hierarchy  
**Long-term Goal**: Playable space roguelike with emergent systemic gameplay

This is an active learning project exploring:
- ECS architecture in Dart
- Turn-based game systems
- Vision/FOV algorithms
- Behavior trees for AI
- Procedural generation (future)

Follow development progress in the commit history and design documents!
