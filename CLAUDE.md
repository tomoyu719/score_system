# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run
dart run bin/score_system.dart

# Test all
dart test

# Test single file
dart test test/score_system_test.dart

# Static analysis (must pass with 0 warnings, 0 errors)
dart analyze

# Format
dart format .

# Build native executable
dart compile exe bin/score_system.dart -o build/score
```

Once Melos is set up (`melos.yaml`), use:

```bash
melos run analyze     # analyze all packages
melos run test        # test all packages
melos run deps_check  # verify dependency boundaries via tools/dep_checker.dart
```

## TDD Workflow

All public API development follows **Red → Green → Refactor**:

1. Write a failing test first
2. Implement the minimum code to make it pass
3. Refactor without breaking the test

Coverage targets: ≥80% overall; `score_core` + `score_layout` ≥85%.

## Architecture

This is a **headless-engine-first** personal music score editing system. It has no GUI; scores are manipulated via CLI, TUI, or MCP Server. The codebase is a **Pub workspace monorepo** (Dart SDK ≥3.9.2).

```
score_cli / score_tui / score_mcp   ← interface layers
              ↓
          score_core                ← command engine + data model + validation (pure Dart)
         ↙         ↘
  score_layout    score_io          ← layout calc / collision  |  file format I/O
```

Planned package layout under `packages/`:

| Package | Responsibility | `dart:io` | `dart:ffi` |
|---|---|---|---|
| `score_core` | Data model, CommandEngine, Validator, Query | ✗ | ✗ |
| `score_layout` | LayoutTree calculation, Collision detection/resolution | ✗ | ✗ |
| `score_io` | MusicXML 3.1, MIDI SMF, native `.score.json` | ✓ | ✗ |
| `score_cli` | `args` parsing, command routing | ✓ | ✗ |
| `score_tui` | ANSI terminal rendering, modal editing | ✓ | ✗ |
| `score_mcp` | MCP stdio transport (JSON-RPC 2.0), tool/resource handlers | ✓ | ✗ |

**Dependency direction is strictly one-way.** `score_core` and `score_layout` must never import `dart:io`, Flutter, or terminal packages. CI enforces this via `tools/dep_checker.dart`.

## Core Design Principles

**Immutable data model + CommandEngine**: All state changes flow through `CommandEngine.apply(command, score)`. Direct mutation is forbidden. `Score` and all child entities are `final class` immutable value objects using `copyWith`.

**Undo/Redo via full snapshots**: `CommandRecord` holds `scoreBefore` and `scoreAfter`. Since `Score` is immutable, this is just two references. Max 1000 steps.

**`CommandEngine` never throws for user errors**: Returns `CommandSuccess` or `CommandFailure` (with the original `Score` unchanged). Internal bugs throw `ScoreException`.

**`Fraction` for all timing**: Musical durations and offsets use `Fraction(int numerator, int denominator)`, never `double`. JSON representation is the string `"3/4"`.

**Type-safe IDs**: Every entity uses an `extension type` wrapper (e.g., `extension type NoteId(String value) {}`), so mismatched ID assignments are compile errors.

**Layout coordinate unit**: Staff Space (sp), where 1 sp = the interval between staff lines. Matches SMuFL standard; layout results are renderer-agnostic.

## Code Style (NFR-07)

- 1 file per public class
- `if` nesting max 1 level — use early returns
- All public APIs documented with `///` doc comments
- Linter: `package:lints/recommended.yaml`; CI enforces 0 warnings, 0 errors

## score_core Data Model Hierarchy

```
Score
  └── IList<Part>
        └── IList<Staff>
              └── IMap<measureNumber, Measure>
                    └── IMap<VoiceId, Voice>
                          └── IList<MusicEvent>  (NoteEvent | RestEvent | ChordEvent)
  └── IList<MeasureHeader>   (TimeSignature / KeySignature / Tempo / Barline — shared across Parts)
  └── IList<BeamGroup | Slur | Tie>  (edge elements referencing events by ID)
```

Uses `fast_immutable_collections` (`IList`, `IMap`) for structural sharing.

## CLI Output Contract

- Default output: **JSON** (for CI and coding agents)
- `--format pretty`: human-readable
- Errors always go to `stderr` as JSON
- Exit codes: `0` success, `1` error, `2` validation failure, `3` unresolved layout collision

## Collision Resolution Priority

Collision resolver moves lower-priority elements first; higher-priority elements are treated as immovable:

1. staff lines / barlines / noteheads (immovable)
2. stems / beams (Y-extend only)
3. accidentals (X only)
4. articulations (Y only)
5. dynamics / tempo text (Y only)
6. lyrics (Y down)
7. fingerings / chord symbols (X or Y)
8. rehearsal marks (Y only, lowest priority)

Elements with `isManualOverride: true` are skipped. Resolution iterates up to 10 times; remaining collisions become warnings.

## Native File Format (`.score.json`)

- UTF-8 JSON, 2-space indent, human-editable
- `$schema_version` field for migration
- `Fraction` as string `"3/4"`, IDs as UUID v4 strings
- Deterministic output (no timestamps by default) — same `Score` always produces the same file

## TUI Modal Editing

Vim-style 5 modes: `NORMAL` (default) → `INSERT` (`i`) for note entry → `VISUAL` (`v`) for range selection → `COMMAND` (`:`) for palette → `SEARCH` (`/`). `Esc` always returns to `NORMAL`. Score mutations go through `CommandEngine`; the TUI has no independent mutable state.

## MCP Server

- Protocol: MCP Specification 2024-11-05, JSON-RPC 2.0, stdio transport
- Resource URI scheme: `score://current`, `score://parts/{partId}`, `score://measures/{n}`, `score://layout`, `score://collisions`, etc.
- Sandbox: `--sandbox <dir>` restricts all file access; path traversal is rejected at request time
- All tool calls are appended to an audit log in JSONL format
- Destructive operations (part/measure delete, file save) require a confirmation handshake

## Testing Strategy

| Type | Location | Notes |
|---|---|---|
| Unit / Command Engine | each package | TDD — write test first |
| Layout golden | `score_layout/test/golden/` | Compare serialized `LayoutTree` JSON (no images needed) |
| MusicXML roundtrip | `score_io/test/fixtures/` | import → export → import must be lossless for supported elements |
| TUI snapshot | `score_tui/test/snapshots/` | ANSI-stripped plain text comparison |
| Dependency boundary | `tools/dep_checker.dart` | Enforced in CI |
| Property-based | `score_core` / `score_io` | Uses `glados` package |
