# Project FreeStar — Game Concept

## Purpose

This document is the primary game-design and product brief for Project FreeStar, a Godot game developed on Omarchy with heavy use of AI-assisted / vibe coding.

The game is inspired primarily by **Freelancer** and **Elite**, but is intended to have its own identity:

> **A retro low-poly, first-person space sandbox set in an effectively endless, fully procedural universe.**

The player is an independent pilot who can take missions, hunt pirates, become a pirate, explore unknown systems, trade, improve their reputation, buy better equipment and ships, and travel indefinitely through procedurally generated space.

This file is the primary source of truth for the game's intended design, scope, gameplay direction, and roadmap.

Repository workflow, coding behavior, and agent operating rules belong in `AGENTS.md`. When the two files cover the same topic, use `GAME_CONCEPT.md` for game-design intent and `AGENTS.md` for implementation process.

---

# 1. Core Game Fantasy

The player is an independent space pilot in an effectively endless procedural galaxy.

There is no fixed career path.

The player should be able to:

- bounty hunt
- commit piracy
- explore
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
- easy to understand without requiring hardcore simulation knowledge

The game should not aim for realistic spaceflight.

It should prioritize fun, readability, discovery, and atmosphere.

---

# 2. Confirmed Design Decisions

## Perspective

**First-person cockpit view.**

The player flies from inside the ship.

The exact cockpit implementation can initially be simple. A full complex simulated cockpit is not required for **0.1 — Flight Playground**.

---

## Visual Style

**Flat-shaded low-poly 3D with a retro 1990s PC game aesthetic.**

Desired visual characteristics:

- low-poly ships
- low-poly stations
- flat shading
- limited color palettes
- simple procedural planets
- chunky HUD graphics
- retro fonts
- pixelated or low-resolution rendering
- strong silhouettes
- simple materials rather than physically realistic rendering
- optional CRT / dithering / color-banding effects later

Possible internal rendering targets:

- 640×360
- 854×480

The low-resolution presentation should be a deliberate style choice, not simply poor graphics.

Avoid chasing modern AAA realism.

---

## Flight Model

**Arcade-style flight.**

Do not build fully Newtonian flight physics.

The desired feel is closer to Freelancer:

- easy to control
- responsive
- mouse-friendly
- readable in combat
- momentum can exist, but should not dominate the controls
- the ship should generally go where the player expects

Design goal:

> Easy to fly, difficult to master.

---

## Travel Model

There are three major movement modes.

### 1. Normal Flight

Used for:

- combat
- docking
- asteroid fields
- station approaches
- local exploration
- flying around points of interest

Example conceptual speed range:

```text
0 ─────────────── 600 m/s
```

This is only a starting idea and should be tuned for fun.

### 2. Supercruise

Used for fast travel between major locations inside one star system.

Examples:

- planet to planet
- planet to station
- station to asteroid field
- station to jump gate

The player still flies and steers.

Supercruise should avoid forcing the player to spend long periods crossing empty space.

Approaching massive objects, stations, combat areas, or destinations should reduce allowable speed or automatically transition the ship toward normal flight.

### 3. Inter-System Jump Travel

Used to move between star systems.

The initial design should use a **jump-gate / jump-route network**, similar to Freelancer.

Later additions may include:

- hidden jump holes
- unstable wormholes
- anomalous routes
- secret systems

---

# 3. Planet Design

Planets are **not landable** in the initial game.

The player can:

- fly near planets
- scan planets
- orbit planets
- visit orbital stations
- discover locations associated with planets

Do NOT implement seamless planetary landing early.

Do NOT implement walking on planets early.

Planets should instead serve as:

- visual landmarks
- navigation anchors
- economic / faction context
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

# 4. Stations and Docking

Stations are important visual and gameplay landmarks.

The player should **physically fly into stations**.

Docking should not simply be a menu command that teleports the ship.

Suggested docking flow:

1. approach station
2. request or receive docking clearance
3. station provides visual docking guidance
4. fly toward docking entrance
5. enter docking tunnel / hangar
6. once sufficiently inside, autodock may engage
7. transition to station interface

