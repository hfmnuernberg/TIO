# Update FRB (flutter-rust-bridge)


The installed version of `flutter-rust-bridge-codegen` must match the version of the flutter_rust_bridge dependency in
`Cargo.toml` and `pubspec.yaml`.

## How to update

1. Check for new versions of `flutter-rust-bridge` and related crates.

Check [frb releases](https://github.com/fzyzcjy/flutter_rust_bridge/releases).

In the rust folder, run:

```shell
cargo search flutter-rust-bridge
```

All listed flutter_rust_bridge dependencies should be on the same version.
- flutter_rust_bridge
- flutter_rust_bridge_codegen
- flutter_rust_bridge_macros
- ...


2. In the rust folder, open `Cargo.toml` and update the version of `flutter_rust_bridge` to the latest version.

```toml
[dependencies]
flutter_rust_bridge = "=X.X.X"
```

_Note: The leading = is valid Cargo syntax for “exact version”. This is recommended to avoid unexpected breaking changes._


3. In the root folder, open `pubspec.yaml` and update the version of `flutter_rust_bridge` to the latest version.

```yaml
dependencies:
  flutter_rust_bridge: X.X.X
```


4. In rust folder, open the terminal and install the `flutter_rust_bridge_codegen` version.

```shell
cargo install flutter_rust_bridge_codegen --version <VERSION> --force
```


5. In the root folder, open the terminal and regenerate bindings (the bridge code).

```shell
flutter_rust_bridge_codegen generate --no-dart-enums-style
```


4. Clean & rebuild

In the root folder, run:

```shell
flutter clean
app install
cargo +1.85.0 update
app generate:rust
app run ios
```


## Troubleshooting

Common pitfalls:
- “Cannot parse array length” INFO logs during codegen: These are non-fatal info messages. If a specific Rust type with
  const array lengths is actually used across FFI, prefer Vec<T> in the FFI-signature-facing structs.
- Lifetimes: If you hit lifetime-related parser messages, and you do pass references over FFI, consider FRB’s
  `enable_lifetime: true` config (or redesign FFI to use owned types like String, Vec<T>, etc.).
- Multiple objects with the same key (THREAD, THREAD_SENDER) info logs: Benign unless those symbols are exported in your
  FFI surface. If they are, rename one or don’t expose both. 
