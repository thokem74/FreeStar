# AGENTS.md

## Project FreeStar

Project FreeStar is a Godot space game developed on Omarchy with AI-assisted / vibe coding.

This file is the **single source of truth** for:

- the game concept
- gameplay direction
- technical direction
- scope boundaries
- milestone order
- repository working rules
- coding conventions
- implementation guidance for AI coding agents

Do not look for a separate game-concept document. Keep lasting design and implementation guidance in this file.

If a current user instruction conflicts with this file, follow the newer explicit user instruction. If that instruction changes a lasting project decision, update this file as part of the task.

---

# 1. Core Vision

The game is inspired primarily by **Freelancer** and **Elite**, while developing its own identity:

> **A retro low-poly, first-person arcade space sandbox set in an effectively endless procedural universe.**

The player is an independent space pilot with no fixed career.

The player should eventually be able to:

- bounty hunt
- commit piracy
- explore unknown space
- accept generated missions
- trade commodities
- improve faction reputation
- buy and upgrade ships
- discover anomalies and hidden locations
- move progressively deeper into more dangerous and strange regions of space

The desired emotional tone is similar to **Freelancer**:

- adventurous
- accessible
- action-oriented
- atmospheric
- slightly mysterious
- dense enough that space does not feel empty
- understandable without requiring hardcore simulation knowledge

The game should not aim for realistic spaceflight.

Prioritize:

- fun
- readability
- discovery
- atmosphere
- responsive controls
- strong gameplay density

---

# 2. Working List and Milestones

This is the **only milestone list** used by the project.

Do not invent alternate milestone names, prototype numbering schemes, phases, slices, or parallel roadmap labels.

```text
0.1  Flight Playground
0.2  Combat
0.3  Docking
0.4  Supercruise
0.5  Station Services
0.6  Missions
0.7  Economy
0.8  Procedural Systems
0.9  Procedural Galaxy
1.0  Core Sandbox
```

Milestones must be implemented in this general order unless the user explicitly changes the plan.

When discussing scope, use the names and numbers above.

The project principle is:

> **Build the smallest enjoyable version of the current milestone before expanding the game.**

Do not implement later-milestone systems just because they might eventually be useful.

---

# 3. Current Development Philosophy

The project is intentionally developed through small, testable AI-assisted iterations.

Avoid requests or implementations equivalent to:

> "Build the whole game."

Prefer focused tasks such as:

- add the player flight controller
- improve mouse steering
- add one basic weapon
- add one simple enemy
- add station docking
- add supercruise
- add a commodity market
- add deterministic system generation

Each task should create something testable.

The core development priorities are:

```text
FUN > REALISM

SMALL WORKING FEATURE > LARGE INCOMPLETE SYSTEM

READABLE CODE > CLEVER CODE

GOOD COMMENTS > MYSTERIOUS CODE

DETERMINISTIC GENERATION > CHAOTIC RANDOMNESS

COHERENT WORLD > MAXIMUM RANDOMNESS

GAMEPLAY DENSITY > EMPTY SCALE

ITERATION SPEED > PREMATURE ARCHITECTURE

CURRENT MILESTONE > FUTURE FEATURES
```

---

# 4. Agent Mission

When working in this repository:

1. understand the current repository state
2. identify the current milestone
3. inspect the relevant scenes, scripts, resources, and project settings
4. implement only the requested feature and necessary supporting work
5. preserve existing working behavior
6. keep the implementation small and understandable
7. test the result where practical
8. document important behavior and decisions
9. leave the codebase easier to understand and continue

This is a solo-development project using AI-assisted coding.

Optimize for:

- clarity
- iteration speed
- maintainability
- testability
- understandable architecture
- fun gameplay

Do not optimize for hypothetical future requirements that have not been requested.

---

# 5. Before Changing Code

Before implementing a task:

1. inspect the relevant files and scenes
2. inspect `project.godot` when input, rendering, physics, or project settings matter
3. identify the smallest set of files that need changing
4. check whether a similar system already exists
5. understand existing conventions before adding new ones
6. verify the Godot version used by the project
7. avoid broad refactors unless they are necessary for the requested feature

Do not rewrite working systems merely because another architecture might also work.

Do not create duplicate implementations of existing behavior.

---

# 6. Technology

Primary engine:

```text
Godot 4
```

The repository currently targets Godot 4.7.x unless the project configuration later changes explicitly.

Preferred scripting language:

```text
GDScript
```

Prefer Godot-native solutions.

Prefer:

- scenes
- nodes
- resources
- signals
- composition
- small focused scripts
- editor-exposed tuning values
- data-driven configuration where it adds clear value

Avoid external dependencies unless they provide strong, immediate value.

Do not silently upgrade the project to a different Godot major version.

Use APIs compatible with the project's configured Godot version.

---

# 7. Code Readability and Comments

Readable code is a project requirement.

The code should be understandable when another developer or coding agent reads it later without needing to reconstruct the original conversation.

Use:

- descriptive class names
- descriptive method names
- descriptive variable names
- clear scene and node names
- small focused functions
- straightforward control flow
- typed GDScript where practical