This preserves the satisfaction of manual docking without making every landing tedious.

---

## Station Interior Scope

The player does **not** walk around stations in the initial game.

After docking, use a station interface instead.

Possible station interface sections:

```text
MISSION BOARD
SHIP DEALER
EQUIPMENT
COMMODITY MARKET
FACTIONS
LAUNCH
```

The interface should feel atmospheric and retro.

Possible later enhancements:

- low-resolution portraits
- station announcements
- generated advertisements
- faction imagery
- ship previews

---

# 5. Combat

Combat should feel similar to Freelancer rather than a hard space simulator.

Preferred initial control concept:

- mouse-driven aiming
- ship rotates toward aim direction
- optional keyboard support for thrust / strafe / roll
- targeting reticle
- lead indicator
- readable enemy markers

The game should eventually support both mouse-centric and more traditional control schemes where practical, but mouse flight is the preferred baseline.

---

## Initial Weapon Concepts

Start simple.

Possible first weapons:

- pulse laser
- plasma cannon
- mass driver
- missile launcher

Later possibilities:

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

Avoid building a huge weapon taxonomy early.

---

# 6. Ships

The game should support multiple ship classes.

Suggested classes:

- Scout
- Interceptor
- Light Fighter
- Heavy Fighter
- Freighter
- Gunship
- Explorer

Ships should have meaningful differences in:

- hull
- shields
- speed
- maneuverability
- cargo
- weapon hardpoints
- utility hardpoints
- power capacity

Example:

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

---

## Ship Ownership

The eventual design may allow the player to own multiple ships stored at stations.

This is not required for the first vertical slice.

---

## Procedural Manufacturers

Manufacturers may later be procedurally generated.

Examples:

```text
ARCADIA DYNAMICS
KORVAX INDUSTRIES
```

Different manufacturers may eventually influence:

- silhouettes
- material palette
- engine style
- weapon compatibility
- stat tendencies
- branding

This is a later system, not an early requirement.

---

# 7. Main Activities

The player's primary activities are:

1. **Bounty hunting**
2. **Piracy**
3. **Exploration**
4. **Missions**

Trading exists, but it is not intended to be the only core activity.

---

## Bounty Hunting

Possible loop:

1. accept bounty
2. travel to target region
3. locate target
4. fight target and escorts
5. destroy or disable target
6. return or receive payment
7. gain faction reputation

---

## Piracy

Initial piracy should be straightforward:

- attack cargo ships
- cause cargo to drop
- collect cargo
- evade authorities
- possibly sell contraband

Do not implement complex boarding or ship capture early.

Those can be considered later.

---

## Exploration

Exploration should be meaningful.

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

Exploration should sometimes reveal new routes or locations.

Example:

```text
Known route:

A──B──C──D
      │
      E

Anomaly discovered:

A──B──C──D
      │
      E
      :
      :
      X

X = hidden / unknown system
```

---

# 8. Missions

Missions should eventually be procedurally generated.

Initial mission families may include:

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

Later, procedural factions may generate short mission chains.

However:

> Do not attempt a complex procedural narrative generator early.

Start with understandable mission templates that use generated locations, factions, rewards, and targets.

---

# 9. Economy

Use a **simple Elite-style buy-low / sell-high economy**.

Do not build a full simulated production economy early.

Stations can have:

- commodity supply
- commodity demand
- price modifiers
- faction modifiers
- system-type modifiers

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

# 10. Player Progression

Player progression should combine several systems.

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

May exist, but should remain lightweight.

The game should remain primarily about:

- flying
- equipment
- ship choice
- player skill

Avoid turning the project into a stat-heavy RPG.

---

# 11. Death and Failure

Not yet fully decided.

Potential models include:

- reload latest save
- respawn at previous station with financial penalty
- ship loss with insurance-like recovery

For early prototypes, simply restart the local scene or restore the last safe state.

Do not spend significant implementation time on death penalties yet.

---

# 12. Universe Generation

The universe should be **completely procedural**.

There should not be a fixed handcrafted main galaxy.

