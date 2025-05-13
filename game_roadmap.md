# 🧭 Game Development Roadmap (Roguelike Turn-Based)

This roadmap provides a structured, bite-sized progression from MVP to a deeper gameplay experience. Tasks are grouped by theme and roughly ordered from easiest to most involved.

---

## 📦 Phase 1: *Player Interaction & Feedback*

### 🔹 Easy Wins

- [x] **Log system** – Print events like “Picked up item” or “Attacked NPC” to console/log.
- [x] **Add `Health` component** – Just an integer for now.
- [x] **Add `Inventory` component** – Store a list of item entity IDs.
- [x] **Create `Item` component** – Marks an entity as pickable.
- [x] **Allow player to pick up nearby items** (e.g., standing on same tile).

### 🔹 Slightly More Involved

- [ ] **Limit inventory size** – Prevent picking up items over a max capacity.
- [ ] **Basic UI overlay** – Show current health or inventory via Flame HUD text.

---

## 🛠 Phase 2: *World Interactions*

### 🔹 Easy Wins

- [ ] **Add `Mineable` component** – Tag ore nodes.
- [ ] **Add `Tool` component** – Used to increase mining output.
- [ ] **Allow mining via interaction** – Player interacts to destroy node, gain `Item`.

### 🔹 Medium

- [ ] **Add `Mining` skill** – Component with XP and level.
- [ ] **Increase mining yield by skill level**.
- [ ] **Add `Smelter` entity** – Interact with it to turn ore into bars.

---

## ⚔ Phase 3: *Combat and Enemies*

### 🔹 Easy Wins

- [ ] **Add `AttackIntent` component** – Player triggers attack.
- [ ] **Add `Damage` component** – Carry damage info.
- [ ] **When adjacent to enemy, apply `Damage` to them**.

### 🔹 Medium

- [ ] **If HP <= 0, destroy entity**
- [ ] **NPC AI flees if low HP** (use behavior tree)
- [ ] **NPC drops loot** when defeated

---

## 📈 Phase 4: *Character Growth*

### 🔹 Easy Wins

- [ ] **Add `XP` component** – Tracks experience per skill.
- [ ] **Gain XP on mining, attacking, crafting**.
- [ ] **Add `Attribute` component** – Strength, Intelligence, etc.

### 🔹 Medium

- [ ] **Level-up bonuses** – +HP, +damage, better results, etc.
- [ ] **Add `Speed` attribute** – Affects turn order

---

## 🧠 Phase 5: *More Advanced Simulation*

### 🔹 Easy Wins

- [ ] **Add `Sleep` or `Idle` behavior** – NPCs alternate between behaviors
- [ ] **Simple perception radius** – 3x3 square vision

### 🔹 Medium

- [ ] **Event triggers on sight** – If NPC sees player, alert or attack
- [ ] **Patrol routes using waypoints**

---

## 🛒 Phase 6: *Economy & Items*

### 🔹 Easy Wins

- [ ] **Create a merchant NPC** – Stationary, tagged with `Merchant` component.
- [ ] **Allow trading with player via console commands** or basic UI

### 🔹 Medium

- [ ] **Prices vary by player Charisma or merchant mood**
- [ ] **Merchants remember trades and adjust stock**

---

## 🚪 Phase 7: *World Expansion & Transitions*

### 🔹 Easy Wins

- [ ] **Interior/exterior separation** – Mark chunks as `RegionId` or `CellId`
- [ ] **Trigger cell change on certain tiles**

### 🔹 Medium

- [ ] **Keep AI active in non-loaded cells**
- [ ] **Time passage affects inactive chunks**

---

## 📌 Sample Sprint Plan

### Day 1

- [ ] Add `Item`, `Inventory`, and pickup logic
- [ ] Add `Mineable` and interactable ore nodes

### Day 2

- [ ] Add `Mining` skill and XP
- [ ] Add `Smelter` and basic crafting logic

### Day 3

- [ ] Add `Health` + `Damage` components
- [ ] Add basic combat — player attacks NPC

### Day 4–5

- [ ] Add `Speed` + turn queue logic
- [ ] Add behavior tree logic for fleeing or patrolling