## Comments Are Required Where They Improve Understanding

Write **good, readable comments** that explain the software.

Comments should help a reader understand:

- why a system exists
- what a component is responsible for
- how important data flows through the system
- why a non-obvious implementation choice was made
- gameplay assumptions
- coordinate-space assumptions
- state transitions
- formulas that are not self-explanatory
- relationships between scenes or components
- temporary limitations that future work must understand
- deterministic-generation assumptions

Good example:

```gdscript
# Convert the mouse offset from the HUD reticle into a desired local
# pitch/yaw rate. The ship responds gradually so mouse flight feels
# responsive without snapping directly to the steering indicator.
func update_mouse_steering(delta: float) -> void:
    ...
```

Another good example:

```gdscript
# Supercruise uses a separate speed model from normal flight.
# Normal-flight velocity is restored when leaving supercruise so the
# transition does not inject an enormous physical velocity into combat.
func exit_supercruise() -> void:
    ...
```

Avoid useless comments that merely repeat the code.

Bad example:

```gdscript
# Increase speed.
speed += acceleration
```

Prefer commenting the **intent** rather than every line.

Public or important systems should usually have a short comment near the class or major methods explaining their role.

Comments must remain accurate when code changes. Update or remove stale comments.

Code readability and useful comments are part of the **Definition of Done** for implementation tasks.

---

# 8. GDScript Style

Use typed GDScript where practical.

Prefer:

```gdscript
var current_speed: float = 0.0
var target: Node3D
```

Use descriptive methods:

```gdscript
enter_supercruise()
request_docking()
apply_weapon_damage()
```

Avoid cryptic names such as:

```gdscript
do_sc()
x1()
tmp2
```

Use `@export` for values that should be tuned in the Godot editor.

Use `@export_category` when it helps organize inspector values.

Example:

```gdscript
@export_category("Flight")
@export var max_speed: float = 600.0
@export var acceleration: float = 100.0
@export var deceleration: float = 120.0
@export var mouse_sensitivity: float = 0.003
@export var roll_speed: float = 1.8
```

Use constants for meaningful fixed values.

Use signals where event communication is cleaner than tightly coupled node references.

Avoid deeply coupled node-path assumptions where exported references, groups, or signals would make the relationship clearer.

---

# 9. Implementation Style

Prefer small, explicit implementations.

A component should generally have one clear responsibility.

Reasonable separation might eventually include:

```text
ship movement
weapons
health / damage
targeting
enemy AI
docking
supercruise
HUD
missions
economy
procedural generation
save data
```

Do not put all of these into one giant script.

At the same time, do not fragment simple functionality into dozens of tiny files merely for architectural purity.

Use judgment.

Prefer composition over giant inheritance hierarchies.

Avoid speculative abstraction.

Do not create a generic framework before the project actually needs one.

---

# 10. Gameplay Values Must Be Tunable

Gameplay parameters should generally be easy to tune.

Examples:

- maximum ship speed
- acceleration
- deceleration
- steering sensitivity
- roll rate
- weapon damage
- weapon cooldown
- projectile speed
- enemy health
- enemy engagement range
- docking trigger size
- supercruise acceleration
- supercruise maximum speed
- supercruise slowdown distance

Prefer editor-exposed values or data resources instead of scattering balance numbers throughout code.

---

# 11. Game Perspective

The game uses a:

> **First-person cockpit view**

The player flies from inside the ship.

A fully modeled cockpit is not required early.

The initial camera may use:

- a simple forward first-person camera
- minimal cockpit framing
- HUD-based feedback

The cockpit should not obstruct combat readability.

A more detailed cockpit can be added later if it improves the game.

---

# 12. Visual Direction

The visual style is:

> **Flat-shaded low-poly 3D with a retro 1990s PC-game aesthetic.**

Desired characteristics:

- low-poly ships
- low-poly stations
- flat shading
- limited color palettes
- simple procedural planets
- chunky HUD graphics
- retro fonts
- pixelated or low-resolution rendering
- strong silhouettes
- simple materials
- simple lighting

Possible internal rendering targets:

```text
640×360
854×480
```

The low-resolution presentation should be intentional.

Avoid chasing modern AAA realism.

Potential later effects include:

- CRT treatment
- dithering
- color banding
- subtle glow
- retro display noise

These effects are polish, not early priorities.

---

# 13. Retro Rendering Foundation

The game should eventually render the 3D presentation at a deliberately low internal resolution and scale it cleanly.

A suitable Godot approach may use:

- a low-resolution `SubViewport`
- nearest-neighbor scaling
- a full-screen presentation layer

Choose the simplest Godot-native implementation that works cleanly with the current project.

Do not add complex post-processing before basic gameplay works.

---

# 14. Flight Model

Flight is:

> **Arcade-style, not realistic Newtonian simulation.**

Desired feel:

- responsive
- easy to understand
- mouse-friendly
- fun in combat
- visually readable
- forgiving enough for docking
- predictable acceleration and deceleration