Handcrafted content may eventually be layered on top, but the world generation itself must work without requiring handcrafted systems.

---

## Deterministic Generation

The universe should be deterministic.

Example:

```text
GALAXY_SEED = 4815162342
```

The same universe seed must generate the same:

- sectors
- star systems
- planets
- stations
- factions
- system names
- markets
- jump routes
- broad environmental properties

This is extremely important.

---

# 13. Sector-Based Universe Architecture

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

A sector generates its contents from coordinates + galaxy seed.

Example concept:

```gdscript
sector_seed = hash(Vector3i(x, y, z)) ^ galaxy_seed
```

The exact hashing method must be deterministic and stable.

Avoid depending on unstable randomized hash behavior if it may differ between sessions or platforms.

---

## Sector Content

A sector may generate:

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

Only nearby sectors should need to exist in active memory.

This allows the galaxy to scale to extremely large sizes.

Conceptually:

```text
1 system
100 systems
10,000 systems
1,000,000 systems
```

The architecture should not fundamentally change as galaxy size increases.

---

# 14. Star System Structure

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

# 15. System Character / Archetypes

Systems should not feel like random bags of objects.

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

The system archetype should influence:

- station type
- faction presence
- ship traffic
- mission types
- pirate activity
- commodity prices
- environmental look

This creates coherent procedural generation.

---

# 16. Factions

Factions should also be procedural.

Avoid completely meaningless random faction generation.

Use reusable faction archetypes such as:

- corporations
- planetary governments
- pirate clans
- mercenary guilds
- miners
- traders
- research organizations
- military factions
- religious organizations

Generated faction properties may include:

- name
- colors
- logo / emblem
- faction archetype
- preferred ship styles
- allies
- enemies
- aggression
- lawfulness
- economy preference
- mission preference

Example generated names:

```text
Helios Mining Combine
Vega Free Corsairs
Orion Colonial Authority
```

The goal is procedural variety with understandable gameplay roles.

---

# 17. Persistence Model

The user has explicitly chosen:

> **Do not build a deeply persistent universe simulation.**

The universe can be regenerated deterministically.

The game should avoid storing huge amounts of world state.

A good long-term model is:

- regenerate base world from seed
- store player-specific changes only where useful

Potential saved information:

```text
Universe seed
Player location
Credits
Current ship
Owned ships
Equipment
Faction reputation
Known / discovered systems
Completed missions
Important discoveries
```

Do not simulate or permanently store every NPC in the galaxy.

Do not attempt an MMO-style persistent universe.

---

# 18. Density Principle

A major design principle is:

> **Space should feel large, but gameplay should not feel empty.**

Freelancer is a useful reference.

When the player reaches an interesting local area, there should often be some combination of:

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

Supercruise should skip the boring travel between meaningful areas.

Normal flight should happen where interesting interactions can occur.

---

# 19. Procedural Stations

Stations may eventually be built from reusable modules.

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

The generator can vary:

- module count
- module placement
- silhouette
- scale
- faction styling
- color palette

This can create many stations from a small asset library.

Do not attempt a perfect modular station generator in the first vertical slice.

---

# 20. AI-Generated Assets

AI-generated or externally sourced assets may be used where appropriate.

Potential use cases:

- UI concepts
- portraits
- faction emblems
- advertisements
- texture concepts
- ship design references
- station signage
- background art
- icons

For in-game runtime assets, keep licensing and provenance clear.

Prefer systems that require relatively few source assets and generate variety procedurally.

The low-poly retro art direction is intentionally chosen to reduce asset-production burden.

---

# 21. Godot Technical Direction

The game will be built in **Godot** on **Omarchy**.

Preferred scripting language unless a task specifically benefits from another option:

> **GDScript**

Keep architecture understandable for a solo developer using AI coding assistance.

Prefer:

- small components
- clear scene boundaries
- explicit data structures
- deterministic generation
- simple dependencies
- readable scripts
- easy-to-test systems

Avoid overengineering.

Avoid building giant inheritance hierarchies.

Prefer composition where practical.

---

