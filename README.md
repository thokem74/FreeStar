# FreeStar

First-person retro arcade space sandbox. Current milestone: **0.1 — Flight Playground**.

## Run

Open `project.godot` in **Godot 4.7.x** and press F6 on the playground or F5 to run the project. From this directory:

```sh
godot --path .
```

The ship starts stationary facing a handcrafted test range. A belt of 220 colorful, rotated blocks provides nearby motion cues; a warm star and distant planet help orientation. Local structures are solid but cause no damage.

## Controls

| Input | Action |
|---|---|
| Mouse | Offset reticle requests smooth pitch/yaw |
| A / D | Roll left / right |
| Hold right mouse | Horizontal reticle offset rolls instead of yawing; vertical motion still pitches |
| W | Accelerate toward 600 m/s |
| S | Brake, stop, then reverse while held |
| Left Shift | Boost toward 1,200 m/s while held |
| C | Center steering |
| Home | Reset to stationary spawn |
| Esc | Pause and release mouse |
| Left click while paused | Resume with centered steering |

Start stationary; W or Shift starts forward flight. Releasing forward acceleration returns smoothly to 150 m/s cruise. Hold S to brake to zero, then reverse up to 150 m/s. Releasing S completes a stop and never resumes cruise. After releasing S, W or Shift cancels stopping and drives forward; direction changes pass through zero before accelerating the other way.

S overrides W and Shift while held. Shift takes priority over W. Releasing Shift while holding W returns toward normal maximum speed; releasing both returns to cruise. Boost has no energy limit and is local arcade acceleration, not supercruise. Q/E, R/F, and Space have no flight bindings.

Right mouse is a held roll modifier. Entering/leaving it clears horizontal steering and residual yaw/roll, while retaining pitch. A/D and mouse roll combine within the normal roll-rate cap.

Losing focus pauses flight. Resuming preserves cruise/stopped state and centers steering. The HUD shows actual movement speed and STOPPED, CRUISE, ACCELERATING, BRAKING, BOOST, or REVERSING. Collisions block or slide without damage and do not store forward acceleration against obstacles.

The world and HUD render at 854×480 with nearest-neighbor scaling and black bars. Integer enlargement is used when it fits; smaller windows scale proportionally.

Initial tuning is 200 m/s² normal acceleration, 400 m/s² boost acceleration, 300 m/s² automatic deceleration, and 600 m/s² braking/direction changes. Reverse acceleration is 200 m/s².

Tune flight and steering in `PlayerShip`'s inspector; camera FOV is on its Camera3D. The HUD reads telemetry, and the root presentation routes window input into the internal viewport.

## Validation

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --quit-after 120
godot --headless --path . --script tests/flight_test.gd
# Requires a graphics display; captures default, resized and paused views in /tmp.
godot --path . --script tests/presentation_test.gd
```

For hands-on testing, fly between the belt blocks, approach structures head-on and at an angle, try full-speed contact, reset, switch focus, and resize the window. Judge steering comfort, landmark visibility, and HUD readability interactively.

Project design and milestone scope live in [AGENTS.md](AGENTS.md).

The block belt is a fixed, editor-editable scene with shared meshes/materials and matching solid box colliders. Its varied spacing leaves a clear initial approach. It does not generate or animate obstacles at runtime.