The ship should generally move in the direction the player expects.

Momentum may exist, but should not dominate the controls.

Reference feel:

> Freelancer rather than Kerbal Space Program.

Design goal:

> **Easy to fly, difficult to master.**

---

# 15. Mouse Flight

The baseline control style is mouse-driven flight.

General intent:

- mouse controls desired pitch/yaw rates; A/D controls roll
- ship smoothly rotates toward the requested direction
- keyboard controls acceleration, braking and boost
- releasing acceleration returns to cruise; braking to zero latches a stop
- later auxiliary movement can be added where useful
- aiming should remain readable during combat

Do not make the mouse feel like directly dragging a rigid body.

Avoid excessive input latency.

Use controllable smoothing.

The exact steering curve should be treated as a gameplay-tuning problem.

---

# 16. Travel Model

There are three travel scales.

## Normal Flight

Used for:

- combat
- docking
- asteroid fields
- station approaches
- local exploration
- flying around points of interest

An initial conceptual speed range may be around:

```text
0 ─────────────── 600 m/s
```

This is a tuning starting point, not a fixed simulation requirement.

## Supercruise

Used for fast travel between major locations inside one star system.

Examples:

- planet to planet
- planet to station
- station to asteroid field
- station to jump gate

The player should still steer during supercruise.

Supercruise exists to remove boring travel.

Approaching massive objects, stations, dangerous areas, or destinations should reduce effective speed or prepare the transition back to normal flight.

Supercruise is not a realistic relativistic simulation.

## Inter-System Travel

Inter-system travel initially uses a jump-gate / jump-route network.

Later possibilities may include:

- hidden jump holes
- unstable wormholes
- anomalous routes
- secret systems

Do not implement alternate jump systems before the basic network is needed.

---

# 17. Planet Design

Planets are **not landable** in the planned core game scope unless a later explicit decision changes this.

The player can eventually:

- fly near planets
- scan planets
- orbit planets
- visit orbital stations
- discover locations associated with planets

Do not implement:

- seamless planetary landing
- walking on planets
- detailed planetary terrain traversal

Planets should serve as:

- visual landmarks
- navigation anchors
- economic context
- faction context
- exploration targets
- procedural worldbuilding

Possible procedural planet parameters:

- size
- base color
- secondary color
- atmosphere
- rings
- cloud layer
- classification
- economy association
- faction ownership
- rarity
- scan data

---

# 18. Stations and Docking

Stations are important visual and gameplay landmarks.

The player should physically fly into stations.

Docking should not simply teleport the ship after clicking a menu option.

Desired docking flow:

```text
approach station
    ↓
request or receive docking clearance
    ↓
receive visual docking guidance
    ↓
fly toward docking entrance
    ↓
enter docking tunnel / hangar
    ↓
autodock may engage sufficiently deep inside
    ↓
transition to station services
```

This keeps docking satisfying without making every landing unnecessarily tedious.

The player does not walk around stations.

---

# 19. Station Services

After docking, use an atmospheric retro station interface.

Possible service sections:

```text
MISSION BOARD
SHIP DEALER
EQUIPMENT
COMMODITY MARKET
FACTIONS
LAUNCH
```

Potential later presentation enhancements:

- low-resolution portraits
- station announcements
- generated advertisements
- faction imagery
- ship previews
- station-specific backgrounds

Prioritize functionality and readability before presentation polish.

---

# 20. Combat

Combat should feel closer to Freelancer than to a hardcore space simulator.

Preferred concepts:

- mouse-driven aiming
- ship rotates toward aim direction
- targeting reticle
- target lead indicator
- readable enemy markers
- responsive weapons
- clear hit feedback

Possible initial weapons:

- pulse laser
- plasma cannon
- mass driver
- missile launcher

Possible later weapons:

- railgun
- ion cannon
- EMP weapon
- torpedo
- mining laser
- tractor beam

Weapons may use:

- weapon energy
- ammunition
- cooldowns

Do not build a large weapon taxonomy early.

---

# 21. Enemy AI

Early enemy AI should remain simple.

A basic combat enemy only needs to:

```text
acquire player
approach
maintain approximate engagement range
aim
shoot
reposition
```

It does not need advanced squad tactics.

Prefer readable, tunable state-based behavior over complicated AI architecture.

AI should be good enough to test combat feel.

---

# 22. Ships

The game should eventually support multiple ship classes.

Suggested classes:

- Scout
- Interceptor
- Light Fighter
- Heavy Fighter
- Freighter
- Gunship
- Explorer

Ships may differ in:

- hull
- shields
- speed
- maneuverability
- cargo capacity
- weapon hardpoints
- utility hardpoints
- power capacity

Example concept:

```text
Raptor Mk II

Hull       ███████░░░
Shield     █████░░░░░
Speed      ████████░░
Cargo      ███░░░░░░░

Hardpoints:
2 × Light Weapon
2 × Medium Weapon
1 × Missile
1 × Utility
```

The player may eventually own multiple ships stored at stations.

That is not an early requirement.