# 22. Suggested High-Level Project Structure

This is a starting suggestion, not a strict requirement.

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

Use Godot Resources for data where they make the project easier to inspect and edit.

Do not force every system into JSON if Godot Resources are simpler.

---

# 23. Implementation Principles

When implementing features:

1. **Build the smallest working version first.**
2. Do not implement unrelated future systems.
3. Keep code modular and readable.
4. Prefer simple solutions that can later be expanded.
5. Avoid speculative abstractions.
6. Add comments where architecture is non-obvious.
7. Keep deterministic generation reproducible.
8. Avoid hidden global state.
9. Avoid giant scripts.
10. Prefer data-driven configuration for ships, weapons, commodities, and procedural archetypes.
11. Preserve existing working behavior unless the task explicitly requires changing it.
12. If a requested feature conflicts with this design brief, flag the conflict before making a large architectural change.

---

# 24. Features Explicitly Out of Scope for Early Development

Do NOT prioritize:

- planetary landing
- walking on planets
- walking around stations
- multiplayer
- colony building
- persistent NPC simulation
- detailed political simulation
- complex economic simulation
- seamless full-galaxy loading
- fully Newtonian physics
- hundreds of weapons
- hundreds of handcrafted ships
- fully simulated ship interiors
- procedural story generation at large scale
- ship boarding
- ship capture
- realistic orbital mechanics
- survival mechanics
- crafting systems

These features may be reconsidered later.

They should not distract from making the core flight experience fun.

---

# 25. Core Gameplay Loop

Target loop:

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
Complete mission or discover something
    ↓
Earn credits + reputation
    ↓
Upgrade ship
    ↓
Travel deeper into the galaxy
```

---

# 26. Development Philosophy

The project is intentionally being developed through small vibe-coding iterations.

For AI-assisted implementation, avoid broad tasks such as:

> "Build Freelancer / Elite."

Instead, implement one small feature at a time.

Good task examples:

> Add a first-person arcade spaceship controller.

> Add mouse-based aiming and rotate the ship toward the cursor.

> Add one laser weapon with hitscan or projectile damage.

> Add an enemy ship with simple chase-and-fire AI.

> Add a station docking trigger.

> Add supercruise with acceleration and automatic slowdown near destinations.

> Add deterministic star-system generation from an integer seed.

> Add a sector system that loads only the current and neighboring sectors.

> Add a simple commodity market using generated price modifiers.

Each task should produce something testable.

---

## Milestone Terminology

Use these names consistently throughout the project:

- **0.1 — Flight Playground**: flight foundation only
- **0.2 — Combat**: weapons, damage, and first enemy
- **0.3 — Docking**: station approach, docking, and launch
- **0.4 — Supercruise**: fast in-system travel
- **First Vertical Slice**: the combined playable result of milestones **0.1–0.4**

`0.1` must not be used as shorthand for the whole first vertical slice.

---

# 27. First Vertical Slice

The **first vertical slice** combines **0.1 — Flight Playground**, **0.2 — Combat**, **0.3 — Docking**, and **0.4 — Supercruise** into one playable star system.

Its goal is:

> **Make flying through one small test star system fun.**

The first playable test system should contain roughly:

```text
Star

