#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUST_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
cd "$RUST_DIR"

# `#[flutter_rust_bridge::frb(...)]` is an attribute proc macro. It rebuilds every token group of the
# item it annotates (see convert_frb_attr_to_encoded_form in flutter_rust_bridge_macros), which gives
# the function body a synthetic span. Coverage instrumentation needs real source spans, so annotated
# functions are dropped from the coverage map entirely - they do not even show up as uncovered.
# Measuring on a throwaway copy with those attributes stripped keeps the committed sources untouched
# while still reporting the truth. The attributes are no-ops for compilation.
# The copy lives outside the repo so it cannot be picked up by repo-wide checks (analyze:files scans
# *.sh and would otherwise count the copied scripts), while build artifacts stay under rust/target so
# CI caching still applies.
COVERAGE_SRC="${TMPDIR:-/tmp}/tio-rust-coverage-src"
export CARGO_TARGET_DIR="$RUST_DIR/target/coverage"

IGNORE_REGEX='(frb_generated\.rs|src/api/test/|src/api/ffi\.rs|build\.rs)'

# BSD awk (macOS) does not support \s, so match POSIX character classes instead
CHANNEL="$(awk -F\" '/^[[:space:]]*rust-version[[:space:]]*=/ {print $2; exit}' Cargo.toml)"
if [ -z "$CHANNEL" ]; then
  CHANNEL="$(awk -F\" '/^[[:space:]]*channel[[:space:]]*=/ {print $2; exit}' "$RUST_DIR/../rust-toolchain.toml")"
fi

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

prepare_source_copy() {
  rm -rf "$COVERAGE_SRC"
  mkdir -p "$COVERAGE_SRC"
  rsync -a --exclude '/target' --exclude '/coverage' "$RUST_DIR/" "$COVERAGE_SRC/"
  find "$COVERAGE_SRC/src" -name '*.rs' -exec \
    sed -i.bak -E '/^[[:space:]]*#\[(flutter_rust_bridge::)?frb\(.*\)\][[:space:]]*$/d' {} +
  find "$COVERAGE_SRC/src" -name '*.rs.bak' -delete

  # Stripping the attributes can leave imports unused, and CI builds with RUSTFLAGS=-D warnings.
  # Linting the real sources is clippy's job; this copy only has to compile and run.
  printf '#![allow(warnings)]\n%s\n' "$(cat "$COVERAGE_SRC/src/lib.rs")" > "$COVERAGE_SRC/src/lib.rs"
}

assert_measured() {
  if [ ! -d "$COVERAGE_SRC" ]; then
    echo "❌  No coverage data. Run 'scripts/app.sh rust coverage:measure' first." >&2
    exit 2
  fi
}

report() {
  assert_measured
  ( cd "$COVERAGE_SRC" && cargo +"$CHANNEL" llvm-cov report --ignore-filename-regex "$IGNORE_REGEX" "$@" )
}

case "${1:-help}" in
  coverage)
    bash "$0" coverage:measure
    bash "$0" coverage:generate
    bash "$0" coverage:open
    ;;

  coverage:measure)
    ensure_llvm_cov
    prepare_source_copy
    print_header "cargo +$CHANNEL llvm-cov --no-report --workspace (on instrumentable source copy)"
    ( cd "$COVERAGE_SRC" && cargo +"$CHANNEL" llvm-cov --no-report --workspace )
    mkdir -p coverage
    report --lcov --output-path "$RUST_DIR/coverage/lcov.info"
    # Point the report back at the committed sources instead of the throwaway copy
    sed -i.bak "s|$COVERAGE_SRC|$RUST_DIR|g" "$RUST_DIR/coverage/lcov.info"
    rm -f "$RUST_DIR/coverage/lcov.info.bak"
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