---

# 23. Procedural Ship Manufacturers

Manufacturers may later be procedurally generated.

Example names:

```text
ARCADIA DYNAMICS
KORVAX INDUSTRIES
```

Manufacturers may eventually influence:

- silhouettes
- material palettes
- engine styles
- weapon compatibility
- stat tendencies
- branding

This is a later system and should not be implemented before it supports actual gameplay.

---

# 24. Main Player Activities

The primary activities are:

1. bounty hunting
2. piracy
3. exploration
4. missions

Trading also exists, but it is not intended to be the only central activity.

---

# 25. Bounty Hunting

Possible loop:

1. accept bounty
2. travel to target region
3. locate target
4. fight target and possible escorts
5. destroy or disable target
6. receive or return for payment
7. gain faction reputation

Keep the first implementation simple.

---

# 26. Piracy

Initial piracy should be straightforward.

Possible loop:

- identify cargo ship
- attack ship
- force cargo drops
- collect cargo
- evade authorities
- sell legal or illegal goods

Do not implement complex boarding or ship capture early.

---

# 27. Exploration

Exploration should provide meaningful discoveries rather than empty travel.

Possible discoveries:

- abandoned ships
- derelict stations
- asteroid bases
- ancient satellites
- battle wreckage
- unknown signals
- strange beacons
- pirate ambushes
- spatial anomalies
- hidden jump holes
- alien structures
- rare planets
- hidden systems

Exploration should sometimes reveal:

- new routes
- hidden locations
- rare resources
- unusual missions
- unknown systems

Example:

```text
Known route:

A──B──C──D
      │
      E

Hidden route discovered:

A──B──C──D
      │
      E
      :
      :
      X
```

---

# 28. Missions

Missions should eventually be procedurally generated from understandable templates.

Possible mission families:

- bounty
- patrol
- escort
- defend
- destroy
- delivery
- smuggling
- exploration
- scan
- recovery
- anti-pirate
- pirate raid

Mission templates may reference:

```text
faction
target
location
reward
difficulty
```

Later, factions may produce short mission chains.

Do not attempt large-scale procedural narrative generation early.

---

# 29. Economy

Use a simple Elite-style:

> **buy low / sell high**

economy.

Do not build a full real-time production simulation.

Stations may have:

- commodity supply
- commodity demand
- price modifiers
- faction modifiers
- system-type modifiers
- local modifiers

Possible commodities:

- food
- machinery
- ore
- fuel
- medicine
- electronics
- luxury goods
- weapons
- contraband

The economy should be understandable and useful for gameplay.

It does not need to simulate every cargo shipment in the galaxy.

---

# 30. Player Progression

Player progression should eventually combine several systems.

## Money

Used for:

- buying ships
- buying weapons
- upgrading equipment
- buying cargo
- repairs

## Reputation

Used for:

- unlocking missions
- faction access
- better rewards
- station permissions
- legal / illegal relationships

## Exploration

Used for:

- discovering systems
- revealing routes
- finding rare locations
- unlocking knowledge

## Skills / Perks

Skills or perks may exist but should remain lightweight.

The game should remain primarily about:

- flying
- equipment
- ship choice
- player skill

Avoid turning the game into a stat-heavy RPG.

---

# 31. Death and Failure

Death and failure rules are not yet fully decided.

Possible later models:

- reload latest save
- respawn at previous station with a financial penalty
- ship loss with an insurance-like recovery system

For early milestones, restarting the local scene or restoring the last safe state is sufficient.

Do not spend significant implementation time on death penalties early.

---

# 32. Universe Generation

The universe should eventually be **completely procedural**.

There should not be a fixed handcrafted main galaxy required for the game to function.

Handcrafted content may eventually be layered on top, but procedural generation should be capable of creating the world structure independently.

---

# 33. Deterministic Generation

The universe should be deterministic.

Example:

```text
GALAXY_SEED = 4815162342
```

The same universe seed must generate the same broad content:

- sectors
- star systems
- planets
- stations
- factions
- system names
- markets
- jump routes
- environmental properties

Determinism is a core technical requirement.

Avoid relying on random behavior that may change across sessions or platforms.

Store explicit seeds where useful.

---

# 34. Sector-Based Universe Architecture

The endless galaxy should not exist entirely in memory.

Divide the galaxy into procedural sectors.

Conceptually:

```text
Sector (-3, 8)
Sector (-2, 8)
Sector (-1, 8)

Sector (-3, 7)
Sector (-2, 7) ← PLAYER
Sector (-1, 7)

Sector (-3, 6)
Sector (-2, 6)
Sector (-1, 6)
```

A sector should generate its contents from coordinates plus the galaxy seed.

Conceptual example:

```gdscript
sector_seed = stable_sector_hash(sector_coordinates, galaxy_seed)
```

Do not depend on a hashing method whose result might change between sessions or platforms.

Only nearby or needed sectors should exist in active memory.

---

# 35. Sector Content

A sector may eventually generate:

- stars
- star systems
- system names
- planets
- stations
- asteroid fields
- factions
- economies
- pirate activity
- anomalies
- jump connections

