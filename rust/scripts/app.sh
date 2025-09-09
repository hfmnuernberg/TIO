#!/usr/bin/env bash

set -euo pipefail

if [ ! -f "./pubspec.yaml" ]; then echo "❌  Wrong directory! Must be in project root!"; exit 2; fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUST_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
cd "$RUST_DIR"

# ---------- helpers ------------------------------------------------------------

get_channel_from_file() {
  # Read rust-toolchain.toml's channel; default to "stable"
  if [[ -f "rust-toolchain.toml" ]]; then
    local value
    value="$(awk -F\" '/channel *=/ {print $2; exit}' rust-toolchain.toml || true)"
    [[ -n "${value:-}" ]] && { echo "$value"; return; }
  fi
  echo "stable"
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
  help                                      Show this help
  doctor [<channel>]                        Show rustup toolchains & rustc version (default: pinned)

Toolchain / MSRV / Edition   (docs/update-rust.md)
  toolchain:install [<channel>]             rustup toolchain install (default: pinned)
  toolchain:pin <channel>                   Write rust-toolchain.toml with the given channel
  msrv:set <version>                        Set [package].rust-version in Cargo.toml
  edition:set <edition>                     Set [package].edition in Cargo.toml (e.g. 2021, 2024)
  edition:fix [<channel>] [--allow-dirty]   Run cargo +<channel> fix --edition

Quality
  fmt [<channel>]                           cargo fmt --all
  clippy [<channel>]                        cargo clippy --workspace --all-targets -D warnings
  analyze [<channel>]                       Alias for clippy
  test [<channel>]                          cargo test --workspace
  build [<channel>]                         cargo build
  clean                                     cargo clean

Dependencies                 (docs/update-rust-dependencies.md)
  deps:outdated                             cargo outdated (root & transitive)
  deps:outdated:root                        cargo outdated -R (only root deps)
  deps:upgrade                              cargo upgrade            (requires cargo-edit)
  deps:update [<channel>]                   cargo +<channel> update  (refresh lockfile)

Flutter Rust Bridge          (docs/update-flutter-rust-bridge.md)
  frb:install [<version>]                   cargo install flutter_rust_bridge_codegen [--version X] --force
  frb:generate                              flutter_rust_bridge_codegen generate --no-dart-enums-style

Flows
  refresh                                   clean → deps:update → fmt → clippy → build → test
  update:rust <channel>                     toolchain:install + toolchain:pin + msrv:set <channel> + (optional edition)
  update:edition <edition> [<channel>]      edition:set + edition:fix

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
    echo -n "rustc version ($CH): "
    rustup_run "$CH" rustc --version
    ;;

  toolchain:install)
    shift || true
    CH="$(resolved_channel "${1:-}")"
    print_header "Installing toolchain $CH"
    rustup toolchain install "$CH"
    ;;

  toolchain:pin)
    shift || true
    [[ -z "${1:-}" ]] && { echo "Usage: toolchain:pin <channel>" >&2; exit 2; }
    CH="$1"
    print_header "Pinning rust-toolchain.toml → channel=\"$CH\""
    cat > rust-toolchain.toml <<EOF
