#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUST_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
cd "$RUST_DIR"
ROOT_DIR="$(cd -- "$RUST_DIR/.." && pwd)"
cd "$RUST_DIR"

if [ ! -f "$ROOT_DIR/pubspec.yaml" ]; then echo "❌  Wrong directory! pubspec.yaml not found in $ROOT_DIR"; exit 2; fi

# ---------- helpers ------------------------------------------------------------

get_channel_from_file() {
  # Prefer repo root pin, then local; default to Edition-2024 MSRV (1.85.0)
  for p in "$ROOT_DIR/rust-toolchain.toml" "rust-toolchain.toml"; do
    if [[ -f "$p" ]]; then
      local value
      value="$(awk -F\" '/channel *=/ {print $2; exit}' "$p" || true)"
      [[ -n "${value:-}" ]] && { echo "$value"; return; }
    fi
  done
  echo "1.85.0"
}

get_rust_version_from_cargo() {
  # Extracts [package].rust-version from rust/Cargo.toml
  if [[ -f "Cargo.toml" ]]; then
    awk -F\" '/^\s*rust-version\s*=\s*"/ {print $2; exit}' Cargo.toml || true
  fi
}

CHANNEL_DEFAULT="$(get_channel_from_file)"

resolved_channel() {
  if [[ -n "${1:-}" ]]; then echo "$1"; else echo "$CHANNEL_DEFAULT"; fi
}

cargo_plus() { local ch; ch="$(resolved_channel "${1:-}")"; shift || true; command cargo +"$ch" "$@"; }
rustup_run() { local ch; ch="$(resolved_channel "${1:-}")"; shift || true; command rustup run "$ch" "$@"; }

# sed -i portable (macOS/BSD vs GNU)
sed_in_place() {
  if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi
}

ensure_tool() {
  local bin="$1" crate="$2"
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "→ Installing $crate ..."
    cargo install "$crate" --force
  fi
}

print_header() {
  echo "──────────────────────────────────────────────────────────────────────────────"
  echo "$*"
  echo "──────────────────────────────────────────────────────────────────────────────"
}

# ---------- alias expansion (match root/widgetbook vibe) ----------------------

aliases=(
  "lint:analyze"
  "start:run"
)

for pair in "${aliases[@]}"; do
  short="${pair%%:*}"
  full="${pair##*:}"
  if [[ "${1:-}" == "$short" ]]; then
    set -- "$full" "${@:2}"
    break
  elif [[ "${1:-}" == "$short:"* ]]; then
    suffix="${1#"$short:"}"
    set -- "$full:$suffix" "${@:2}"
    break
  fi
done

# ---------- help ---------------------------------------------------------------

help() {
  cat <<'EOF'
Usage: scripts/app.sh <command> [args]

General
  help                              - Shows this help
  doctor                            - Shows rustup toolchains & rustc version

Quality
  format                            - Formats Rust code and Dart (lib test)
  clippy                            - Lints Rust code
  analyze | lint                    - Alias for clippy
  test                              - Runs the Rust tests for the crate(s)
  build                             - Compiles the Rust code and build the default dev profile (no --release)
  clean                             - Runs Rust’s clean for the crate(s). It deletes the rust/target/ build artifacts (including incremental build cache). It doesn’t touch Cargo.lock, Flutter/Pods/android caches, or anything outside rust/.
  refresh                           - clean → update → format → lint → build → test

Toolchain / MSRV / Edition   (docs/update-rust.md)
  install:toolchain [<channel>]     - Installs and uses the toolchain (default: install pinned from rust-toolchain.toml)
  install:edition                   - Installs and uses the Rust Edition set in Cargo.toml (e.g., after update)
  uninstall:toolchain [<channel>]   - Uninstalls the provided toolchain (not the current default)

Flutter Rust Bridge          (docs/update-flutter-rust-bridge.md)
  install:frb [<version>]           - Installs flutter_rust_bridge_codegen (given or latest) and cargo-ndk (latest)
  generate                          - Regenerates Flutter<->Rust bindings with Flutter Rust Bridge (auto-detects rust_input/dart_output)

Dependencies                 (docs/update-rust-dependencies.md)
  outdated                          - Lists all outdated dependencies (direct and transitive) and show current vs compatible/latest version. (requires and automatically installs cargo-outdated)
  outdated:root                     - Lists all outdated root-only dependencies: Only shows crates listed in Cargo.toml (ignores transitive deps)
  upgrade                           - Updates the version requirements in Cargo.toml to the latest compatible releases; afterwards do app rust update to refresh the lockfile. (requires and automatically installs cargo-edit)
  update                            - Refreshes Cargo.lock to the newest versions that satisfy your Cargo.toml constraints (non-breaking). Does not change Cargo.toml.

Notes
- Commands default to the pinned rust-version in Cargo.toml or channel in rust-toolchain.toml.
- This script runs from rust/ automatically, so paths like Cargo.toml are local.
EOF
}