The architecture should be capable of scaling from a few systems to an extremely large galaxy without requiring the entire galaxy to be loaded.

---

# 36. Star System Structure

A generated system may contain:

```text
Star
├── Planet
├── Planet
│   └── Station
├── Asteroid Field
├── Trade Route
├── Pirate Area
├── Hidden Signal
└── Jump Gate
```

Possible system components:

- one or more stars
- planets
- moons
- orbital stations
- asteroid fields
- jump gates
- pirate bases
- wrecks
- anomalies
- patrol zones
- trade routes

Not every system needs every feature.

---

# 37. System Archetypes

Systems should not feel like random collections of unrelated objects.

A procedural system should have a broad identity.

Possible archetypes:

- wealthy industrial system
- agricultural system
- frontier colony
- mining system
- military system
- pirate-controlled region
- research system
- trade hub
- isolated outpost
- anomalous / mysterious region

The archetype should influence:

- station types
- faction presence
- ship traffic
- mission types
- pirate activity
- commodity prices
- environmental look

This creates coherent procedural generation.

---

# 38. Factions

Factions should eventually be procedural but understandable.

Possible archetypes:

- corporations
- planetary governments
- pirate clans
- mercenary guilds
- miners
- traders
- research organizations
- military factions
- religious organizations

Possible generated properties:

- name
- colors
- emblem
- archetype
- preferred ship style
- allies
- enemies
- aggression
- lawfulness
- economy preference
- mission preference

Example names:

```text
Helios Mining Combine
Vega Free Corsairs
Orion Colonial Authority
```

The goal is procedural variety with understandable gameplay roles.

---

# 39. Persistence Model

Do not build a deeply persistent universe simulation.

Regenerate base world content deterministically.

Store only meaningful player state and important changes.

Potential save data:

```text
Universe seed
Player location
Credits
Current ship
Owned ships
Equipment
Cargo
Faction reputation
Known / discovered systems
Completed missions
Important discoveries
```

Do not permanently store every generated NPC or temporary encounter.

Do not attempt an MMO-style persistent universe.

---

# 40. Gameplay Density

A major design principle is:

> **Space should feel large, but gameplay should not feel empty.**

Interesting local areas should often contain some combination of:

- patrols
- traders
- convoys
- pirates
- distress calls
- wrecks
- anomalies
- stations
- asteroid fields
- mission targets

Supercruise should skip boring travel between meaningful areas.

Normal flight should happen where interesting interactions can occur.

---

# 41. Procedural Stations

Stations may eventually be constructed from reusable modules.

Possible modules:

```text
core
habitat
solar array
dock
cargo ring
antenna
industrial block
defense turret
refinery
hangar
```

Example:

```text
Industrial Station
├── central cylinder
├── two cargo rings
├── six docking arms
├── refinery module
└── four solar arrays
```

The generator may vary:

- module count
- module placement
- silhouette
- scale
- faction styling
- color palette

Do not build a complex procedural station generator before milestone 0.8 requires procedural systems.

---

# 42. Assets

Placeholder assets are encouraged during prototyping.

Simple primitives are acceptable.

Examples:

```text
box = station module
sphere = planet
capsule = ship body
cylinder = engine
```

Gameplay should not be blocked by missing final art.

AI-generated or externally sourced assets may eventually be used for:

- UI concepts
- portraits
- faction emblems
- advertisements
- texture concepts
- ship design references
- station signage
- background art
- icons

Keep licensing and provenance clear for external assets.

Do not add copyrighted third-party assets without a clear license.

The low-poly retro direction is intentionally chosen to reduce asset-production burden.

---

# 43. Suggested Repository Structure

This is a starting direction, not a rigid requirement.

```text
res://
├── scenes/
│   ├── player/
│   ├── ships/
│   ├── stations/
│   ├── planets/
│   ├── systems/
│   ├── weapons/
│   ├── ui/
│   └── test/
│
├── scripts/
│   ├── flight/
│   ├── combat/
│   ├── docking/
│   ├── travel/
│   ├── procedural/
│   ├── missions/
│   ├── economy/
│   ├── factions/
│   └── persistence/
│
├── data/
│   ├── ships/
│   ├── weapons/
│   ├── commodities/
│   ├── faction_archetypes/
│   └── station_modules/
│
├── assets/
│   ├── models/
│   ├── textures/
│   ├── audio/
│   └── fonts/
│
└── autoload/
```

Do not create empty directory structures far ahead of the current milestone unless they make the repository clearer.

---

# 44. Scene Organization

Prefer reusable scenes.

Possible examples:

```text
PlayerShip.tscn
EnemyShip.tscn
Station.tscn
Planet.tscn
Projectile.tscn
HUD.tscn
FlightPlayground.tscn
```

Do not duplicate complete scene setups when composition or scene inheritance clearly improves maintenance.

Do not build abstract scene factories before they are needed.

---

# 45. Data Organization

Use Godot Resources where useful for reusable game data.

Possible data resources:

