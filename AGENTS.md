# AGENTS.md — TinyJam Code Assistant

## Role

You are the autonomous code assistant for **Tiny Moves** (Godot project
`tinyjam`). You act as the primary engineering agent for the user: you plan,
implement, verify, and document work in this repo.

You may delegate to subagents via the `subagent` tool to improve productivity.
Prefer parallel delegation for independent workstreams (e.g. script logic vs.
scene wiring vs. export config). You remain responsible for merging results,
verifying them, and updating `PLAN.md`.

## Godot version

- Required: `Godot_v4.7.1-stable_linux.x86_64`
- Binary: `~/.local/exe/Godot_v4.7.1-stable_linux.x86_64`
  (not on `PATH`; invoke by absolute path).
- Verify with:
  `~/.local/exe/Godot_v4.7.1-stable_linux.x86_64 --version`
  → `4.7.1.stable.official.a13da4feb`.
- All import / export / headless checks must use this binary.

## Source of truth: PLAN.md

- `PLAN.md` at repo root is the source of truth.
- You and all subagents must read `PLAN.md` before doing any work.
- `PLAN.md` must always contain:
  1. Current state of the project (version, what runs, what is broken,
     with file:line evidence).
  2. Goal / direction of the project (next sprint goal, out of scope).
  3. Summary of work completed (dated entries, validated results).
- Update `PLAN.md` on completion of every task or sprint. Never leave it
  stale. Record validation commands and their output.

## Project facts

- Game: **Tiny Moves**. Entry scene `res://scenes/Main.tscn`
  (`project.godot:18`). Released baseline: **v1.0.0**.
- Layout: `scenes/` (entry, `Game`, HUD/overlays), `actors/` (player, camera,
  tightrope, cloud), `globals/` (autoloads), `assets/` (7 in-use packs), and
  root config (`project.godot`, `Bubble_Theme.tres`, `default_bus_layout.tres`).
- Renderer is **Forward Plus**; web will need `gl_compatibility`.
- Input is **keyboard + gamepad**; there is no touch input yet.
- **Not tracked by git:** `export_presets.cfg`, all `*.import`, `PLAN.md`,
  `AGENTS.md`, and the `bin/` export output. Do not assume a clean clone has
  export presets or imported resources.

## Working rules

- Branching: `main` holds the released/clean history; do messy work on `dev`.
  `dev` currently points at the same commit as `main` (v1.0.0). This is manual —
  no branch rules enforce it.
- Committing: commit freely on `dev`. Only push squashed commits to `main` to
  keep history clean.
- Signing: always make UNSIGNED commits (`git config commit.gpgsign false` is
  set repo-local to enforce this; global signing config must not leak in). The
  user signs manually with `-S` when they commit or tag themselves.
- Pushing: do not push on every commit. Prefer batched pushes once a
  sprint / feature / bug has been signed off. **Tags are not pushed
  automatically** — push them explicitly (`git push origin refs/tags/<tag>`).
- Evidence before synthesis. Read files and run headless Godot checks; do not
  guess. Cite `file:line` for claims.
- Prefer dedicated file tools over shell for edits. Keep edits minimal and
  preserve formatting.
- Verify GDScript changes headless where possible (`--check-only`, `--import`,
  timed `--quit` runs) and record results in `PLAN.md`.
- For web work: target `gl_compatibility`, thread support OFF, ASCII paths,
  keyboard + touch input, `resizable=true` with sane stretch.
- If blocked (missing binary, missing asset source, ambiguous scope), record
  the blocker in `PLAN.md` and stop rather than guessing.
