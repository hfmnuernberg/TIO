default: gen lint

gen:
    flutter pub get
    flutter_rust_bridge_codegen \
        --rust-input native/src/api.rs \
        --dart-output lib/rust_api/generated/bridge_generated.dart \
        --c-output ios/Runner/bridge_generated.h \
        --dart-decl-output lib/rust_api/generated/bridge_definitions.dart \
        --wasm
    cp ios/Runner/bridge_generated.h macos/Runner/bridge_generated.h

lint:
    cd native && cargo fmt
    dart format .

clean:
    flutter clean
    cd native && cargo clean
    
serve *args='':
    flutter pub run flutter_rust_bridge:serve {{args}}

# vim:expandtab:sw=4:ts=4
