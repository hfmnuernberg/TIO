import UIKit
import Flutter
import AVFAudio

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    print("dummy_value=\(dummy_method_to_enforce_bundling())");
      
    #if os(iOS)
    _ = AVAudioSession.sharedInstance();
    #endif
    
    GeneratedPluginRegistrant.register(with: self);

    return super.application(application, didFinishLaunchingWithOptions: launchOptions);
  }
}
