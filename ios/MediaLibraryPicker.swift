import Flutter
import MediaPlayer
import AVFoundation

class MediaLibraryPicker: NSObject, MPMediaPickerControllerDelegate {
    private var result: FlutterResult?

    func pick(allowMultiple: Bool, result: @escaping FlutterResult) {
        self.result = result

        let picker = MPMediaPickerController(mediaTypes: .anyAudio)
        picker.delegate = self
        picker.allowsPickingMultipleItems = allowMultiple
        picker.showsCloudItems = true
        picker.showsItemsWithProtectedAssets = false

        guard let viewController = topViewController() else {
            result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Unable to present picker", details: nil))
            self.result = nil
            return
        }

        viewController.present(picker, animated: true)
    }

    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true)

        let items = mediaItemCollection.items
        if items.isEmpty {
            result?(nil)
            result = nil
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var paths: [String] = []
            var skippedCount = 0

            for item in items {
                guard let assetURL = item.assetURL else {
                    skippedCount += 1
                    continue
                }

                if let exportedPath = self?.exportAsset(url: assetURL, name: item.title ?? "audio") {
                    paths.append(exportedPath)
                } else {
                    skippedCount += 1
                }
            }

            DispatchQueue.main.async {
                self?.result?(["paths": paths, "skippedCount": skippedCount])
                self?.result = nil
            }
        }
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true)
        result?(nil)
        result = nil
    }

    private func exportAsset(url: URL, name: String) -> String? {
        let sanitizedName = name.replacingOccurrences(of: "/", with: "_")
        let outputPath = NSTemporaryDirectory() + "\(sanitizedName)_\(Int(Date().timeIntervalSince1970)).m4a"
        let outputURL = URL(fileURLWithPath: outputPath)

        let asset = AVURLAsset(url: url)

        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            return nil
        }

        exporter.outputFileType = .m4a
        exporter.outputURL = outputURL

        let semaphore = DispatchSemaphore(value: 0)
        var exportedPath: String?

        exporter.exportAsynchronously {
            if exporter.status == .completed {
                exportedPath = outputPath
            }
            semaphore.signal()
        }

        semaphore.wait()
        return exportedPath
    }

    private func topViewController() -> UIViewController? {
        var topController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController

        while let presented = topController?.presentedViewController {
            topController = presented
        }

        return topController
    }
}
