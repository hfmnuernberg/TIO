# Troubleshooting

### Install or update error: "You don't have write permissions for the /usr/bin directory."

If you're facing the following error on macOS when installing or updating CocoaPods:

```
ERROR:  While executing gem ... (Gem::FilePermissionError)
    You don't have write permissions for the /usr/bin directory.
```

Try executing the following command instead:

```shell
sudo gem install cocoapods -n/usr/local/bin
```

### Install or update error: "activesupport"

If an error message suggests to install `activesupport`, do so and try installing CocoaPods again.

### Failed to run custom build command for coreaudio-sys

When facing this error after upgrading the iOS simulators:

```
Xcode build done.                                           79.3s
Failed to build iOS app
Error (Xcode): failed to run custom build command for coreaudio-sys v0.2.16
/Users/davidbieder/repos/hfm/TIO/ios/Pods/SEVERE:0:0

Could not build the application for the simulator.
Error launching application on iPhone 16.
```

Try this workaround:

```shell
export BINDGEN_EXTRA_CLANG_ARGS="--target=arm64-apple-ios18.4-simulator"
```

### Failed to build iOS app

```
Xcode build done.  
Error (Xcode): rustc 1.88.0 is not supported by the following packages:
/Users/mauricereichelt/repos/tio-music/TIO/ios/Pods/SEVERE:0:0

Could not build the application for the simulator.
Error launching application on iPhone 16.
```

Check if the installed version of rust toolchain is used as default. ([update-rust.md](./update-rust.md/#7-install--use-that-toolchain))
