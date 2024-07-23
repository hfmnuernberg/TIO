#!/usr/bin/env python3

import argparse
import os


parser = argparse.ArgumentParser(
    prog=f"generate.py",
    description="This is a helper-script to generate e.g. rust bindings, splash files or icon files.",
)
parser.add_argument("type", choices=["all", "rust", "splash", "icon", "json"])


def generate_rust():
    call_os(
        "flutter_rust_bridge_codegen --rust-input native/src/api.rs --dart-output ./lib/rust_api/generated/bridge_generated.dart --dart-decl-output ./lib/rust_api/generated/bridge_definitions.dart"
    )


def generate_splash():
    call_os(
        "flutter pub run flutter_native_splash:create --path=flutter_native_splash.yaml"
    )


def generate_icon():
    call_os("flutter pub run flutter_launcher_icons -f flutter_launcher_icons.yaml")


def generate_json():
    call_os("dart run build_runner build -d")


def call_os(command):
    return_value = os.system(command)
    if return_value != 0:
        print("\nERROR: something went wrong!")
        exit(1)


args = parser.parse_args()
if args.type == "all":
    generate_rust()
    generate_splash()
    generate_icon()
    generate_json()
elif args.type == "rust":
    generate_rust()
elif args.type == "splash":
    generate_splash()
elif args.type == "icon":
    generate_icon()
elif args.type == "json":
    generate_json()
else:
    print(f"unknown value: {args.command}")
