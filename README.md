# FreeStar

First-person retro arcade space sandbox. Current milestone: **0.1 — Flight Playground**.

## Run

Open `project.godot` in **Godot 4.7.x** and press F6 on the playground or F5 to run the project. From this directory:

```sh
godot --path .
```

The ship starts stationary facing a handcrafted test range. Orange and teal pylons show nearby motion; a station silhouette and distant planet help orientation. Local structures are solid but cause no damage.

## Controls

| Input | Action |
|---|---|
| Mouse | Offset steering reticle; farther from center turns faster |
| W / S | Raise / lower persistent throttle |
| Q / E | Roll left / right |
| Space | Set throttle to zero and decelerate |
| C | Center steering |
| R | Reset ship and controls to the safe spawn |
| Esc | Pause and release mouse |
| Left click while paused | Resume with centered steering |

Losing focus pauses flight. Throttle remains set during collisions; speed displays actual movement. The world and HUD render at 854×480 with nearest-neighbor scaling and black bars. Integer enlargement is used when it fits; smaller windows scale proportionally.

Tune flight and steering in `PlayerShip`'s inspector; camera FOV is on its Camera3D. The HUD reads telemetry, and the root presentation routes window input into the internal viewport.

## Validation

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --quit-after 120
godot --headless --path . --script tests/flight_test.gd
# Requires a graphics display; captures default, resized and paused views in /tmp.
godot --path . --script tests/presentation_test.gd
```

For hands-on testing, fly through the pylons, approach structures head-on and at an angle, try full-speed contact, reset, switch focus, and resize the window. Judge steering comfort, landmark visibility, and HUD readability interactively.

Project design and milestone scope live in [AGENTS.md](AGENTS.md).