[toolchain]
channel = "$CH"
EOF
    ;;

  msrv:set)
    shift || true
    [[ -z "${1:-}" ]] && { echo "Usage: msrv:set <version>" >&2; exit 2; }
    V="$1"
    print_header "Setting [package].rust-version=\"$V\" in Cargo.toml"
    if grep -qE '^\s*rust-version\s*=' Cargo.toml; then
      sed_in_place 's/^\(\s*rust-version\s*=\s*\)".*"/\1"'"$V"'"/' Cargo.toml
    else
      if grep -q '^\[package\]' Cargo.toml; then
        awk -v v="$V" '
          BEGIN{done=0}
          /^\[package\]/{print; getline; print "rust-version = \"" v "\""; print; done=1; next}
          {print}
          END{if(!done) print "\n[package]\nrust-version = \"" v "\""}
        ' Cargo.toml > Cargo.toml.__tmp && mv Cargo.toml.__tmp Cargo.toml
      else
        printf '\n[package]\nrust-version = "%s"\n' "$V" >> Cargo.toml
      fi
    fi
    ;;

  edition:set)
    shift || true
    [[ -z "${1:-}" ]] && { echo "Usage: edition:set <edition>" >&2; exit 2; }
    ED="$1"
    print_header "Setting [package].edition=\"$ED\" in Cargo.toml"
    if grep -qE '^\s*edition\s*=' Cargo.toml; then
      sed_in_place 's/^\(\s*edition\s*=\s*\)".*"/\1"'"$ED"'"/' Cargo.toml
    else
      if grep -q '^\[package\]' Cargo.toml; then
        awk -v ed="$ED" '
          BEGIN{done=0}
          /^\[package\]/{print; getline; print "edition = \"" ed "\""; print; done=1; next}
          {print}
          END{if(!done) print "\n[package]\nedition = \"" ed "\""}
        ' Cargo.toml > Cargo.toml.__tmp && mv Cargo.toml.__tmp Cargo.toml
      else
        printf '\n[package]\nedition = "%s"\n' "$ED" >> Cargo.toml
      fi
    fi
    ;;

  edition:fix)
    shift || true
    CH="$(resolved_channel "${1:-}")"
    [[ "${1:-}" == "$CH" ]] && shift || true
    ALLOW=""
    [[ "${1:-}" == "--allow-dirty" ]] && ALLOW="--allow-dirty"
    print_header "cargo +$CH fix --edition ${ALLOW}"
    cargo_plus "$CH" fix --edition ${ALLOW}
    ;;

  fmt)
    shift || true
    CH="$(resolved_channel "${1:-}")"
    print_header "cargo +$CH fmt --all"
    cargo_plus "$CH" fmt --all
    ;;

  clippy|analyze)
    shift || true
    CH="$(resolved_channel "${1:-}")"
    print_header "cargo +$CH clippy --workspace --all-targets -- -D warnings"
    cargo_plus "$CH" clippy --workspace --all-targets -- -D warnings
    ;;

  test)
    shift || true
    CH="$(resolved_channel "${1:-}")"
    print_header "cargo +$CH test --workspace"
    cargo_plus "$CH" test --workspace
    ;;

  build)
    shift || true
    CH="$(resolved_channel "${1:-}")"
    print_header "cargo +$CH build"
    cargo_plus "$CH" build
    ;;

  clean)
    print_header "cargo clean"
    cargo clean
    ;;

  deps:outdated)
    print_header "cargo outdated"
    ensure_tool cargo-outdated cargo-outdated
    cargo outdated
    ;;

  deps:outdated:root)
    print_header "cargo outdated -R (root-only)"
    ensure_tool cargo-outdated cargo-outdated
    cargo outdated -R
    ;;

  deps:upgrade)
    print_header "cargo upgrade (cargo-edit)"
    ensure_tool cargo-add cargo-edit
    ensure_tool cargo-upgrade cargo-edit
    cargo upgrade
    ;;

  deps:update)
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
    print_header "Refresh: clean → deps:update → fmt → clippy → build → test"
    "$SCRIPT_DIR/app.sh" clean
    "$SCRIPT_DIR/app.sh" deps:update
    "$SCRIPT_DIR/app.sh" fmt
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
    "$SCRIPT_DIR/app.sh" toolchain:install "$CH"
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
    "$SCRIPT_DIR/app.sh" edition:fix "$CH" --allow-dirty || "$SCRIPT_DIR/app.sh" edition:fix "$CH"
    ;;

  run|start*)
    # Rust is a library here; keep command for symmetry with root/widgetbook scripts.
    echo "Nothing to run directly (Rust library crate). Use your Flutter runner (e.g., root scripts)."
    ;;

  *)
    help; exit 1 ;;
esac
