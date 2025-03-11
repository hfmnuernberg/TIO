# Upgrade iOS & Android SDKs

## Android

1. Identify the newest Android SDK/API version/level by checking the [endoflife.date](https://endoflife.date/android) page and the [Android API Levels](https://apilevels.com/) page
2. Change the `compileSdkVersion` and `targetSdkVersion` in the [build.gradle](../android/app/build.gradle) file to the newest version
3. Change the `minSdkVersion` in the [build.gradle](../android/app/build.gradle) file to the last version still receiving security updates
4. Completely rebuild the app
5. Upgrade dependencies if possible (or necessary)
6. Adjust code if necessary
7. Thoroughly test the app in different emulators and on physical devices
8. Push and merge changes to the `main` branch
9. Verify that the bundles are build and uploaded to the app store successfully
10. Thoroughly test the staging app on physical devices

## iOS

1. Identify the newest iOS SDK version by checking the [endoflife.date](https://endoflife.date/ios) page
2. Change the `platform :ios, 'XX.0'` in the [Podfile](../ios/Podfile) to the last version still receiving security updates
3. Update Flutter’s engine info [plist](../ios/Flutter/AppFrameworkInfo.plist) and set `MinimumOSVersion` to `18.0`
4. Update the specific Xcode version in the GitHub Action [build job for iOS](../.github/workflows/reusable-build-ios-app.yaml), e.g. `xcode-version: 16.2.0`
5. If necessary also update the iOS Simulator version in the GitHub Action [build job for iOS](../.github/workflows/reusable-build-ios-app.yaml), e.g. `iOS 18.2 Simulator`
6. Change the `IPHONEOS_DEPLOYMENT_TARGET` in the different `ios/**/*.pbxproj` files to the same version 
7. Completely rebuild the app
8. Upgrade dependencies if possible (or necessary)
9. Adjust code if necessary
10. Thoroughly test the app in different emulators and on physical devices
11. Push and merge changes to the `main` branch
12. Verify that the bundles are build and uploaded to the app store successfully
13. Thoroughly test the staging app on physical devices
