# AGENTS.md

## Project

**Project FreeStar**

A Godot space game developed on Omarchy with AI-assisted / vibe coding.

The game is a first-person arcade space sandbox inspired by **Freelancer** and **Elite**, with:

- a retro low-poly 1990s PC-game look
- arcade mouse-driven spaceflight
- bounty hunting
- piracy
- exploration
- procedural missions
- simple trading
- physical station docking
- supercruise inside star systems
- jump travel between systems
- an eventually endless deterministic procedural universe

Before making architectural or gameplay decisions, read:

```text
docs/GAME_CONCEPT.md
```

`docs/GAME_CONCEPT.md` contains the detailed game concept and is the primary source of truth for **what the game is supposed to become**.

It contains substantially more product and design context than this file, including:

- the complete game fantasy and intended Freelancer/Elite inspiration
- confirmed gameplay decisions
- cockpit and visual direction
- normal flight, supercruise, and inter-system travel
- planets and orbital interaction
- stations and physical docking
- combat and weapons
- ship classes and progression
- bounty hunting, piracy, exploration, missions, and trading
- procedural factions
- the simple economy model
- deterministic universe and sector generation
- system archetypes and density principles
- persistence boundaries
- procedural station ideas
- asset strategy
- Prototype 0.1 scope
- the longer development roadmap
- features intentionally postponed or out of scope

## Game Concept Authority

Use the two documents for different purposes:

```text
AGENTS.md
    = how the coding agent should work in this repository

docs/GAME_CONCEPT.md
    = what game we are building and why
```

Read `docs/GAME_CONCEPT.md` before making changes that affect:

- gameplay behavior
- controls or flight feel
- visual direction
- combat
- docking
- supercruise
- ships or equipment
- missions
- factions
- economy
- exploration
- procedural generation
- universe structure
- persistence
- scope or roadmap

For a small isolated implementation task, do not repeatedly re-read the whole document if the relevant design constraints are already clear. For architectural work, new gameplay systems, or ambiguous requirements, consult it first.

If a user request explicitly changes the game design, follow the user's newer instruction and update `docs/GAME_CONCEPT.md` when the change is significant enough to become a lasting project decision.

If this file and `docs/GAME_CONCEPT.md` appear to conflict:

1. follow explicit current user instructions first
2. use `AGENTS.md` for repository/process/coding behavior
3. use `docs/GAME_CONCEPT.md` for game-design intent
4. prefer the smallest implementation that satisfies the current milestone when ambiguity remains

---

# 1. Agent Mission

Your job is not to build the entire game at once.

Your job is to:

1. understand the current state of the repository
2. implement the requested feature
3. keep the implementation small and understandable
4. preserve existing working behavior
5. test the feature where practical
6. leave the project easier to continue than you found it

This is a solo-development project using AI-assisted coding.

Optimize for:

- clarity
- iteration speed
- maintainability
- testability
- fun gameplay

Do not optimize for hypothetical future requirements that have not been requested.

---

# 2. Core Design Rule

The most important project principle is:

> **First make one star system fun to fly around in. Build the endless galaxy later.**

Do not prematurely implement large procedural systems while basic flight, combat, docking, and supercruise are still unfinished.

The intended development order is roughly:

```text
Flight
  ↓
Combat
  ↓
Docking
  ↓
Supercruise
  ↓
Station services
  ↓
Missions
  ↓
Economy
  ↓
Procedural star systems
  ↓
Procedural galaxy
```

Respect the current milestone.

---

# 3. Technology

Primary engine:

```text
Godot
```

Preferred scripting language:

```text
GDScript
```

Use another language only if the repository already uses it for a clear reason or the task explicitly requires it.

Prefer Godot-native solutions.

Prefer:

- scenes
- nodes
- resources
- signals
- composition
- small scripts
- data-driven configuration

Avoid adding external dependencies unless they provide clear value.

---

# 4. Before Changing Code

Before implementing a task:

1. inspect the relevant files and scenes
2. understand the current architecture
3. identify the smallest set of files that need changing
4. check whether a similar system already exists
5. preserve existing conventions where they are reasonable

Do not rewrite working systems merely because you would have designed them differently.

Do not perform broad refactors unless required for the requested feature.

---

# 5. Implementation Style

Prefer small, explicit implementations.

Good:

```gdscript
class_name ShipMovement
extends Node

@export var max_speed: float = 600.0
@export var acceleration: float = 80.0
```

Avoid giant scripts containing unrelated responsibilities such as:

```text
movement
weapons
inventory
missions
UI
save system
procedural generation
```

Split systems when they become meaningfully distinct.

Do not split code into dozens of tiny files merely for architectural purity.

Use judgment.

---

# 6. GDScript Style

Use typed GDScript where practical.

Prefer:

```gdscript
var current_speed: float = 0.0
var target: Node3D
```

over unnecessary untyped state.

Use descriptive names.

Prefer:

```gdscript
enter_supercruise()
```

over:

```gdscript
do_sc()
```

Use constants for meaningful fixed values.

Use `@export` for values that should be tuned in the Godot editor.

Use signals for event communication when appropriate.

Avoid deeply coupled node-path assumptions where a cleaner exported reference or signal would work.

---

# 7. Gameplay Values Must Be Tunable

Gameplay parameters should generally be easy to tune.

Examples:

- maximum ship speed
- acceleration
- steering sensitivity
- roll rate
- weapon damage
- weapon cooldown
- enemy health
- docking trigger size
- supercruise acceleration
- supercruise maximum speed

Prefer editor-exposed values or resource data instead of burying gameplay balance numbers throughout code.

Example:

```gdscript
@export_category("Flight")
@export var max_speed: float = 600.0
@export var acceleration: float = 100.0
@export var mouse_sensitivity: float = 0.003
```

---

# 8. Flight Philosophy

Flight is arcade-style.

Do not implement realistic Newtonian physics unless explicitly requested.

Desired behavior:

- responsive
- easy to understand
- mouse-friendly
- fun in combat
- visually readable
- forgiving enough for docking

The player should feel like they are flying a powerful space fighter, not operating a spacecraft simulator.

Reference feel:

> Freelancer rather than Kerbal Space Program.

---

# 9. Mouse Flight

The baseline control style is mouse-driven flight.

General intent:

- mouse controls desired pitch/yaw direction
- keyboard controls throttle and auxiliary movement
- optional keyboard roll
- ship smoothly turns toward aim direction
- combat targeting remains readable

Do not make the mouse feel like directly dragging a rigid body.

Favor controllable smoothing.

Avoid excessive input latency.

---

# 10. Combat Philosophy

Combat should be readable and satisfying before becoming complicated.

Initial combat should use simple systems:

- one player weapon
- one enemy type
- shields / hull if needed
- damage
- destruction
- simple target markers

Do not build a complex weapon ecosystem early.

Simple enemy AI is acceptable.

An early enemy only needs to do things like:

```text
acquire player
approach
maintain approximate range
aim
shoot
turn away / reposition
```

It does not need sophisticated tactics.

---

# 11. Docking Philosophy

Docking should involve physically flying into a station.

Preferred flow:

```text
approach station
    ↓
receive clearance
    ↓
follow docking guidance
    ↓
enter hangar / docking tunnel
    ↓
autodock trigger
    ↓
station interface
```

The player does not walk around stations.

Do not add first-person character movement inside stations unless explicitly requested in a future milestone.

---

# 12. Supercruise Philosophy

Supercruise exists to eliminate boring travel.

It is not a realistic relativistic simulation.

It should:

- move the player quickly between major system locations
- allow steering
- feel visually exciting
- reduce speed near destinations or dangerous areas
- transition cleanly back to normal flight

Avoid making supercruise require long periods of passive waiting.

---

# 13. Retro Visual Direction

The project should look intentionally retro.

Favor:

- low-poly geometry
- flat shading
- limited palettes
- bold silhouettes
- simple textures
- chunky HUD elements
- low-resolution rendering
- nearest-neighbor scaling
- simple lighting

Possible internal render targets:

```text
640×360
854×480
```

Do not replace the retro direction with modern photorealistic rendering.

Do not add expensive visual effects unless they clearly improve the intended style.

---

# 14. Procedural Generation Rules

Procedural generation will eventually be a major system.

When implementing it, follow these principles.

## Deterministic

The same seed must generate the same result.

Conceptually:

```text
galaxy seed
    +
sector coordinates
    +
system index
    =
deterministic content
```

Avoid relying on behavior that may change across runs or platforms.

Store explicit seeds where needed.

---

## Generate, Don't Simulate Everything

Do not maintain the entire galaxy in memory.

Do not simulate millions of NPCs.

Generate nearby content as needed.

Regenerate deterministic content when revisiting locations.

Persist only meaningful player state or meaningful changes.

---

## Coherent Randomness

Do not generate random content without context.

Prefer system archetypes such as:

- industrial
- agricultural
- mining
- military
- pirate
- frontier
- research
- trade hub

Then generate content consistent with that identity.

For example, a mining system should be more likely to contain:

- asteroid fields
- mining stations
- ore exports
- industrial traffic
- mining missions

This is better than independent random rolls for every object.

---

# 15. Persistence

Do not build a massively persistent simulated universe.

Long-term save data may contain:

- universe seed
- player position
- player ship
- owned ships
- credits
- equipment
- cargo
- faction reputation
- discovered systems
- important discoveries
- completed missions

Do not save every generated NPC or every temporary encounter.

---

# 16. Economy

The intended economy is simple.

Use an Elite-style:

> buy low / sell high

model.

Stations can modify commodity prices based on:

- system archetype
- station archetype
- faction
- supply/demand category
- local modifiers

Do not implement a galaxy-wide real-time production simulation unless explicitly requested later.

---

# 17. Missions

Start with templates.

Good initial mission types:

- bounty
- patrol
- delivery
- scan
- escort
- recovery

Mission templates should reference generated data such as:

```text
faction
target
location
reward
difficulty
```

Do not attempt AI-generated narrative campaigns or complex procedural storytelling in early milestones.

---

# 18. Factions

Factions should eventually be procedural but understandable.

Use archetypes such as:

- corporation
- government
- pirate clan
- military
- mercenary guild
- research organization
- traders
- miners

Faction generation may eventually define:

- name
- colors
- emblem
- legal status
- allies
- enemies
- ship preferences
- mission preferences

Do not implement this before core gameplay needs it.

---

# 19. Scope Guardrails

Do not implement the following unless explicitly requested:

- planetary landing
- walking on planets
- walking in stations
- multiplayer
- colony building
- MMO-style persistence
- realistic orbital mechanics
- fully Newtonian physics
- survival mechanics
- crafting
- giant skill trees
- large-scale procedural storytelling
- complex political simulation
- complex economic simulation
- ship boarding
- ship capture
- full ship interiors
- seamless loading of an entire galaxy

If a task appears to imply one of these, implement the smallest alternative that satisfies the immediate gameplay requirement.

---

# 20. Assets

Use placeholder assets freely during prototyping.

Simple primitives are acceptable.

Examples:

```text
box = station module
sphere = planet
capsule = ship body
cylinder = engine
```

Gameplay should not be blocked by missing final art.

Keep asset paths organized.

Do not add copyrighted third-party assets without clear licensing.

When external or generated assets are introduced later, keep provenance and license information where appropriate.

---

# 21. Scene Organization

Prefer reusable scenes.

Likely examples:

```text
PlayerShip.tscn
EnemyShip.tscn
Station.tscn
Planet.tscn
Projectile.tscn
HUD.tscn
TestSystem.tscn
```

Do not duplicate complete scene setups when inheritance or composition would make maintenance easier.

Do not build overly abstract scene factories before they are needed.

---

# 22. Data Organization

Use Godot Resources where useful for reusable game data.

Good candidates:

```text
ShipData
WeaponData
CommodityData
FactionArchetype
StationArchetype
```

Example concept:

```gdscript
class_name WeaponData
extends Resource

@export var display_name: String
@export var damage: float
@export var fire_rate: float
@export var projectile_speed: float
```

Do not create a generic universal data framework.

Use straightforward project-specific resources.

---

# 23. UI

UI should be readable before decorative.

Prefer:

- strong contrast
- large readable indicators
- simple shapes
- clear target markers
- clear speed / throttle information
- retro aesthetic

HUD should eventually communicate:

```text
speed
throttle
target
target range
shield
hull
weapon state
supercruise state
mission objective
```

Only add information as gameplay systems require it.

Avoid clutter.

---

# 24. Error Handling

Fail clearly during development.

If a required node or resource is missing, prefer an understandable development error over silently doing the wrong thing.

Use warnings for recoverable setup issues.

Avoid flooding output with debug logs every frame.

Temporary debug logging is acceptable while implementing a feature, but remove noisy logs before finishing the task.

---

# 25. Testing

For each feature, test the smallest relevant gameplay path.

Examples:

## Flight

Verify:

- movement starts
- throttle works
- ship stops / slows correctly
- mouse turning works
- speed cap works

## Combat

Verify:

- weapon fires
- projectile/raycast hits
- damage is applied
- enemy can die

## Docking

Verify:

- station can be entered
- docking trigger activates once
- station UI appears
- launch returns the player to flight

## Procedural Generation

Verify:

