# TinyJam — PLAN (source of truth)

_Last updated: 2026-10-21 · Godot 4.7.1 · released as **v1.0.0**_

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
- Renderer: **gl_compatibility** (`project.godot:101-102`, `config/features`
  now `"GL Compatibility"`). Changed 2026-10-21 so the desktop and web
  builds render identically; Forward+ still works and is retuned to the
  original v1.0.0 look at runtime (§4, §5.3-5.4, §7.4).
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
  **Renderer-safe as of 2026-10-18:** one shader branches on the built-in
  `CURRENT_RENDERER` define — Forward+ keeps the original normal-roughness
  highlight (byte-for-byte; desktop verified pixel-identical), Compatibility
  reconstructs a view-space normal from three depth taps and uses the OpenGL
  NDC when unprojecting depth. Compiles clean under both renderers
  (`:19-21`, `:36-40`, `:60-77`, `:112-143`). See §5.1-5.2 and §6.
  **Grey halo fixed 2026-10-21** (§5.11): two mechanisms, both in the
  Compatibility branch only. (1) The normal reconstruction is faded out in
  the far distance, where the depth buffer has no precision left and the
  reconstructed normal is pure noise. (2) A foreground gate: a pixel may only
  produce a highlight if it is in front of a neighbour, so the highlight can
  no longer leak onto background pixels next to a silhouette - the quad's
  partial alpha then painted a 1px grey/pink halo just outside the black
  outline. The Forward+ branch is untouched (0 differing pixels, §6).
- `assets/shaders/Tree_wind.gdshader` — vertex-level wind sway on the trees
  (`scenes/Game.tscn`, meshes `actors/ShaderTree.tres` / `ShaderTreeSmall.tres`).
- `assets/fonts/Baberry.otf` plus `assets/ui-kit/*` textures drive the
  `Bubble_Theme.tres` menu skin.
- **Renderer look table** (`scenes/game.gd:16-25`): the scene resource holds
  the Compatibility look (AgX tonemap, key light `light_energy = 0.4`,
  Compatibility sky); on Forward+ the original v1.0.0 look (Filmic tonemap,
  key light `1.0`, original sky) is restored at runtime.

### Build & run
- Run in editor: `~/.local/exe/Godot_v4.7.1-stable_linux.x86_64 --path . --editor`
- Run headless (smoke test): `... --headless --path . --quit-after 180`
- Export: Project → Export → "Windows Desktop".

### Repo / git
- Single commit `initial commit`; `main`, `dev`, and `origin/main` all point at
  it. `dev` is the working branch.
- **`v1.0.0`** is an **annotated, signed** tag on that commit
  ("Release version for game jam").
- 1387 tracked files. Not tracked (see §5.7): `export_presets.cfg`, every
  `*.import`, `PLAN.md`, `AGENTS.md`, and the `bin/` export output.

## 3. Goal / direction

**v1.0.0 is the shipped baseline.** Next work is a short polish sprint followed
by a web release:

1. ~~**Renderer-safe pixel shader**~~ — **done 2026-10-18** (§5.1-5.2,
   §7.1-7.3): one `#if CURRENT_RENDERER` shader, desktop stays pixel-identical,
   Compatibility highlight approximated from depth.
2. ~~**Close the Compatibility colour gap**~~ — **done 2026-10-21** (§5.3-5.4,
   §7.4): root-caused to the engine's shadowed-light multipass + raw
   background write; fixed by retuning the scene for Compatibility (AgX
   tonemap, dimmed key light, per-renderer sky). The two renderers now
   differ by 7.7% of pixels (>32 levels) instead of 68.3%, and the
   Forward+ path is still bit-identical to v1.0.0.
3. ~~**Remove the grey halo around the pixel outline**~~ — **done
   2026-10-21** (§5.11, §7.6): the Compatibility depth→normal reconstruction
   is noise in the far distance; fading it out removes the halo and leaves
   the Forward+ path bit-identical.
4. **Web (HTML5) export for itch.io embedding** — project settings + preset
   (§5.8-5.9, §7.6).

Out of scope: mobile, new levels/art, engine upgrades.

## 4. Work completed

