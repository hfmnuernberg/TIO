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

# Extracts [package].rust-version from rust/Cargo.toml
get_rust_version_from_cargo() {
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
  help                                    Show this help
  doctor [<channel>]                      Show rustup toolchains & rustc version (default: pinned)

Toolchain / MSRV / Edition   (docs/update-rust.md)
  install:toolchain [<channel>]           Install and use the toolchain (default: install pinned from rust-toolchain.toml)
  install:edition                         Install and use the Rust Edition set in Cargo.toml (e.g., after update)

Quality
  format                                  Formats rust code (uses rust-version from Cargo.toml)
  clippy                                  Lints rust code (uses rust-version from Cargo.toml)
  analyze | lint                          Alias for clippy
  test                                    Runs the Rust tests for the crate(s) (uses rust-version from Cargo.toml)
  build                                   Compiles the Rust code (uses rust-version from Cargo.toml)
  clean                                   cargo clean

Dependencies                 (docs/update-rust-dependencies.md)
  outdated                                cargo outdated (root & transitive)
  outdated:root                           cargo outdated -R (only root deps)
  upgrade                                 cargo upgrade (requires cargo-edit)
  update [<channel>]                      cargo +<channel> update (refresh lockfile)

Flutter Rust Bridge          (docs/update-flutter-rust-bridge.md)
  frb:install [<version>]                 cargo install flutter_rust_bridge_codegen [--version X] --force
  frb:generate                            flutter_rust_bridge_codegen generate --no-dart-enums-style

Flows
  refresh                                 clean → update → format → clippy → build → test
  update:rust <channel>                   install:toolchain + toolchain:pin + msrv:set <channel> + (optional edition)
  update:edition <edition> [<channel>]    edition:set + install:edition

Notes
- Commands default to the pinned channel in rust-toolchain.toml, or "stable" if none is pinned.
- This script runs from rust/ automatically, so paths like Cargo.toml are local.
EOF
}

# ---------- commands -----------------------------------------------------------

case "${1:-help}" in
  help) help ;;

  doctor)
    shift || true
    CH="$(resolved_channel "${1:-}")"
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
    shift || true
    "$SCRIPT_DIR/app.sh" format
    CH="$(get_rust_version_from_cargo)"
    [[ -z "$CH" ]] && CH="$(resolved_channel "")"
    print_header "cargo +$CH fmt --all"
    cargo_plus "$CH" fmt --all
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
    shift || true
    CH="$(resolved_channel "${1:-}")"
    print_header "cargo +$CH update"
    cargo_plus "$CH" update
    ;;

  frb:install)
    shift || true
    VERS="${1:-}"
    print_header "Installing flutter_rust_bridge_codegen ${VERS:+(version $VERS)}"
    if [[ -n "$VERS" ]]; then
      cargo install flutter_rust_bridge_codegen --version "$VERS" --force
    else
      cargo install flutter_rust_bridge_codegen --force
    fi
    flutter_rust_bridge_codegen --version || true
    ;;

  frb:generate)
    print_header "flutter_rust_bridge_codegen generate --no-dart-enums-style"
    flutter_rust_bridge_codegen generate --no-dart-enums-style
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