```text
ShipData
WeaponData
CommodityData
FactionArchetype
StationArchetype
```

Example:

```gdscript
class_name WeaponData
extends Resource

@export var display_name: String
@export var damage: float
@export var fire_rate: float
@export var projectile_speed: float
```

Do not create a universal generic data framework.

Use straightforward project-specific resources.

---

# 46. Input Map

Prefer named Godot input actions.

Possible actions:

```text
accelerate
brake_reverse
boost
mouse_roll
roll_left
roll_right
fire_primary
fire_secondary
target_nearest
toggle_supercruise
request_docking
```

Do not hard-code keyboard keys directly into gameplay logic unless there is a strong reason.

Mouse motion can be processed through Godot input events as appropriate.

---

# 47. UI and HUD

UI should be readable before decorative.

Prefer:

- strong contrast
- large readable indicators
- simple shapes
- clear target markers
- clear speed and flight-mode information
- retro aesthetic

The HUD may eventually communicate:

```text
speed
flight mode
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

# 48. Error Handling

Fail clearly during development.

If a required node or resource is missing, prefer an understandable error over silently doing the wrong thing.

Use warnings for recoverable setup issues.

Avoid debug logs that print every frame.

Temporary logging is acceptable during implementation, but remove noisy or obsolete logs before finishing the task.

---

# 49. Testing

For each feature, test the smallest relevant gameplay path.

## Flight

Verify:

- scene starts correctly
- movement starts
- acceleration, cruise, braking and boost work
- acceleration works
- deceleration works
- mouse turning works
- roll works
- speed cap works

## Combat

Verify:

- weapon fires
- projectile or ray hits
- damage is applied
- enemy can be destroyed
- basic combat remains controllable

## Docking

Verify:

- station can be approached
- entrance is understandable
- docking trigger activates correctly
- station state appears
- launch returns the player to flight

## Supercruise

Verify:

- mode enters correctly
- acceleration behaves predictably
- player retains steering control
- slowdown works
- mode exits correctly
- normal-flight state is restored sensibly

## Procedural Generation

Verify:

- same seed produces same result
- different seed produces different result
- obvious invalid configurations are avoided
- generation does not depend on frame timing

When practical, add small deterministic tests for non-scene logic.

---

# 50. Performance

Do not prematurely optimize.

Avoid obviously unbounded behavior.

Bad:

```text
spawn thousands of active ships
keep every visited system loaded forever
run expensive generation every frame
```

Good:

```text
generate content when entering a region
despawn distant temporary encounters
cache data when useful
load only relevant sectors
pool objects only when measurement shows it helps
```

Measure before major optimization work.

---

# 51. Autoloads and Global State

Use autoloads sparingly.

Possible long-term candidates:

```text
GameState
SaveManager
SceneRouter
UniverseManager
```

Do not put ordinary ship behavior, weapon logic, enemy AI, or station behavior into global singletons.

Before adding an autoload, consider whether the system can remain a normal node or resource.

Avoid hidden global state.

---

# 52. Scope Guardrails

Do not implement the following unless explicitly requested by the user:

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
- fully simulated ship interiors
- seamless loading of the entire galaxy
- hundreds of weapons before the core combat loop works
- hundreds of handcrafted ships before ship variety is needed

If a task appears to imply one of these systems, implement the smallest alternative that satisfies the immediate gameplay requirement.

---

# 53. Do Not Invent Requirements

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

If the task says:

> Add docking.

Do not also add:

- station walking
- ship repair economy
- faction customs
- hangar inventory management

Implement docking.

Future milestones can build on working foundations.

---

# 54. Avoid AI-Assisted Coding Failure Modes

Do not:

- replace large working systems without need
- create duplicate implementations
- add unused abstractions
- invent Godot APIs that do not exist
- claim a feature works without testing it where practical
- scatter magic constants across scripts
- create circular dependencies
- create a giant singleton containing the whole game
- add future systems just because they sound useful
- hide errors
- leave abandoned prototype code connected to production scenes
- leave outdated comments that no longer match behavior
- generate enormous files when a few focused components are clearer

Prefer boring, understandable code.

---

# 55. Documentation Rules

This `AGENTS.md` is the project's main living design and implementation guide.

Update it when a user decision materially changes:

- core game design
- scope
- milestone definitions
- technical principles
- major architecture rules
- long-term procedural-generation assumptions

Do not update it for every tiny code change.

Source-code comments should explain implementation details close to the relevant code.

This file should explain project-wide intent.

---

# 56. Milestone 0.1 — Flight Playground

## Goal

Create a runnable playground where the player can judge whether basic first-person arcade flight feels good.

## Implement

- runnable main test scene
- reusable player ship scene
- first-person camera
- mouse steering
- acceleration, cruise, braking and boost
- acceleration
- deceleration
- mouse pitch/yaw and keyboard roll
- speed cap
- basic HUD
- retro rendering foundation
- visible landmarks that make motion and orientation easy to judge

Suggested test landmarks:

- large distant planet placeholder
- floating structures
- simple station-like silhouette
- objects at several distances
- directional landmarks

Use primitive geometry where practical.

## HUD

At minimum display:

- aiming reticle
- current speed
- current flight mode

## Success Criteria

- project launches directly into a playable scene
- player can immediately fly
- mouse steering feels smooth and understandable
- acceleration, return to cruise, braking and boost behave predictably
- acceleration and deceleration are readable
- speed cap is enforced
- roll works
- visible landmarks make movement easy to judge
- low-resolution retro presentation works
- code is clearly structured
- important code contains useful explanatory comments

## Agreed Flight Playground Defaults

- No Man's Sky-inspired arcade controls: mouse-offset pitch/yaw with a bounded
  steering reticle and non-inverted pitch; A/D rolls.
- W accelerates, Left Shift boosts; S brakes through zero, then reverses while held.
- Space does nothing. No Q/E or R/F thrust. Hold RMB to use horizontal reticle
  offset for roll instead of yaw; pitch remains available and A/D roll combines
  with mouse roll within the rate cap. Modifier transitions clear horizontal
  offset and residual yaw/roll, retaining pitch.
- Start stationary. W or Shift activates flight; release returns to cruise.
- S overrides acceleration/boost. Releasing S completes a stop without cruise;
  W/Shift can cancel stopping after S is released. Direction changes stop at zero
  before accelerating the opposite way. Shift takes priority over W.
- Initial speeds: 150 m/s cruise, 600 m/s normal maximum, 1,200 m/s boost maximum.
- Acceleration: 200 m/s² normal, 400 m/s² boost. Automatic deceleration: 300 m/s²;
  braking/direction changes: 600 m/s². Reverse maximum: 150 m/s; reverse acceleration:
  200 m/s². No automatic banking or boost energy system.
- Boost retains steering authority and is local flight, not milestone 0.4 Supercruise.
- C centers steering; Home resets position, speed, rotation requests and cruise state.
- Esc/focus loss pauses flight; left click resumes with centered steering and
  preserved stopped/cruise state.
- HUD shows actual movement speed and STOPPED, CRUISE, ACCELERATING, BRAKING, BOOST or REVERSING.
- Solid local landmarks block and slide without damage; the distant planet is scenery.
- Render world/HUD at 854×480 with nearest-neighbor scaling and black bars.
- Prefer integer enlargement, proportional downscaling for smaller windows.
- Default window: 1708×960. Minimal cockpit framing leaves the center clear.
- Initial steering: 90°/s pitch/yaw, 100°/s roll, 80° camera FOV.
- All gameplay values above are inspector-exposed playtesting defaults.

## Not Part of 0.1

Do not implement:

- weapons
- enemies
- docking flow
- supercruise
- station services
- missions
- economy
- procedural generation

---

# 57. Milestone 0.2 — Combat

## Goal

Add a small but satisfying combat loop on top of working flight.

## Implement

- one basic weapon
- fire input
- projectile or ray-based hit detection
- damage interface
- hull and/or simple shield state
- one simple enemy ship
- basic enemy chase / attack behavior
- enemy destruction
- basic combat HUD information
- useful hit feedback

Possible first weapon:

```text
Pulse Laser
```

## Success Criteria

- combat is understandable
- weapon fire feels responsive
- enemy can attack the player
- player can destroy the enemy
- mouse flight remains comfortable during combat
- combat-related code is separated cleanly from flight
- non-obvious combat logic is explained by readable comments

## Not Part of 0.2

Do not add:

- large weapon catalogs
- loot systems
- advanced squad AI
- procedural enemy factions
- boarding
- ship capture

---

# 58. Milestone 0.3 — Docking

## Goal

Make flying into a station satisfying and establish the transition between flight and station state.

## Implement

- simple low-poly test station
- visually understandable entrance
- docking corridor or hangar
- docking clearance state
- guidance indicators where useful
- docking trigger
- transition to a placeholder station state
- launch back into flight

## Success Criteria

- station approach is readable
- player physically flies into the station
- docking does not trigger incorrectly from outside
- station state is entered reliably
- player can launch and return to flight
- docking logic is understandable in code and comments

## Not Part of 0.3

Do not implement:

- walking inside stations
- complex station services
- procedural station construction
- complex docking traffic control

---

# 59. Milestone 0.4 — Supercruise

## Goal

Remove boring in-system travel while keeping travel interactive.

## Implement

- supercruise mode/state
- enter/exit controls
- high-speed acceleration
- steering while travelling
- destination marker
- slowdown near destination
- clean transition to normal flight
- clear HUD state

## Success Criteria

- long-distance travel is much faster than normal flight
- player remains in control
- approach to destinations is manageable
- mode transitions are predictable
- supercruise does not inject unusable normal-flight velocities
- travel state code contains comments explaining important transitions

## Not Part of 0.4

Do not implement:

- realistic relativistic physics
- galaxy jumps
- hidden wormholes
- procedural system generation

---

# 60. Milestone 0.5 — Station Services

## Goal

Turn a docked station into a useful gameplay hub.

## Implement Simple Versions Of

- mission board
- equipment screen
- commodity market entry point
- ship information
- factions overview if needed by current data
- launch control

The UI may use placeholder data where later systems are not available yet.

## Success Criteria

- docking leads to a clear station interface
- navigation is understandable
- services are modular enough for later systems
- launch reliably returns to space
- interface matches the retro direction without sacrificing readability

---

# 61. Milestone 0.6 — Missions

## Goal

Give the player repeatable objectives that connect flight, combat, docking, and travel.

## Implement A Few Templates

Start with a small selection such as:

- bounty
- patrol
- delivery
- scan

Mission data should be explicit and understandable.

Possible fields:

```text
mission type
issuer
target
location
reward
difficulty
state
```

## Success Criteria

- player can accept a mission
- objective is visible
- progress is tracked
- mission can succeed or fail
- reward can be granted
- mission templates can reuse game locations and entities

Do not build complex procedural stories.

---

# 62. Milestone 0.7 — Economy

## Goal

Add a simple commodity trading loop.

## Implement

- commodity definitions
- player cargo
- station markets
- buy action
- sell action
- station price modifiers
- cargo capacity
- credits integration

## Success Criteria

- prices differ meaningfully between stations
- player can buy and carry commodities
- player can sell commodities
- transactions update credits and cargo correctly
- system remains simple enough to understand

Do not simulate galaxy-wide production chains.

---

# 63. Milestone 0.8 — Procedural Systems

## Goal

Generate coherent star-system content from deterministic seeds.

This milestone is about **individual procedural systems**, not the whole galaxy.

## Implement

- stable system seed
- generated star
- generated planets
- generated station placements
- generated asteroid fields
- generated points of interest
- system archetype
- deterministic names where needed
- coherent content based on the archetype

## Success Criteria

- same seed creates the same system
- different seeds create meaningful variation
- generated objects are spatially usable
- systems have recognizable character
- generated content supports existing gameplay
- generation code is clearly documented, especially seed derivation and coordinate assumptions

Do not create the entire galaxy yet.

---

# 64. Milestone 0.9 — Procedural Galaxy

## Goal

Connect procedural systems into an effectively endless deterministic galaxy.

## Implement

- sector coordinates
- deterministic sector generation
- systems inside sectors
- stable system identifiers
- jump network
- nearby-sector loading
- unloading of irrelevant sectors
- galaxy seed
- discovery state where required

## Success Criteria

- same galaxy seed creates the same galaxy structure
- player can move between generated systems
- nearby content loads as needed
- distant content is not kept active unnecessarily
- jump connectivity is valid enough for gameplay
- procedural code explains seed hierarchy and stable identifiers in comments

---

# 65. Milestone 1.0 — Core Sandbox

## Goal

Combine the working systems into the intended FreeStar sandbox experience.

## Integrate

- flight
- combat
- docking
- supercruise
- station services
- missions
- economy
- procedural systems
- procedural galaxy
- exploration
- progression
- piracy
- bounty hunting
- procedural factions where required by gameplay

## Desired Player Loop

```text
Dock at station
    ↓
