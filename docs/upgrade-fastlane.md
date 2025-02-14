# Upgrade Fastlane

1. Identify the newest fastlane version by checking the [fastlane releases](https://github.com/fastlane/fastlane/releases) page
2. Update the Fastlane version in the [Android](../android/Gemfile) and [iOS](../ios/Gemfile) `Gemfiles`
3. Update the `Gemfile.lock` files in the `android` and `ios` directories:
   ```shell
   cd android
   bundle update fastlane
   cd ..
   
   cd ios
   bundle update fastlane
   cd ..
   ```
4. Push and merge your changes to the main branch
5. Verify that the bundles are build and uploaded to the app stores successfully