#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUST_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
cd "$RUST_DIR"

INSTRUMENTABLE_SRC="${TMPDIR:-/tmp}/tio-rust-coverage-src"
export CARGO_TARGET_DIR="$RUST_DIR/target/coverage"

INSTRUMENT_DEPENDENCIES_TOO="--no-rustc-wrapper"
FRB_ATTRIBUTE='^[[:space:]]*#\[(flutter_rust_bridge::)?frb\(.*\)\][[:space:]]*$'
IGNORE_REGEX='(frb_generated\.rs|src/api/test/|src/api/ffi\.rs|build\.rs)'
LCOV_FILE="$RUST_DIR/coverage/lcov.info"

read_toolchain_channel() {
  local channel
  channel="$(awk -F\" '/^[[:space:]]*rust-version[[:space:]]*=/ {print $2; exit}' Cargo.toml)"
  [ -n "$channel" ] || channel="$(awk -F\" '/^[[:space:]]*channel[[:space:]]*=/ {print $2; exit}' \
    "$RUST_DIR/../rust-toolchain.toml")"
  echo "$channel"
}

CHANNEL="$(read_toolchain_channel)"

print_header() {
  echo "──────────────────────────────────────────────────────────────────────────────"
  echo "$*"
  echo "──────────────────────────────────────────────────────────────────────────────"
}

ensure_llvm_cov() {
  rustup component add llvm-tools --toolchain "$CHANNEL" >/dev/null 2>&1 || true
  if ! command -v cargo-llvm-cov >/dev/null 2>&1; then
    echo "→ Installing cargo-llvm-cov ..."
    cargo install cargo-llvm-cov --locked
  fi
}

copy_sources_without_frb_attributes() {
  rm -rf "$INSTRUMENTABLE_SRC"
  mkdir -p "$INSTRUMENTABLE_SRC"
  rsync -a --exclude '/target' --exclude '/coverage' "$RUST_DIR/" "$INSTRUMENTABLE_SRC/"
  find "$INSTRUMENTABLE_SRC/src" -name '*.rs' -exec sed -i.bak -E "/$FRB_ATTRIBUTE/d" {} +
  find "$INSTRUMENTABLE_SRC/src" -name '*.rs.bak' -delete
  silence_lints_in_copy
}

silence_lints_in_copy() {
  local lib="$INSTRUMENTABLE_SRC/src/lib.rs"
  printf '#![allow(warnings)]\n%s\n' "$(cat "$lib")" > "$lib"
}

rewrite_copy_paths_to_committed_sources() {
  local resolved_copy; resolved_copy="$(cd "$INSTRUMENTABLE_SRC" && pwd -P)"
  sed -i.bak -e "s|$resolved_copy|$RUST_DIR|g" -e "s|$INSTRUMENTABLE_SRC|$RUST_DIR|g" "$LCOV_FILE"
  rm -f "$LCOV_FILE.bak"
}

assert_measured() {
  if [ ! -d "$INSTRUMENTABLE_SRC" ]; then
    echo "❌  No coverage data. Run 'scripts/app.sh rust coverage:measure' first." >&2
    exit 2
  fi
}

report() {
  assert_measured
  ( cd "$INSTRUMENTABLE_SRC" && cargo +"$CHANNEL" llvm-cov report --ignore-filename-regex "$IGNORE_REGEX" "$@" )
}

case "${1:-help}" in
  coverage)
    bash "$0" coverage:measure
    bash "$0" coverage:generate
    bash "$0" coverage:open
    ;;

  coverage:measure)
    ensure_llvm_cov
    copy_sources_without_frb_attributes
    print_header "cargo +$CHANNEL llvm-cov --no-report $INSTRUMENT_DEPENDENCIES_TOO --workspace"
    ( cd "$INSTRUMENTABLE_SRC" &&
      cargo +"$CHANNEL" llvm-cov --no-report "$INSTRUMENT_DEPENDENCIES_TOO" --workspace )
    mkdir -p coverage
    report --lcov --output-path "$LCOV_FILE"
    rewrite_copy_paths_to_committed_sources
    ;;

  coverage:print)
    report
    ;;

  coverage:validate)
    threshold="${2:-}"
    if [ -z "$threshold" ]; then echo "📖 Usage: $0 coverage:validate <threshold>" >&2; exit 2; fi
    echo "Threshold: $threshold%"
    report --fail-under-lines "$threshold"
    ;;

  coverage:generate)
    report --html --output-dir "$RUST_DIR/coverage/html"
    ;;

  coverage:open)
    open "$RUST_DIR/coverage/html/index.html"
    ;;

  *)
    echo "📖 Usage: $0 coverage[:measure|:print|:validate <threshold>|:generate|:open]"
    exit 1
    ;;
esac
