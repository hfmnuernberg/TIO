# TIO Music - Claude Code Project Guide

## Project Overview

TIO Music is a cross-platform mobile app (iOS & Android) for musicians, developed for Hochschule für Musik Nürnberg. It's a "notebook for musicians" with tools like metronome, tuner, piano, media player, flash cards, and more.

### Project History

Studio Fluffy originally developed TIO and left the project in poor shape — no test coverage, poor code quality. cultivate(software) took over around early 2025 and has been continuously refactoring, adding tests, and improving the codebase. The refactoring is ongoing: new code follows clean architecture, but legacy areas remain. The service layer, domain layer, and dependency injection were introduced by cultivate — they are not part of the original design.

## Tech Stack

- **Frontend**: Flutter 3.35.2 (via FVM) / Dart 3.9.0
- **Native audio engine**: Rust 1.89.0 (FFI via flutter_rust_bridge 2.11.1)
- **State management**: Provider + ChangeNotifier
- **Serialization**: json_serializable (with build_runner code generation)
- **Testing**: flutter_test + mocktail
- **CI/CD**: GitHub Actions, Fastlane (iOS), semantic-release

## Repository Structure

```
├── lib/                        # Flutter/Dart source
│   ├── main.dart               # Entry point, DI setup (MultiProvider)
│   ├── app.dart                # Root widget, routing, theming
│   ├── domain/                 # Business logic (audio, metronome, piano, tuner, flash_cards)
│   ├── models/                 # Data models (ChangeNotifier-based)
│   │   └── blocks/             # Block types (TextBlock, ImageBlock, MetronomeBlock, etc.)
│   ├── pages/                  # UI screens (home, metronome, tuner, piano, media_player, etc.)
│   ├── services/               # Service interfaces (mixins) + impl/ + decorators/
│   ├── widgets/                # Reusable UI components
│   ├── util/                   # Constants, helpers, localization (en/de)
│   └── src/rust/               # Generated Rust FFI bindings (DO NOT EDIT)
├── rust/                       # Rust native library
│   ├── src/api/
│   │   ├── ffi.rs              # FFI functions exposed to Dart
│   │   ├── modules/            # Core: media_player, generator, tuner, metronome, piano, recorder
│   │   ├── audio/              # Audio buffers, global lock, interpolation
│   │   └── util/               # Constants, audio loading/resampling
│   └── Cargo.toml
├── test/                       # Dart tests (domain/, integration/, widgets/, mocks/)
├── scripts/                    # Build automation
│   └── app.sh                  # Main CLI for all dev tasks
├── docs/                       # Project documentation
├── assets/                     # Icons, sounds, SoundFonts, themes
├── widgetbook/                 # Widget documentation/gallery
├── .github/workflows/          # CI/CD pipelines
├── pubspec.yaml                # Flutter dependencies
├── analysis_options.yaml       # Dart linting (120 char line length)
├── rust-toolchain.toml         # Rust version + Android targets
├── justfile                    # Quick tasks (gen, lint, clean, serve)
└── flutter_rust_bridge.yaml    # Rust-Dart bridge config
```

## Key Commands

All commands via `scripts/app.sh` from repo root:

| Task | Command |
|------|---------|
| Install all deps | `scripts/app.sh install` |
| Run app | `scripts/app.sh run` |
| Run tests | `scripts/app.sh test` |
| Run specific test | `scripts/app.sh test <path> <name>` |
| Test with coverage | `scripts/app.sh coverage:measure:random` |
| Validate coverage | `scripts/app.sh coverage:validate 62.7` |
| Format code | `scripts/app.sh format` |
| Lint/analyze | `scripts/app.sh analyze` |
| Generate all code | `scripts/app.sh generate` |
| Generate Rust bindings | `scripts/app.sh generate:rust` |
| Generate JSON serialization | `scripts/app.sh generate:json` |
| Build iOS | `scripts/app.sh build ios` |
| Build Android | `scripts/app.sh build android prd prd release` |
| Clean all | `scripts/app.sh clean` |
| Full reset | `scripts/app.sh reset` |

Rust-specific commands:

| Task | Command |
|------|---------|
| Rust tests | `scripts/app.sh rust test` |
| Rust lint | `scripts/app.sh rust clippy` |
| Rust format | `scripts/app.sh rust format` |
| Rust build | `scripts/app.sh rust build` |

## Architecture Patterns

### Dart/Flutter

- **Layered architecture**: pages (UI) → domain (logic) → services (abstractions) → models (data)
- **Dependency injection**: Manual setup in `main.dart` via `MultiProvider` with `Provider<Interface>`
- **Service pattern**: Interfaces defined as Dart **mixins** in `services/`, implementations in `services/impl/`, logging decorators in `services/decorators/`
- **State**: Models extend `ChangeNotifier` (e.g., `Project`, `ProjectLibrary`)
- **Navigation**: Imperative (`Navigator.push()`), not declarative routing
- **Persistence**: File-based JSON (ProjectRepository, MediaRepository)
- **Localization**: Custom delegate with English (en) and German (de) translations

### Rust