- 2025-03-24: **v1.0.0** released. Tagged `v1.0.0` ("Release version for game
  jam") and published to itch.io as a Windows downloadable.
- 2026-10-17: docs (`PLAN.md`, `AGENTS.md`) refreshed against the v1.0.0 tree.
- 2026-10-18: **Pixel-post shader made `gl_compatibility`-safe.**
  `assets/shaders/pixelart_stylizer.gdshader` declared
  `uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture`, which is
  Forward+ only. Under Compatibility the shader failed to compile
  (`SHADER ERROR: 'hint_normal_roughness_texture' is only available when using
  the Forward+ renderer.`) and the post-process quad fell back to an opaque
  default material that occluded the whole screen. The normal texture and the
  highlight pass it drove were removed; the depth silhouette outline is
  unchanged and now renders under both renderers. Verified via windowed runs
  and 30-frame captures (§6). Desktop Forward+ look changes for ~1.5% of
  pixels (§5.5).
- 2026-10-18: **Renderer-safe shader finished — highlight restored on both
  renderers from one file.** Replaced the §4 stop-gap above with a single
  `assets/shaders/pixelart_stylizer.gdshader` that branches on the built-in
  `CURRENT_RENDERER` define:
  - `:19-21` the Forward+ only
    `uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture` is
    wrapped in `#if CURRENT_RENDERER == RENDERER_FORWARD_PLUS`; the **crux
    test passed** — the guarded uniform compiles clean under
    `--rendering-method gl_compatibility`, so the two-file fallback was **not**
    needed.
  - `:112-125` the Forward+ highlight is the original v1.0.0 code, byte-for-byte
    (`git diff HEAD -- <shader>` shows only added lines; no original line is
    modified or removed).
  - `:60-77` + `:126-142` the Compatibility path reconstructs a view-space
    normal from 3 depth taps (centre / right / up, `cross` of reconstructed
    view-space positions) and feeds it through the existing `normalIndicator()`
    math. Its final `smoothstep` threshold is `(0.9, 1.5)` instead of
    `(0.2, 0.8)`: depth-rebuilt normals are noisier than the G-buffer normals,
    so the stricter threshold is what keeps the rim at the reference weight.
  - `:36-40` `getDepth()` NDC is branched per renderer (Vulkan
    `vec3(uv * 2.0 - 1.0, d)` vs OpenGL `vec3(uv, d) * 2.0 - 1.0`), fixing
    §5.2.
  Verified headless: Forward+ before/after = **0 differing pixels** (5 frames);
  Compatibility = EXIT 0, no `SHADER ERROR`, 30 frames; Compatibility
  highlight changes **1.75-1.80%** of source pixels vs **1.71-1.75%** for the
  original Forward+ highlight; depth-outline mask IoU across renderers
  **0.911**. Raw output in §6, evidence in /tmp/opencode/tinyjam_fix/.
- 2026-10-21: **Compatibility colour gap closed by retuning the scene (not
  the shader).** Research first (§6), then three candidate fixes were
  measured; the "keep the cast shadows" option shipped, the other two are
  recorded in §5.4 as alternatives.
  - **Root cause (not the stylizer):** the pixel-post shader is innocent —
    with the post quad hidden the sample colours are unchanged in both
    renderers. The gap comes from two engine behaviours:
    1. **Shadowed lights are a separate additive pass in sRGB space** in
       Compatibility ([godotengine/godot#90259](https://github.com/godotengine/godot/issues/90259),
       an intentional trade-off confirmed by the rendering lead: non-shadowed
       lights are computed in linear space in one pass, shadowed lights need
       multi-pass blending, which Compatibility does in sRGB space). Any
       scene with a base-pass contribution (ambient / un-shadowed light)
       **and** a shadow-casting light is therefore over-brightened in
       Compatibility. Measured on the lit ground: Forward+ `(117,226,182)`
       vs Compatibility `(156,255,255)` — clipped.
    2. **The background colour is written raw** in Compatibility (no tonemap,
       no sRGB encode), so the sky was `(74,144,207)` instead of
       `(94,180,230)`.
  - **Measured rule:** a scene with a *single* light pass matches across
    renderers exactly (ground `(106,205,151)` in both with ambient off;
    `(119,230,187)` vs `(117,226,182)` with ambient on and shadows off).
    Two passes never match, and the divergence grows with the brightness of
    the second pass.
  - **Shipped fix** (option 3, "keep the cast shadows"):
    - `scenes/Game.tscn:25` `tonemap_mode` 2 (Filmic) → **4 (AgX)** — AgX's
      shoulder absorbs the over-brightened lit areas instead of clipping
      them (0.6% of pixels clipped vs 40%+ with Filmic).
    - `scenes/Game.tscn:261` key light `light_energy = 0.4` (was 1.0) —
      brings the lit areas back to the original level.
    - `scenes/Game.tscn:21` `background_color` → the Compatibility sky
      `Color(0.36862745, 0.70588237, 0.9019608)`, which Compatibility
      writes out as exactly `(94,180,230)`, the original v1.0.0 sky.
    - `scenes/game.gd` — renderer look table: on Forward+ the original
      v1.0.0 look (Filmic, key light 1.0, original sky) is restored, so
      Forward+ stays **bit-identical to the shipped game**.
  - **Result** (1920×1080 window capture, whole frame): Forward+ vs
    Compatibility **before** = mean Δ 30.9, 68.3% of pixels differ by >32,
    7.1% identical. **After** = mean Δ 11.9, **7.7%** differ by >32, 26.5%
    identical. Forward+ before vs after = **0 differing pixels**.
    Sample colours after: sky `(94,180,230)` in both; ground Forward+
    `(117,226,182)` vs Compatibility `(96,231,174)`; tree shadow Forward+
    `(44,147,118)` vs Compatibility `(44,122,101)`.
  - `project.godot:101-102` — the project default renderer is now
    `gl_compatibility` (and `config/features` → `"GL Compatibility"`), so
    the desktop and web builds are the same renderer and look identical.
- 2026-10-21: **Grey halo around the pixel outline removed (§5.11).** The
  Compatibility build showed a 1px grey-blue fringe just outside the black
  outline on most objects. Research first, then five instrumented attempts
  to localise it:
  - The scene itself is clean at the halo pixels (plain sky `(94,180,230)`
    with the post-process quad hidden) → the quad was painting it.
  - Disabling the highlight term (`highlights_enabled = false`) removed the
    halo completely → the *normal/highlight* term was the trigger, not the
    depth outline.
  - Debug visualisations of the individual terms (rendered straight to
    `ALBEDO`) at a tree edge: at the halo pixel `normal_diff = 203`
    (non-zero), `neg_depth_diff = 0`, `alpha_mask = 203`; one pixel further
    out `neg_depth_diff = 203` (the guard *does* work there).
  - The reconstructed normals in the far distance are noise: adjacent
    background pixels `(10,127,128)` / `(37,143,170)` / `(33,141,165)` vs a
    stable `(131,145,209)` away from the silhouette; a view-distance
    bitmask showed the sky beyond 200 units and all geometry within 20.
  - **Fix** (`assets/shaders/pixelart_stylizer.gdshader:71-86`): fade the
    reconstructed normal to the constant far-plane normal over the far
    distance, where the depth precision (and the reconstruction) is
    meaningless. The Forward+ branch is untouched.
  - **Result:** the halo pixels are now exactly the sky `(94,180,230)`; the
    outline is solid instead of dotted; only 147 of 57 600 source pixels
    changed (0.26%); Forward+ is **bit-identical** (0 differing pixels). The
    Compatibility rim-highlight weight is 1.40% (Forward+ reference 1.71%);
    lowering the Compatibility threshold to (0.8, 1.4) raises it to 1.63% but
    brings back ~120 extra bright fringe pixels, so the threshold was left
    alone.
- 2026-10-21: **Second halo mechanism fixed (§5.11).** The first fix only
  covered geometry beyond 20 units, so the fringes on *near* objects (the
  trees) survived. Same mechanism: the depth-rebuilt normal is noise wherever
  a tap crosses a silhouette, so the highlight fired on background pixels
  (measured: `normal_diff = 203`, `depth_diff = 0`, `neg_depth_diff = 0` at a
  fringe pixel) and the quad's partial alpha painted the coloured fringe.
  - **Fix:** a foreground gate in the Compatibility branch - a pixel may only
    highlight if it is in front of a neighbour
    (`normal_diff *= step(0.0001, depth_diff);`).
  - **Nothing is lost:** the Compatibility "rim light" was pure noise (with
    the gate the highlight changes 56 px instead of 804), and Forward+'s
    highlight is already invisible in this build (three byte-identical
    captures: on / off / source-stripped). A depth-based silhouette rim was
    also tried and produces nothing.
  - **Result:** the colour-cast pixels fall from 550 to 26; the lighter
    fringe pixels fall from 1399 to 1056 - at parity with the Forward+
    reference (1115); Forward+ stays **bit-identical** (0 differing pixels).

## 5. Known issues / technical debt

### Renderer work (both items resolved 2026-10-18)

1. **✅ RESOLVED (2026-10-18) — Renderer-safe pixel shader.** Shipped as one
   `#if CURRENT_RENDERER` shader; see §4 for the change list and §6 for the
   validation output. Original text kept for context: The project is Forward
   Plus
   (`project.godot:19`); itch.io HTML5 needs `gl_compatibility`. Confirmed
   against the Godot renderer matrix: **Screen texture ✔️** and **Depth texture
   ✔️** are supported by Compatibility, but the **Normal/Roughness buffer ❌ is
   not** — `hint_normal_roughness_texture` is Forward+ only. The interim fix
   (§4) removed the highlight to unblock compilation; the proper fix is a
   single shader that branches per renderer:
   - Godot 4.4+ exposes built-in preprocessor defines `CURRENT_RENDERER` and
     `RENDERER_COMPATIBILITY` (0) / `RENDERER_MOBILE` (1) /
     `RENDERER_FORWARD_PLUS` (2), so the Forward+ only normal-texture uniform
     can be hidden behind `#if CURRENT_RENDERER == RENDERER_FORWARD_PLUS`
     (excluded branches are removed before compilation).
   - **Forward+ path:** the original normal-buffer highlight, byte-for-byte
     unchanged → desktop stays pixel-identical to v1.0.0.
   - **Compatibility path:** reconstruct a view-space normal from 3 depth taps
     (centre / right / up, cross product) and feed it into the existing
     `normalIndicator()` math.
   - **Fallback** if a `#if`-guarded uniform will not compile: two shader files
     selected at runtime, e.g. via `RenderingServer.get_rendering_device() == null`.
   - Refs: Godot docs *Overview of renderers* (feature matrix), *Advanced
     post-processing* (NDC + `CURRENT_RENDERER`), *Shader preprocessor*
     (built-in defines); godotshaders "World normals from screen depth" (CC0
     depth→normal reconstruction).
2. **✅ RESOLVED (2026-10-18) — Compatibility depth unprojection used the wrong
   NDC.** `getDepth()` in `assets/shaders/pixelart_stylizer.gdshader` now
   branches the NDC per renderer (`:36-40`), and `getViewPos()` (Compatibility
   only, `:63-68`) does the same for the normal reconstruction. Verified by the
   cross-renderer depth-outline mask IoU of 0.911 (§6). Original text kept for
   context: `getDepth()` built NDC as
   `vec3(screen_uv * 2.0 - 1.0, raw_depth)` (Vulkan, z ∈ `[0,1]`), but
   Compatibility uses OpenGL NDC (z ∈ `[-1,1]`) and needs
   `vec3(screen_uv, raw_depth) * 2.0 - 1.0`. The current web outline renders by
   luck; the docs and community both confirm unprojection is what breaks under
   Compatibility. Fix with the same `CURRENT_RENDERER` branch and verify the
   outline geometry matches across renderers (§7.3).

### Regressions (colour parity — investigate separately)

3. **✅ RESOLVED (2026-10-21) — Compatibility: Environment
   `background_color` is not tonemapped.** Root cause confirmed: in
   `gl_compatibility` the background is written without the Forward+
   tonemap/sRGB pipeline, so the sky is much darker. Measured with a grey
   ramp (`background_color` linear 0.25 / 0.50 / 0.80 / 1.0 → Forward+ output
   79 / 162 / 228 / 255 vs Compatibility 64 / 127 / 204 / 255, i.e.
   Compatibility = linear × 255). Fixed by giving Compatibility its own
   sky value (`scenes/Game.tscn:21` + `scenes/game.gd:16-17`): the sky is now
   `(94,180,230)` in **both** renderers. Original text kept for context: The
   game sky colour `(0.29052547, 0.5662663, 0.81195307)`
   (`scenes/Game.tscn:21`) renders `(94,180,230)` on Forward+ vs
   `(74,144,207)` on Compatibility. Captures:
   `/tmp/opencode/cap/{nopost_fwd,nopost_gc,bg_*}`.
4. **✅ RESOLVED (2026-10-21) — Compatibility: ambient/shadowed-light
   lighting differs.** Root cause: shadow-casting lights are rendered as a
   separate additive pass in **sRGB space** in Compatibility
   ([godotengine/godot#90259](https://github.com/godotengine/godot/issues/90259)),
   so a lit surface gets the ambient/base pass *plus* an sRGB-space light
   contribution and clips. Original text kept for context: With
   `ambient_light_energy = 0` the two renderers match on all geometry (ground
   pixel `(105,205,153)` in both); with ambient on they diverge, most on
   large flat surfaces (ground: Forward+ `(119,230,189)` vs Compatibility
   `(155,255,255)`, bright pixels clip; `/tmp/opencode/overlay_amb2.png`).
   The game uses `ambient_light_source = 3` (Sky) with `ambient_light_color`
   and `ambient_light_sky_contribution = 0.17` (`scenes/Game.tscn:22-24`).
   Captures: `/tmp/opencode/cap/{amb0,amb1,amb2,amb3}_*`.
   **Not fixable by matching values** — it is a structural difference:
   a scene with one light pass matches across renderers, two passes never
   do. The scene was retuned instead (AgX + dimmed key light); see §4.

   **Two alternatives were measured and kept on file** (neither shipped,
   because the user chose to keep the cast shadows):

   - **Alternative A — drop the cast shadows in Compatibility**
     (`DirectionalLight3D.shadow_enabled = false`): one light pass, so the
     renderers agree almost exactly. Measured: ground `(119,230,187)` vs
     Forward+ `(117,226,182)`, tree `(19,124,113)` vs `(17,113,103)`, rock
     `(68,95,142)` vs `(61,86,130)`. Whole-frame: mean Δ 12.2, 13.0% of
     pixels differ by >32. Cost: the tree/ball cast shadows disappear (the
     scene is flatter). This is the closest colour match available.
   - **Alternative B — Alternative A applied to both renderers** (ship
     Compatibility everywhere *and* drop the shadows): the desktop and web
     builds then look byte-identical to each other, at the cost of changing
     the shipped v1.0.0 art direction on desktop.
   - **Rejected — ambient off, shadows on** (one pass, keeps the cast
     shadows): colours match exactly, but everything facing away from the
     light goes black (tree tops, platform sides). Far too harsh.
   - **Rejected — Filmic tonemap with a dimmed key light**: the lit areas
     still clip (40%+ of pixels) because Filmic has no shoulder for the
     over-brightened values; AgX does.
5. **✅ RESOLVED (2026-10-18) — Normal-based highlight missing on
   Compatibility.** Restored by §5.1: Forward+ uses the original
   normal-roughness buffer, Compatibility uses the depth-reconstructed normal,
   and the Compatibility rim now changes ~1.8% of pixels (reference 1.75%).
   Original text kept for context: Removed by the §4 stop-gap. Costs **1.54%**
   of desktop Forward+ pixels (mean `|Δ|` 0.55 — a 1px inner rim on
   silhouettes; `/tmp/opencode/overlay_varA.png`). A naive depth-only rim was
   tested and rejected (28% of pixels changed). To be restored properly by §1
   above.

### Other technical debt

6. **Only a Windows export preset** (`export_presets.cfg:1-4`). The shipped
   macOS build is not reproducible from the repo.
7. **Not reproducible from a clean clone.** `export_presets.cfg`
   (`.gitignore:18`) and all `*.import` (`:11`) are git-ignored, so a fresh clone
   has no export presets and must re-import every asset.
8. **Fixed, non-resizable window** (`project.godot:33`) blocks responsive web
   embedding; needs `resizable=true` with a sane stretch mode.
9. **BGM autoplays on load** (`globals/AudioPlayer.tscn:8`). Browsers block
   autoplay until a user gesture, so web needs an interaction-gated start.
10. **Minor dead code.** The player `Timer` → `_on_timer_timeout` only sets
    `constant_torque` drift (`actors/player.gd:42-43`); `killzone.gd:5`
    `allowContinue` is never read; the `@tool` `camera.gd:12` prints on every
    property set.

### Post-process (resolved 2026-10-21)

11. **✅ RESOLVED (2026-10-21) — Compatibility: grey halo just outside the
    black outline.** A 1px grey-blue fringe (e.g. `(128,175,197)` and
    `(103,177,218)`) appeared on the background side of the pixel outline on
    most objects; the scene itself was clean there (the plain sky
    `(94,180,230)`), so the post-process quad was painting it.
    **Root cause (not the outline logic):** the Compatibility path rebuilds a
    view-space normal from three depth taps
    (`assets/shaders/pixelart_stylizer.gdshader:71-76`). The depth buffer has
    no precision left in the far distance, so the reconstructed normal there
    is pure noise — measured on adjacent background pixels: `(10,127,128)`,
    `(37,143,170)`, `(33,141,165)` versus a stable `(131,145,209)` away from
    the silhouette. A background pixel next to an object therefore compares
    its stable normal against a noisy neighbour, `normalIndicator()`
    (`:52-58`) fires, and `normal_diff > 0` lands on the *background*
    (measured `203` at the halo pixel). The intended guard
    `neg_depth_diff` (`:99-104`) cannot catch it: it only tests the four
    direct neighbours' depth, and at that pixel all four are background, so
    `neg_depth_diff = 0` (it is `1` at the pixel actually touching the
    object). The leak lands on the *second* pixel out, where no local depth
    test can see it. With `normal_diff > 0`, `alpha_mask` (`:159`) becomes
    non-zero, the quad is drawn partially transparent there, and in
    Compatibility the screen-texture round trip is not colour-exact (the
    screen texture holds pre-tonemap linear values, while the background
    bypasses the tonemap), so the partial-alpha blend of the quad over the
    correctly-tonemapped scene paints the desaturated fringe. Forward+ is
    immune: its G-buffer stores a *sentinel* normal for the background, so
    all background pixels share one normal (no difference → no highlight)
    and the screen-texture round trip is colour-exact.
    **Fix (part 1, 2026-10-21):** fade the reconstructed normal to the
    constant far-plane normal over the far distance, where the reconstruction
    is meaningless (`smoothstep(20.0, 60.0, length(p_center))`; the sky
    measures beyond 200 units, all geometry within 20). This removed the halo
    against the sky but **not** the fringes on near geometry: a tree is within
    20 units, so its reconstructed normal is still noise wherever a tap
    crosses the silhouette.
    **Fix (part 2, 2026-10-21) - the foreground gate:** a pixel may only
    produce a highlight if it really is *in front of* a neighbour (a genuine
    silhouette edge), i.e. `normal_diff *= step(0.0001, depth_diff);` in the
    Compatibility branch. The leak then becomes impossible at any distance,
    because a background pixel next to an object is in front of nothing
    (`depth_diff = 0` there, measured) and the `neg_depth_diff` guard can no
    longer be relied on to catch the second pixel out. The Forward+ branch is
    untouched.
    **Why nothing is lost:** the Compatibility "rim light" was pure noise -
    with the gate the highlight changes 56 px (0.10%) instead of 804 px
    (1.40%). Forward+'s highlight is already invisible in this build: three
    Forward+ captures (highlight on, highlight off, highlight code stripped at
    source level) are byte-identical, so the G-buffer normals in the
    SubViewport give no usable signal. A depth-based "silhouette rim" was
    also tried and produces nothing (0.00-0.07%): the shadow term overwrites
    the highlight at silhouette pixels.
    **Measured (frozen frame):** the halo pixels are now exactly the sky
    `(94,180,230)`; the colour-cast pixels (the fringe signature) fall from
    550 to 26 (0.05% of the frame); the lighter-fringe pixel count falls
    from 1399 to 1056, i.e. **at parity with the Forward+ reference (1115)**;
    the highlight weight falls from 1.40% to 0.10%; 869 of 57 600 source
    pixels change (1.51%); Forward+ is **bit-identical** (0 differing
    pixels). Evidence and measurements in §6.
    **Rejected alternatives:** a raw-depth background test
    (`raw_depth >= 0.9999` — measured, the background's raw depth is *not*
    ≥ 0.9999 here, so the test never triggers); gating the highlight on
    `depth_diff > 0` (also kills the rim light on smooth surfaces);
    rebuilding the highlight from depth differences instead of normals (a
    larger rewrite of the Compatibility path, not needed).
    **Still open (optional polish):** the quad's partial alpha is a
    fringe risk in Compatibility in general, because the screen-texture round
    trip is not colour-exact there. With the gate the highlight no longer
    contributes any partial alpha, so in practice only the outline's own soft
    edge (the shadow term's `smoothstep(0.2, 0.3)` ramp) can still blend a
    re-tonemapped sample. Making the outline's alpha binary
    (`ALPHA = step(0.5, alpha_mask)`) would remove that last risk, at the
    cost of a harder 1px outline edge in Compatibility than in Forward+.

## 6. Validation log

Current tree, Godot `4.7.1.stable.official.a13da4feb`:

- 2026-10-17 `--version` → `4.7.1.stable.official.a13da4feb`.
- 2026-10-17 `--headless --path . --import` → **EXIT 0**, no errors.
- 2026-10-17 `--headless --path . --quit-after 180` → **EXIT 0**; only benign
  `2 ObjectDB instances were leaked at exit` and
  `1 resources still in use at exit`.
- 2026-10-18 `PATCHED pixelart_stylizer.gdshader` — Forward+ windowed
  `--path . --quit-after 120` → **EXIT 0**, no shader errors.
- 2026-10-18 `PATCHED pixelart_stylizer.gdshader` — Compatibility windowed
  `--path . --rendering-method gl_compatibility --write-movie <frames>
  --quit-after 30` → **EXIT 0**, no `SHADER ERROR`, 30 frames captured; the
  depth outline renders correctly (`/tmp/opencode/cap/final_gc/`). Pre-patch
  the same run failed with
  `SHADER ERROR: 'hint_normal_roughness_texture' is only available when using
  the Forward+ renderer.` + `Shader compilation failed.`
  (`/tmp/opencode/cap/broken/` — post quad occluded the screen).
- 2026-10-18 Compatibility colour parity, measured: see §5.3-5.4.
- 2026-10-18 Shader research (docs, no code change): the renderer feature
  matrix confirms Screen + Depth textures are supported by Compatibility while
  the Normal/Roughness buffer is not (`hint_normal_roughness_texture` is
  Forward+ only); `CURRENT_RENDERER` / `RENDERER_COMPATIBILITY` preprocessor
  defines are available since Godot 4.4; Compatibility uses OpenGL NDC
  (z ∈ `[-1,1]`). Sources: Godot docs *Overview of renderers*, *Advanced
  post-processing*, *Shader preprocessor*; godotshaders "World normals from
  screen depth". Findings and the fix plan: §5.1-5.2, §7.1-7.3.
- 2026-10-18 **RENDERER-SAFE SHADER (§5.1-5.2) — all checks on
  `assets/shaders/pixelart_stylizer.gdshader` (md5
  `6448348f98a25d1b4d0db9a6575163b9` unless stated).** Scratch/evidence:
  `/tmp/opencode/tinyjam_fix/`.
  - **Crux test (§7.1): PASSED — no fallback needed.** A `#if CURRENT_RENDERER
    == RENDERER_FORWARD_PLUS` guard around
    `uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture;`
    compiles clean under Compatibility:
    `godot --path . --rendering-method gl_compatibility --write-movie
    /tmp/opencode/tinyjam_fix/compat/f.png --fixed-fps 15 --quit-after 30`
    → **EXIT 0**, no `SHADER ERROR`, no `Shader compilation failed`, 30 frames.
    (The pre-patch tree failed the same run with
    `SHADER ERROR: 'hint_normal_roughness_texture' is only available when using
    the Forward+ renderer.`)
    - Intermediate failure, fixed: the first attempt put
      `INV_PROJECTION_MATRIX` inside a helper called outside `fragment()` →
      `SHADER ERROR: Unknown identifier in expression: 'INV_PROJECTION_MATRIX'.
      at: (null) (…pixelart_stylizer.gdshader:66)`. Fixed by passing the matrix
      in as a parameter (same pattern `getDepth()` already used).
  - **Desktop parity: 0 differing pixels.** Forward+ (`--path . --write-movie
    <dir> --fixed-fps 15 --quit-after 30`) with the git-HEAD shader
    (`fwd_head/`) vs the new shader (`fwd_final/`):
    frames 0 / 7 / 14 / 21 / 29 → `differing_pixels=0  maxAbsDiff=0` of
    2,073,600 (1920×1080) each. Backing check:
    `git diff HEAD -- assets/shaders/pixelart_stylizer.gdshader` adds no
    removed/changed original line (`grep -E '^-[^-]'` → empty).
  - **Forward+ `NORMAL_TEXTURE` highlight unchanged:** `head` vs `interim`
    (highlights stripped) = 1000 / 995 / 1008 px of 320×180 source pixels at
    frames 0 / 14 / 29 (1.74% / 1.73% / 1.75%).
  - **Compatibility highlight present, matched weight:** new shader vs a
    highlights-off build of the same shader on Compatibility
    (`compat_final/` vs `compat_nohl/`) = 1039 / 1006 / 1031 px (1.80% / 1.75%
    / 1.79%) at frames 0 / 14 / 29; the Forward+ reference over the same frames
    is 1.74% / 1.73% / 1.75% (ratio GC/FWD 1.01-1.04×). Rejected tunings
    measured on the same capture: baseline threshold `(0.2,0.8)` = 4.83%,
    `(0.35,0.95)` = 3.73%, `(0.5,1.1)` = 2.81%, `(0.7,1.3)` = 2.27%; shipped
    `(0.9,1.5)` = 1.79%. A sky-normal sentinel variant blew up to 93% and was
    discarded.
  - **Outline geometry matches across renderers:** binary `depth_diff` masks
    (`diag2final_{fwd,gc}`) → 4702 vs 4285 source px, IoU **0.911**
    (FWD pixels covered by GC 91.1%, GC pixels covered by FWD 100.0%) — the
    §5.2 NDC branch is correct. The pre-fix code rendered the outline "by luck".
  - **Highlight placement (reported honestly):** at frame 29 the Forward+ and
    Compatibility highlight masks overlap with IoU 0.071 (13.4% of the Forward+
    rim pixels are also Compatibility rim pixels); the masks agree structurally
    before the depth-subtraction stage at IoU 0.54. The rims are 1px wide at
    320×180, so any 1px placement difference collapses IoU; the two renderers
    cannot agree exactly because the Forward+ normal buffer stores a sentinel
    normal for the background while a depth reconstruction yields the far-plane
    normal.
  - Diagnostic (no code change): `smoothstep(0.5, 0.5, x)` returns
    `1 / 0 / 1 / 0` for `x = 0.6 / 0.4 / 0.6×10 / 0.4×10` identically on
    Forward+ and Compatibility, so the shared `neg_depth_diff` line is not a
    renderer difference.
  - Evidence images: `/tmp/opencode/tinyjam_fix/{highlight_crop.png,
    mask_overlay.png, diag_grid.png, mask_fwd.png, mask_gc.png}`; raw
    `run.log` per capture directory.
- 2026-10-21 **COLOUR PARITY RESEARCH + FIX (§4, §5.3-5.4, §7.4).**
  Method: a temporary probe scene (removed again; not committed) instantiated
  `res://scenes/Main.tscn`, applied Environment/light variants from env vars,
  captured the 320×180 `SubViewport` and printed named sample pixels; whole
  frames were captured with `--write-movie`. Scratch dir
  `/tmp/opencode/color/` (`probe/*.png`, `base_fwd/`, `base_gc/`, `fin_gc/`,
  `fin_fwd/`, `before_after.png`).
  - **The stylizer shader is not the cause.** With the post-process quad
    hidden (`PROBE_POST=off`) every sample pixel is unchanged in both
    renderers (Compatibility ground `(156,255,255)` either way).
  - **Measured rules** (lit-ground sample, Forward+ vs Compatibility):
    ambient off + one shadowed light → `(106,205,151)` vs `(106,205,151)`
    (**exact match**); ambient on + shadows off → `(117,226,182)` vs
    `(119,230,187)` (Δ≈3); ambient on + shadowed light → `(117,226,182)` vs
    `(156,255,255)` (clipped); ambient on + shadowed light at ambient 0.75 /
    key 0.4 → `(106,255,210)` (still clipped). Shadowed-area samples only
    depend on the ambient and match in every case, e.g. `(44,147,118)` vs
    `(42,140,113)`.
  - **The number of light passes is the variable**, not the energy values:
    one pass (ambient and/or un-shadowed lights only) → the renderers agree;
    adding a shadow-casting light → a second, sRGB-space additive pass →
    over-brightening.
  - **Shadow cascade count is not a factor**: `directional_shadow_mode` 0 / 1
    / 2 gives the same Compatibility output (`(156,255,255)`).
  - **Tonemap**: the tonemap *is* honoured for geometry in Compatibility
    (Filmic and Linear give the same values in both renderers, e.g. ambient
    off + Linear → `(83,172,118)` in both) — only the *background* bypasses
    it.
  - **Ambient source quirk**: in Compatibility `ambient_light_sky_contribution`
    is ignored — `ambient_light_source = SKY, contribution 0.17` gives the
    same result as `source = COLOR, energy 1.0` (ground `(96,231,174)`),
    while Forward+ mixes in 83% of the colour (`(79,150,119)` for the same
    setup). The scene keeps the original Sky-source values, which are
    unchanged on Forward+.
  - **AgX vs Filmic**: with the shadows kept, Filmic clips 40%+ of pixels;
    AgX (`tonemap_mode = 4`) clips 0.6% and keeps the colour. AgX +
    key light 0.4 + ambient 1.0 was the best of 60+ measured variants
    (whole-frame mean Δ 11.9, 7.7% of pixels >32).
  - **Final verification:** `--write-movie` captures of the whole window
    (1920×1080, 20 frames, both renderers, `--quit-after 20`) → EXIT 0, no
    `SHADER ERROR` in either log; Forward+ before vs after = **0 differing
    pixels**; Forward+ vs Compatibility after = mean Δ 11.9 (was 30.9),
    7.7% of pixels >32 (was 68.3%). `--headless --quit-after 180` →
    **EXIT 0** (only the known benign "2 ObjectDB instances were leaked" /
    "1 resources still in use" messages). Gameplay check: a temporary
    harness unpaused the tree and pressed `MoveForward` — the ball rolled
    along the rope and the frame captured with no errors.
- 2026-10-21 **GREY HALO FIX (see 5.11).** Method: a scratch copy of the
  project in `/tmp/opencode/halo` (the repo was not touched) with the
  shader instrumented to render its individual terms to `ALBEDO`, plus a
  temporary probe that instantiates `res://scenes/Main.tscn` and **freezes
  `Engine.time_scale`** (the trees sway with `TIME`, so unfrozen runs are
  not pixel-comparable - two frozen runs differ in 0 pixels).
  - **Term isolation:** with the quad hidden the scene is clean at the halo
    pixels (sky `(94,180,230)`); with `highlights_enabled = false` the halo
    disappears completely, so the highlight term is the trigger.
  - **Term values at a tree edge (row 30):** halo pixel x=281 has
    `normal_diff = 203`, `neg_depth_diff = 0`, `alpha_mask = 203`; x=282 has
    `neg_depth_diff = 203` (the guard works there); x=283 has
    `alpha_mask = 203` (the outline).
  - **Noise evidence:** the reconstructed normal in the far distance is
    random per pixel (`(10,127,128)`, `(37,143,170)`, `(33,141,165)`)
    versus a stable `(131,145,209)` away from the silhouette; a
    view-distance bitmask puts the sky beyond 200 units and all geometry
    within 20.
  - **Fix applied** (`assets/shaders/pixelart_stylizer.gdshader:71-86`):
    fade the reconstructed normal to the constant far-plane normal with
    `1.0 - smoothstep(20.0, 60.0, length(p_center))`.
  - **After (frozen frame, Compatibility):** halo pixel `(30,281)`
    `(128,175,197)` -> `(94,180,230)`; `(31,280)` `(103,177,218)` ->
    `(94,180,230)`; the outline pixel `(30,283)` is unchanged `(0,7,4)`;
    isolated-spike pixels 4056 -> 3939; lighter (fringe) spikes 1460 -> 1399;
    **147 of 57600 source pixels changed (0.26%)**; rim highlight weight
    1.65% -> 1.40% (Forward+ reference 1.71%).
  - **Forward+ untouched:** the original and the fixed shader were captured
    with the same frozen probe -> **0 differing pixels of 57600** (max diff
    0). The fix lives entirely inside the
    `#if CURRENT_RENDERER == RENDERER_COMPATIBILITY` branch.
  - **Live window capture** (`--write-movie`, 20 frames, 1920x1080):
    Compatibility EXIT 0, Forward+ EXIT 0, **0 `SHADER ERROR` in either
    log**; the lighter-fringe pixel count drops 1644 -> 1584 (Forward+
    reference 1301). `--headless --quit-after 180` -> **EXIT 0** (only the
    known benign leak messages).
  - Evidence: `/tmp/opencode/halo/` (`real/final.png` - Compatibility
    before | after | Forward+; `out/*.png`; `real/*.png`).
- 2026-10-21 **SECOND HALO MECHANISM (§5.11).** Same method (frozen frame,
  instrumented shader in a scratch copy of the project under
  `/tmp/opencode/halo`, the repo itself untouched until the fix was applied).
  - **Term isolation at a fringe pixel (27,26) in the current build:**
    `normal_diff = 203` (the highlight fires on a *background* pixel),
    `depth_diff = 0` (it is in front of nothing), `neg_depth_diff = 0` (the
    guard cannot see it - all four neighbours are background), `alpha_mask =
    203`. With the highlight disabled the pixel is exactly the sky
    `(94,180,230)`.
  - **The Compatibility "rim" is noise:** with the foreground gate the
    highlight changes 56 px (0.10%) instead of 804 px (1.40%).
  - **Forward+'s highlight is already invisible in this build:** three
    captures (highlight on, highlight off, highlight code stripped at source
    level) are byte-identical (md5 `431e3bb442437326593d9ee8507d4c02`).
  - **Rejected:** a depth-based silhouette rim (0.00-0.07% weight - the
    shadow term overwrites the highlight at silhouette pixels); a
    raw-depth background test (the background's raw depth is not >= 0.9999);
    raising the Compatibility highlight threshold to (0.75, 1.35) to match the
    old weight (it brings back ~120 extra bright fringe pixels).
  - **After the fix (repo, frozen frame):** colour-cast pixels 550 -> 26
    (0.05% of the frame); lighter fringe pixels 1399 -> 1056 (Forward+
    reference 1115); highlight weight 1.40% -> 0.10%; 869 of 57 600 source
    pixels changed (1.51%); **Forward+ 0 differing pixels of 57 600** (max
    diff 0).
  - **Runs:** `--headless --quit-after 180` -> EXIT 0; windowed runs in both
    renderers -> EXIT 0 with **0 `SHADER ERROR`**; `--write-movie` capture
    (20 frames) -> EXIT 0, no shader errors. Evidence:
    `/tmp/opencode/halo/real2/` (`compare.png` - Compatibility before | after
    | Forward+; `after_gc.png`, `before_gc.png`, `after_fwd.png`,
    `before_fwd.png`, `after_scene.png`).
- Web checks (HTML5 export, iframe embed): **not yet performed.**

## 7. Immediate actions

### Implement + verify now

1. ~~**Crux test (§5.1).**~~ **✅ DONE (2026-10-18) — PASSED.** The
   `#if CURRENT_RENDERER == RENDERER_FORWARD_PLUS` guard around the
   `hint_normal_roughness_texture` uniform compiles clean under
   `--rendering-method gl_compatibility`; the two-file fallback was **not**
   needed. Output: §6.
2. ~~**Port the shader (§5.1-5.2).**~~ **✅ DONE (2026-10-18).**
   - Normal-texture uniform *and* the highlight use are guarded with
     `#if CURRENT_RENDERER == RENDERER_FORWARD_PLUS`; the Forward+ path is the
     original code, byte-for-byte (only added lines vs HEAD).
   - Compatibility branch added: a view-space normal reconstructed from 3 depth
     taps (centre / right / up, cross product) feeds the existing
     `normalIndicator()` math.
   - `getDepth()` NDC is branched per renderer: Vulkan
     `vec3(uv * 2.0 - 1.0, d)` vs OpenGL `vec3(uv, d) * 2.0 - 1.0`.
3. ~~**Verify (record in §6).**~~ **✅ DONE (2026-10-18).**
   - Forward+ before/after → **0 pixel diff** on 5 sampled frames.
   - Compatibility → no `SHADER ERROR`, 30 frames; the depth-outline mask
     matches the Forward+ reference at IoU 0.911; the highlight changes 1.79%
     of pixels vs 1.75% for the Forward+ reference.
   - The reconstruction threshold was tuned to `smoothstep(0.9, 1.5, …)`
     (baseline `(0.2,0.8)` changed 4.83%); sweep numbers in §6.
4. ~~**Close the Compatibility colour gap (§5.3-5.4).**~~ **✅ DONE
   (2026-10-21).** Root-caused to the engine's shadowed-light multi-pass
   (godotengine/godot#90259) plus the raw background write, not to the
   shader. The scene now carries a Compatibility-tuned look (AgX tonemap,
   key light 0.4, Compatibility sky) and `scenes/game.gd` restores the
   original v1.0.0 look on Forward+. Measured: the two renderers went from
   68.3% of pixels differing by >32 to **7.7%**, and the Forward+ build is
   still bit-identical to v1.0.0. Alternatives A and B are recorded in
   §5.4 if the cast shadows ever need to go.

5. ~~**Remove the grey halo around the pixel outline (§5.11).**~~ **✅ DONE
   (2026-10-21).** The Compatibility depth->normal reconstruction is noise in
   the far distance, which made the highlight term fire on background pixels
   next to a silhouette; the quad's partial alpha then painted a 1px grey
   fringe outside the black outline. The reconstruction is now faded to the
   constant far-plane normal over the far distance. The halo pixels are now
   exactly the sky colour, only 0.26% of source pixels changed, and the
   Forward+ path is bit-identical (0 differing pixels). Measurements in §6.

### Then

6. **Web project settings + export (§5.8-5.9).** `resizable=true` + sane
   stretch, interaction-gated BGM, `gl_compatibility` in the HTML5 export
   preset, ASCII paths, thread support OFF.