├── Planet
│
├── Planet
│   └── Station
│
├── Asteroid Field
│
└── Jump Gate
```

The player should be able to:

- fly a ship
- aim using the mouse
- shoot a basic weapon
- fight one simple pirate
- enter / exit supercruise
- approach a station
- fly into the station
- dock
- launch again

No procedural galaxy is required for the first vertical slice.

No economy is required.

No mission system is required.

The goal is to answer:

> **Is flying around in this game fun?**

---

# 28. Proposed Development Roadmap

The milestone numbers below are authoritative for roadmap discussions and implementation tasks.

## 0.1 — Flight Playground

Implement:

- playable test scene
- player ship
- first-person camera
- mouse steering
- throttle
- arcade movement
- basic HUD
- retro rendering setup

## 0.2 — Combat

Implement:

- laser / projectile
- target
- damage
- shields / hull
- one simple enemy AI
- basic combat HUD

## 0.3 — Docking

Implement:

- station
- docking corridor / hangar
- docking clearance
- docking trigger
- station transition
- launch sequence

## 0.4 — Supercruise

Implement:

- supercruise state
- acceleration
- destination marker
- slowdown
- exit to normal flight

## 0.5 — Station Services

Implement simple versions of:

- mission board
- equipment
- market
- ship information
- launch

## 0.6 — Missions

Implement a few procedural mission templates.

Start with:

- bounty
- patrol
- delivery or scan

## 0.7 — Economy

Implement:

- commodities
- station markets
- price modifiers
- player cargo
- buy / sell UI

## 0.8 — Procedural Star System

Generate from seed:

- star
- planets
- station placements
- asteroid fields
- points of interest

## 0.9 — Procedural Galaxy

Implement:

- sectors
- system coordinates
- deterministic generation
- jump network
- nearby-sector loading

## 1.0 — Core Sandbox

Combine:

- missions
- factions
- economy
- procedural systems
- exploration
- progression
- piracy
- bounty hunting

This is the first version that should feel like the intended sandbox.

---

# 29. First Vertical Slice Suggested Implementation Tasks

The following sequence is recommended across milestones 0.1–0.4. Tasks 1–3 form the Flight Playground (0.1), tasks 4–5 add Combat (0.2), tasks 6–7 add Docking (0.3), and task 8 adds Supercruise (0.4).

## Task 1 — Create Project Skeleton

Create:

- main test scene
- player ship scene
- basic world scene
- HUD scene
- folder structure

Do not create procedural galaxy code yet.

## Task 2 — Create Arcade Ship Controller

Requirements:

- 3D movement
- throttle
- acceleration / deceleration
- mouse-driven pitch / yaw
- optional keyboard roll
- speed cap
- responsive controls
- first-person camera

The ship should feel fun rather than physically realistic.

## Task 3 — Retro Rendering

Add a simple low-resolution rendering approach.

Possible solution:

- render 3D world to a low-resolution SubViewport
- scale it to the screen using nearest-neighbor filtering

Do not overcomplicate post-processing initially.

## Task 4 — Basic Weapon

Implement one forward-firing weapon.

Requirements:

- input action
- visible projectile or ray
- hit detection
- damage interface

## Task 5 — Pirate Dummy

Create one enemy ship that can:

- fly toward player
- maintain rough combat distance
- shoot
- receive damage
- be destroyed

AI can be simple.

## Task 6 — Test Station

Create a simple low-poly station with:

- obvious entrance
- docking corridor
- docking trigger

No procedural station generation yet.

## Task 7 — Dock / Launch Flow

Allow:

- fly inside
- trigger dock
- show placeholder station UI
- launch back into the test scene

## Task 8 — Supercruise

Add a supercruise mode between two test locations.

Do not attempt realistic relativistic travel.

---

# 30. Desired Feel of the First Vertical Slice

When testing the first vertical slice, prioritize these questions:

- Does the ship feel good to control?
- Is mouse flight comfortable?
- Does shooting feel satisfying?
- Is the cockpit view readable?
- Is the retro rendering appealing?
- Is approaching a planet visually exciting?
- Does entering a station feel satisfying?
- Does supercruise remove boring travel?
- Is the game understandable without instructions?

Do not measure success by amount of content.

Measure success by feel.

---

# 31. Placeholder Project Name

Temporary working name:

> **Project FreeStar**

This is not necessarily the final game title.

Use it for folders, documentation, and early project naming where convenient.

---

# 32. Summary

When uncertain, remember the central concept:

> Build a first-person arcade space sandbox in Godot that feels like Freelancer, looks like a low-poly retro PC game, and can eventually generate an effectively endless deterministic galaxy.

Prioritize:

1. fun arcade flight
2. good combat
3. satisfying docking
4. fast system travel
5. procedural exploration
6. understandable missions and factions
7. deterministic procedural generation
8. simple scalable architecture

Avoid premature scope.

The galaxy can come later.

First make one star system worth flying around in.