Check missions / equipment / market
    ↓
Launch manually
    ↓
Fly through local space
    ↓
Combat / exploration / encounters
    ↓
Enter supercruise
    ↓
Reach another planet / station / jump gate
    ↓
Complete mission or make a discovery
    ↓
Earn credits + reputation
    ↓
Upgrade ship
    ↓
Travel deeper into the galaxy
```

## Success Criteria

The game should feel like a coherent sandbox rather than a collection of disconnected prototypes.

The player should be able to:

- fly
- fight
- dock
- travel quickly inside systems
- use station services
- accept missions
- trade
- explore generated systems
- move between generated systems
- earn progression
- choose lawful or unlawful activity

The game does not need large amounts of content if the systems combine into an enjoyable repeatable loop.

---

# 66. Definition of Done for a Coding Task

A task is done when:

- the requested behavior exists
- the implementation matches the current milestone
- relevant existing behavior still works
- code fits the current architecture
- code is readable
- important logic contains useful explanatory comments
- comments accurately describe the current implementation
- obvious errors are handled
- values that require tuning are exposed appropriately
- unrelated large features were not added
- noisy debug leftovers are removed
- relevant documentation is updated if a lasting project decision changed
- the result has been tested as far as the environment allows

If testing cannot be performed, state exactly what remains unverified.

---

# 67. Final Direction

When uncertain, return to the core concept:

> **Build a first-person retro arcade space sandbox in Godot that feels like Freelancer, takes inspiration from Elite, and can eventually expand into an effectively endless deterministic procedural universe.**

Prioritize:

1. fun arcade flight
2. satisfying combat
3. physical docking
4. fast and enjoyable travel
5. useful station interactions
6. understandable missions
7. simple economy
8. coherent procedural systems
9. deterministic galaxy generation
10. a sandbox where exploration, bounty hunting, piracy, missions, and progression reinforce each other

Avoid premature scope.

Build the current milestone well before moving to the next one.