- same seed → same result
- different seed → different result
- no obvious invalid configurations
- generation does not depend on frame timing

When possible, add small deterministic tests for non-scene logic.

---

# 26. Performance

Do not prematurely optimize.

However, avoid obviously unbounded behavior.

Examples:

Bad:

```text
spawn thousands of active ships
keep every visited system loaded forever
run expensive procedural generation every frame
```

Good:

```text
generate content when entering a region
despawn distant temporary encounters
pool only where it becomes useful
cache deterministic data when appropriate
```

Measure before performing major optimization work.

---

# 27. Version Compatibility

When modifying Godot APIs or project configuration:

- inspect the current Godot project version
- use APIs compatible with that version
- avoid relying on outdated tutorials without verifying syntax

Do not silently upgrade the project to a new major Godot version.

---

# 28. Input Map

Prefer named Godot input actions.

Examples:

```text
throttle_up
throttle_down
roll_left
roll_right
fire_primary
fire_secondary
target_nearest
toggle_supercruise
request_docking
```

Do not hard-code keyboard keys directly into gameplay logic unless there is a strong reason.

---

# 29. Documentation

When adding a meaningful subsystem, leave enough documentation that another coding agent can continue it.

Document:

- why the subsystem exists
- important assumptions
- public interfaces
- unusual implementation choices

Do not write essays inside source files.

Prefer concise comments and clear code.

If a design decision meaningfully changes the project direction, update relevant project documentation.

---

# 30. Do Not Invent Requirements

If the task says:

> Add a laser weapon.

Do not also add:

- weapon rarity
- crafting
- ten ammunition types
- loot tables
- weapon vendors
- procedural manufacturers

Implement the laser weapon.

Future features can build on it later.

---

# 31. Avoid Vibe-Coding Failure Modes

Do not:

- replace large working systems without need
- create duplicate implementations of the same feature
- add unused abstractions
- invent APIs that do not exist
- claim a feature works without testing it where practical
- scatter magic constants across scripts
- create circular dependencies
- create a giant singleton containing the entire game
- add future systems just because they sound useful
- hide errors with broad exception-like behavior
- leave abandoned prototype code connected to production scenes

Prefer boring, understandable code.

---

# 32. Autoloads / Global State

Use autoloads sparingly.

Reasonable long-term candidates may include:

```text
GameState
SaveManager
SceneRouter
UniverseManager
```

Do not put ordinary ship behavior, weapon logic, enemy AI, or station behavior into global singletons.

Before adding a new autoload, consider whether the system can be a normal node or resource.

---

# 33. Current Target: Prototype 0.1

Unless repository state clearly indicates otherwise, the first prototype target is:

```text
one playable star system
```

containing approximately:

```text
Star
├── Planet
├── Planet
│   └── Station
├── Asteroid Field
└── Jump Gate
```

Required player capabilities:

- first-person ship control
- mouse aiming
- basic weapon
- one simple pirate opponent
- supercruise
- physical station approach
- docking
- launch

Not required yet:

- procedural galaxy
- economy
- full mission system
- faction simulation

---

# 34. Priority Order for Prototype 0.1

When choosing between unfinished systems, prioritize:

1. ship movement
2. camera / mouse flight
3. shooting
4. enemy combat
5. docking
6. supercruise
7. retro presentation
8. environmental polish

A visually beautiful galaxy with bad flight controls is a failed prototype.

---

# 35. Definition of Done for a Coding Task

A task is done when:

- requested behavior exists
- relevant existing behavior still works
- code fits the current architecture
- obvious errors are handled
- values that require tuning are exposed appropriately
- no unrelated large features were added
- debug leftovers are removed
- project documentation is updated if necessary
- the result has been tested as far as the environment allows

If testing cannot be performed, state exactly what remains unverified.

---

# 36. Final Guiding Principles

When uncertain, follow these priorities:

```text
FUN > REALISM

SMALL WORKING FEATURE > LARGE INCOMPLETE SYSTEM

READABLE CODE > CLEVER CODE

DETERMINISTIC GENERATION > CHAOTIC RANDOMNESS

COHERENT WORLD > MAXIMUM RANDOMNESS

GAMEPLAY DENSITY > EMPTY SCALE

ITERATION SPEED > PREMATURE ARCHITECTURE

CURRENT MILESTONE > FUTURE FEATURES
```

The core vision is:

> **A first-person retro arcade space sandbox that feels like Freelancer, takes inspiration from Elite, and can eventually expand into an effectively endless deterministic procedural universe.**
