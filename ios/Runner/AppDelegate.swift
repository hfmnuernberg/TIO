import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let mediaLibraryPicker = MediaLibraryPicker()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let registrar = self.registrar(forPlugin: "MediaLibraryPicker")!
    let channel = FlutterMethodChannel(name: "tio/media_library_picker", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { [weak self] (call, result) in
      guard call.method == "pickAudio" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let args = call.arguments as? [String: Any]
      let allowMultiple = args?["allowMultiple"] as? Bool ?? false
      self?.mediaLibraryPicker.pick(allowMultiple: allowMultiple, result: result)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
