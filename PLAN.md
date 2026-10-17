# TinyJam — PLAN (source of truth)

_Last updated: 2026-10-17 · Godot 4.7.1 · released as **v1.0.0**_

## 1. What this project is

**Tiny Moves** (Godot project `tinyjam`) is a short 3D game-jam entry. The jam
theme was **TINY**, interpreted as *tiny movements*: you balance a ball on a
tightrope, making small steering adjustments while the wind tries to roll you
off. The further you travel before falling, the higher your score.

It is packaged as a Windows downloadable and published to itch.io as **v1.0.0**.
The `v1.0.0` tag marks the shipped tree.

Read this file before doing any work. Update it whenever state changes.

## 2. Current state

### Engine / project config
- Engine: `4.7.1-stable` (`Godot_v4.7.1-stable_linux.x86_64`, not on `PATH`).
- Entry scene: `run/main_scene="res://scenes/Main.tscn"` (`project.godot:18`).
- Renderer: **Forward Plus** (`project.godot:19`). Desktop only — the web
  build will need `gl_compatibility` (see §5.1).
- Display: fixed `1920×1080`, `resizable=false` (`project.godot:31-33`).
- Autoloads (`project.godot:24-27`): `GameState`, `AudioPlayer`, `ButtonSfx`,
  `PauseSfx`.
- Global UI theme: `res://Bubble_Theme.tres` (`project.godot:37`).
- Pixel-snapped 2D and 3D rendering (`project.godot:101-106`).
- The player body sits on collision layer 2, named `Player`
  (`project.godot:97`).

### What the game does
- **Main menu** — Play / Controls / Quit, keyboard + gamepad focus
  (`scenes/Main.tscn:440-521`, `scenes/hud.gd:3-18,37-41`). The Controls page
  shows movement and pause keys drawn from `assets/input-kit` tiles.
- **Pixel-art presentation** — the whole 3D world renders into a `320×180`
  `SubViewport` scaled `×6` (`scenes/Main.tscn:320-334`).
- **Start** — the tree starts paused; entering `GameStartTrigger` begins the run
  (`scenes/game.gd:5-7`, `scenes/Game.tscn:530-540`).
- **Movement** — WASD / arrow keys / gamepad apply torque to the ball, clamped
  to a max angular speed (`actors/player.gd:23-39`).
- **Score** — distance from the start trigger, floored ×10
  (`actors/player.gd:18-20`), clamped and drawn by `scenes/label.gd:5-6`.
- **Tightrope** — entering the next segment's trigger instantiates a new rope
  (`actors/tightrope.gd:11-19`); a timer drops fading cloud obstacles that drift
  across the rope (`actors/tightrope.gd:24-33`, `actors/cloud.tscn`).
- **Pause** — the `Pause` action (Esc/P) pauses; any input resumes
  (`scenes/hud.gd:20-34`).
- **Game over** — falling past the killzone shows the score and a "Main Menu"
  button (`scenes/killzone.gd:7-11`, `scenes/game_over.gd:7-8`); accept/cancel/
  menu reloads to the menu (`scenes/game_over.gd:11-21`).
- **State machine** — `MAIN_MENU / IN_GAME / PAUSED / GAME_OVER`
  (`globals/game_state.gd:5`).

### Audio
- BGM `assets/sounds/BGM.mp3` on the `BGM` bus, `autoplay=true`
  (`globals/AudioPlayer.tscn:3,8`).
- UI click `assets/sounds/interface/click_003.ogg` (`globals/ButtonSFX.tscn:3`).
- Pause tone `assets/sounds/interface/drop_003.ogg` (`globals/PauseSFX.tscn:3`).
- Bus layout in `default_bus_layout.tres`.

### Art / shaders
- Seven asset packs under `assets/`: `fonts`, `input-kit`, `mini-characters`,
  `platformer-kit`, `shaders`, `sounds`, `ui-kit`. **All seven are in use.**
- `assets/shaders/pixelart_stylizer.gdshader` — screen-space pixel outline
  post-process, applied on the player camera (`actors/player.tscn`).
- `assets/shaders/Tree_wind.gdshader` — vertex-level wind sway on the trees
  (`scenes/Game.tscn`, meshes `actors/ShaderTree.tres` / `ShaderTreeSmall.tres`).
- `assets/fonts/Baberry.otf` plus `assets/ui-kit/*` textures drive the
  `Bubble_Theme.tres` menu skin.

### Build & run
- Run in editor: `~/.local/exe/Godot_v4.7.1-stable_linux.x86_64 --path . --editor`
- Run headless (smoke test): `... --headless --path . --quit-after 180`
- Export: Project → Export → "Windows Desktop".

### Repo / git
- Single commit `initial commit`; `main`, `dev`, and `origin/main` all point at
  it. `dev` is the working branch.
- **`v1.0.0`** is an **annotated, signed** tag on that commit
  ("Release version for game jam").
- 1387 tracked files. Not tracked (see §5.3): `export_presets.cfg`, every
  `*.import`, `PLAN.md`, `AGENTS.md`, and the `bin/` export output.

## 3. Goal / direction

**v1.0.0 is the shipped baseline.** Next work is a short polish sprint followed
by a web release:

1. **Minor bugfix pass** on the released desktop build (§5 items).
2. **Web (HTML5) export for itch.io embedding** — see §5.1.

Out of scope: mobile, new levels/art, engine upgrades.

## 4. Work completed

- 2025-03-24: **v1.0.0** released. Tagged `v1.0.0` ("Release version for game
  jam") and published to itch.io as a Windows downloadable.
- 2026-10-17: docs (`PLAN.md`, `AGENTS.md`) refreshed against the v1.0.0 tree.

## 5. Known issues / technical debt

1. **Web-incompatible renderer.** The project is Forward Plus
   (`project.godot:19`); itch.io HTML5 needs `gl_compatibility`. The pixel-post
   shader samples depth/screen/normal textures — confirm each works in the
   Compatibility renderer before relying on the current look.
2. **Only a Windows export preset** (`export_presets.cfg:1-4`). The shipped
   macOS build is not reproducible from the repo.
3. **Not reproducible from a clean clone.** `export_presets.cfg`
   (`.gitignore:18`) and all `*.import` (`:11`) are git-ignored, so a fresh clone
   has no export presets and must re-import every asset.
4. **Fixed, non-resizable window** (`project.godot:33`) blocks responsive web
   embedding; needs `resizable=true` with a sane stretch mode.
5. **BGM autoplays on load** (`globals/AudioPlayer.tscn:8`). Browsers block
   autoplay until a user gesture, so web needs an interaction-gated start.
6. **Minor dead code.** The player `Timer` → `_on_timer_timeout` only sets
   `constant_torque` drift (`actors/player.gd:42-43`); `killzone.gd:5`
   `allowContinue` is never read; the `@tool` `camera.gd:12` prints on every
   property set.

## 6. Validation log

Current tree, Godot `4.7.1.stable.official.a13da4feb`:

- 2026-10-17 `--version` → `4.7.1.stable.official.a13da4feb`.
- 2026-10-17 `--headless --path . --import` → **EXIT 0**, no errors.
- 2026-10-17 `--headless --path . --quit-after 180` → **EXIT 0**; only benign
  `2 ObjectDB instances were leaked at exit` and
  `1 resources still in use at exit`.
- Web checks (gl_compatibility run, HTML5 export, iframe embed): **not yet
  performed.**

## 7. Immediate actions

- _tbd_