# ---------- commands -----------------------------------------------------------

case "${1:-help}" in
  help) help ;;

  doctor)
    CH="$(get_rust_version_from_cargo)"
    [[ -z "$CH" ]] && CH="$(resolved_channel "")"
    print_header "Rust Doctor (channel: $CH)"
    rustup show
    echo
    echo -n "rustc (effective, respecting rust-toolchain.toml): "
    rustc --version
    echo -n "rustc (+$CH explicit): "
    rustup run "$CH" rustc --version
    ;;

  install:toolchain)
    shift || true
    CH="$(resolved_channel "${1:-}")"
    print_header "Installing toolchain $CH"
    rustup toolchain install "$CH"
    ;;

  install:edition)
    CH="$(get_rust_version_from_cargo)"
    [[ -z "$CH" ]] && CH="$(resolved_channel "")"
    print_header "cargo +$CH fix --edition --allow-dirty"
    cargo_plus "$CH" fix --edition --allow-dirty
    ;;

  format)
    CH="$(get_rust_version_from_cargo)"
    [[ -z "$CH" ]] && CH="$(resolved_channel "")"
    print_header "cargo +$CH fmt --all"
    cargo_plus "$CH" fmt --all

    # Also run Dart formatter for project code (same as root script)
    if command -v fvm >/dev/null 2>&1; then DART_CMD="fvm dart"; else DART_CMD="dart"; fi
    print_header "$DART_CMD format --line-length=120 lib test (from $ROOT_DIR)"
    ( cd "$ROOT_DIR" && $DART_CMD format --line-length=120 lib test )
    ;;

  clippy|analyze|lint)
    CH="$(get_rust_version_from_cargo)"
    [[ -z "$CH" ]] && CH="$(resolved_channel "")"
    print_header "cargo +$CH clippy --workspace --all-targets -- -D warnings"
    cargo_plus "$CH" clippy --workspace --all-targets -- -D warnings
    ;;

  test)
    CH="$(get_rust_version_from_cargo)"
    [[ -z "$CH" ]] && CH="$(resolved_channel "")"
    print_header "cargo +$CH test --workspace"
    cargo_plus "$CH" test --workspace
    ;;

  build)
    CH="$(get_rust_version_from_cargo)"
    [[ -z "$CH" ]] && CH="$(resolved_channel "")"
    print_header "cargo +$CH build"
    cargo_plus "$CH" build
    ;;

  clean)
    print_header "cargo clean"
    cargo clean
    ;;

  outdated)
    print_header "cargo outdated"
    ensure_tool cargo-outdated cargo-outdated
    cargo outdated
    ;;

  outdated:root)
    print_header "cargo outdated -R (root-only)"
    ensure_tool cargo-outdated cargo-outdated
    cargo outdated -R
    ;;

  upgrade)
    print_header "cargo upgrade (cargo-edit)"
    ensure_tool cargo-add cargo-edit
    ensure_tool cargo-upgrade cargo-edit
    cargo upgrade
    ;;

  update)
    CH="$(get_rust_version_from_cargo)"
    [[ -z "$CH" ]] && CH="$(resolved_channel "")"
    print_header "cargo +$CH update"
    cargo_plus "$CH" update
    ;;

  install:frb)
    shift || true
    VERS="${1:-}"
    if [[ -n "$VERS" ]]; then
      print_header "Installing flutter_rust_bridge_codegen --version $VERS (forced)"
      cargo install flutter_rust_bridge_codegen --version "$VERS" --force
    else
      print_header "Installing flutter_rust_bridge_codegen (latest, forced)"
      cargo install flutter_rust_bridge_codegen --force
    fi
    print_header "Installing cargo-ndk (latest, forced)"
    cargo install cargo-ndk --force
    flutter_rust_bridge_codegen --version || true
    cargo-ndk --version || true
    ;;

  generate)
    RUST_INPUT="${FRB_RUST_INPUT:-}"
    RUST_ROOT="${FRB_RUST_ROOT:-.}"
    DART_OUTPUT="${FRB_DART_OUTPUT:-}"

    # Detect rust_input if not provided
    if [[ -z "$RUST_INPUT" ]]; then
      if [[ -f "src/api.rs" || -f "src/api/mod.rs" || -d "src/api" ]]; then
        RUST_INPUT="crate::api"
      elif [[ -f "src/lib.rs" ]]; then
        RUST_INPUT="crate"
      else
        echo "❌  Could not determine rust_input. Create src/api.rs (preferred) or set FRB_RUST_INPUT (e.g., crate::api)." >&2
        exit 2
      fi
    fi

    # Detect dart_output if not provided
    if [[ -z "$DART_OUTPUT" ]]; then
      if [[ -d "../lib/src/rust" ]]; then
        DART_OUTPUT="../lib/src/rust"
      elif [[ -d "../lib" ]]; then
        DART_OUTPUT="../lib/bridge_generated.dart"
      elif [[ -d "../../lib" ]]; then
        DART_OUTPUT="../../lib/bridge_generated.dart"
      else
        echo "❌  Could not determine dart_output. Set FRB_DART_OUTPUT or ensure a ../lib folder exists." >&2
        exit 2
      fi
    fi

    print_header "flutter_rust_bridge_codegen generate --rust-input $RUST_INPUT --rust-root $RUST_ROOT --dart-output $DART_OUTPUT --no-dart-enums-style"
    flutter_rust_bridge_codegen generate \
      --rust-input "$RUST_INPUT" \
      --rust-root "$RUST_ROOT" \
      --dart-output "$DART_OUTPUT" \
      --no-dart-enums-style

    # Always format after generating (Rust + Dart)
    bash "$0" format
    ;;

  refresh)
    print_header "Refresh: clean → update → format → clippy → build → test"
    "$SCRIPT_DIR/app.sh" clean
    "$SCRIPT_DIR/app.sh" update
    "$SCRIPT_DIR/app.sh" format
    "$SCRIPT_DIR/app.sh" clippy
    "$SCRIPT_DIR/app.sh" build
    "$SCRIPT_DIR/app.sh" test
    ;;

  update:rust)
    # update:rust <channel>
    shift || true
    [[ -z "${1:-}" ]] && { echo "Usage: update:rust <channel>" >&2; exit 2; }
    CH="$1"
    print_header "Update Rust toolchain/MSRV to $CH"
    "$SCRIPT_DIR/app.sh" install:toolchain "$CH"
    "$SCRIPT_DIR/app.sh" toolchain:pin "$CH"
    "$SCRIPT_DIR/app.sh" msrv:set "$CH"
    echo "Tip: If you also want to move edition, run: $SCRIPT_DIR/app.sh update:edition 2024 $CH"
    ;;

  update:edition)
    # update:edition <edition> [<channel>]
    shift || true
    [[ -z "${1:-}" ]] && { echo "Usage: update:edition <edition> [<channel>]" >&2; exit 2; }
    ED="$1"; CH="$(resolved_channel "${2:-}")"
    print_header "Update edition → $ED (then cargo fix --edition on $CH)"
    "$SCRIPT_DIR/app.sh" edition:set "$ED"
    "$SCRIPT_DIR/app.sh" install:edition "$CH" --allow-dirty || "$SCRIPT_DIR/app.sh" install:edition "$CH"
    ;;

  run|start*)
    # Rust is a library here; keep command for symmetry with root/widgetbook scripts.
    echo "Nothing to run directly (Rust library crate). Use your Flutter runner (e.g., root scripts)."
    ;;

  *)
    help; exit 1 ;;
esac