- **Purpose**: Real-time audio processing (pitch shifting, pitch detection, time stretching, MIDI synthesis)
- **FFI bridge**: All public API in `rust/src/api/ffi.rs`, auto-bridged to Dart
- **Concurrency**: Global audio lock mutex + per-module static state via `lazy_static!`
- **Instance pattern**: Media players use ID-based `HashMap<u32, PlayerInstance>` for multiple concurrent instances
- **Audio pipeline**: Load file → decode (symphonia) → mix to mono → resample (rubato) → process

### Project Domain Model

- A **ProjectLibrary** contains multiple **Projects**
- Each **Project** contains multiple **Blocks** (TextBlock, ImageBlock, MetronomeBlock, PianoBlock, TunerBlock, MediaPlayerBlock, FlashCardBlock)
- Blocks are the core building units - each represents a music tool or content type within a project

## Code Conventions

- **Clean Code (Uncle Bob)**: Small functions, small files, meaningful names. SOLID principles, especially SRP and OCP.
- **Minimal invasiveness**: Change what needs to change. Don't rewrite unrelated code, even if it's not great yet.
- **No unnecessary comments**: No comments that repeat what the code says. No debug logging left in committed code.
- **Line length**: 120 characters (Dart and YAML)
- **Dart formatting**: `dart format -l 120`
- **Rust formatting**: `cargo fmt`
- **Linting**: 50+ custom Dart rules in `analysis_options.yaml`, Rust uses clippy with warnings-as-errors
- **Logging**: `createPrefixLogger('ClassName')` from `util/log.dart`
- **Generated files**: `.g.dart` (JSON), `lib/src/rust/` (FFI) — never edit manually
- **PR titles**: Conventional commits with JIRA ticket: `<type>[(<scope>)]: TIO-###: <description>`
- **Coverage threshold**: 62.7% minimum (ratcheted up as coverage improves)
- **L10n**: Use simple getters for translations, not parameterized functions. Group keys semantically by tool/feature.

## Testing Conventions

- **Integration-level tests**: Render at `ProjectPage` level, navigate to tools, interact through the UI
- **Mocking boundary**: Mock at the **services layer** (AudioSystem, FileSystem, etc.), not at model/block level. Create tools through the UI, not by mocking blocks.
- **No comments in tests**: Use sub-functions and helpers with descriptive names instead
- **Test naming**: Name from the user's perspective of the class, not implementation details
- **Meaningful tests**: Test actual behavior, not getters. Reduce mocking to a minimum.
- **Test utilities**: Helpers in `test/utils/` (e.g., `media_player_utils.dart`, `project_utils.dart`, `render_utils.dart`)
- **Coverage ratcheting**: Thresholds are tightened after improvements — both coverage % and file complexity limits

## Working with Claude Code

- **Never push to remote** — the user pushes manually
- **Don't commit unless explicitly asked** — the user will say when to commit
- **Plan before implementing** — present approach for review before writing code. The user actively reviews plans and catches design issues.
- **Verification before committing**: `scripts/app.sh format` → `scripts/app.sh analyze` → `scripts/app.sh test` → `scripts/app.sh analyze:files`
- **German may be used**: The user occasionally gives instructions in German — understand and act on them normally
- **Iterative workflow**: The user tests changes manually on real devices and reports bugs back for fixing. Multiple rounds of polish are normal.

## CI Pipeline (on PR)

1. YAML lint
2. Static analysis (Dart + Rust clippy)
3. Format check
4. File complexity check (max 23 files exceeding limit, max 342 avg lines)
5. TODO/FIXME analysis
6. Tests with coverage (random order, >= 62.7%)
7. PR title validation (conventional commits + JIRA ticket)

## Important Notes

- After modifying Rust code in `rust/src/api/`, regenerate bindings: `scripts/app.sh generate:rust`
- After modifying model classes with `@JsonSerializable`, regenerate: `scripts/app.sh generate:json`
- The `lib/src/rust/` directory is entirely generated — never edit files there
- Audio initialization differs per platform: iOS initializes audio session first, Android initializes audio system directly
- Tests use `mocktail` for mocking services; test utilities in `test/utils/` and `test/mocks/`
- Existing docs in `docs/` cover setup, publishing, troubleshooting, and upgrade procedures

## Known Gotchas

- **FRB codegen enum naming**: Running `flutter_rust_bridge_codegen generate` changes metronome rhythm enums from PascalCase to camelCase. Restore `metronome_rhythm.dart` after codegen runs.
- **In tests, `context.audioSystem` vs `context.audioSystemMock`**: `context.audioSystem` is the `AudioSystemLogDecorator` wrapper. Use `context.audioSystemMock` when stubbing or verifying.
- **`resetMocktailState()` is dangerous**: It clears ALL stubs and invocations across ALL mocks. Use `clearInteractions(mockObject)` instead to only clear history while keeping stubs.
- **iOS signing**: Uses Fastlane Match with a private Git repo (`TIO-fastlane`). Profiles are referenced by name, so regenerating certs via `match nuke` + `match appstore` doesn't require project file changes.
