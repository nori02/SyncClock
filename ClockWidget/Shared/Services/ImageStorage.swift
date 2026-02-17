import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ImageStorage {
    private static let appGroupID = SettingsManager.appGroupID
    private static let imageDirectoryName = "wallpapers"
    private static let maxWidgetDimension: CGFloat = 400
    private static let jpegQuality: CGFloat = 0.7

    private static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    private static var imageDirectoryURL: URL? {
        guard let container = containerURL else { return nil }
        let url = container.appendingPathComponent(imageDirectoryName, isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    @discardableResult
    static func saveImage(_ image: UIImage, fileName: String? = nil) -> String? {
        guard let directoryURL = imageDirectoryURL else { return nil }
        let name = fileName ?? UUID().uuidString + ".jpg"
        let fileURL = directoryURL.appendingPathComponent(name)
        let resized = resizeForWidget(image)
        guard let data = resized.jpegData(compressionQuality: jpegQuality) else { return nil }
        do { try data.write(to: fileURL, options: .atomic); return name }
        catch { return nil }
    }

    static func loadImage(named fileName: String) -> UIImage? {
        guard let directoryURL = imageDirectoryURL else { return nil }
        let fileURL = directoryURL.appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }

    static func deleteImage(named fileName: String) -> Bool {
        guard let directoryURL = imageDirectoryURL else { return false }
        let fileURL = directoryURL.appendingPathComponent(fileName)
        do { try FileManager.default.removeItem(at: fileURL); return true }
        catch { return false }
    }

    static func deleteImagesExcept(_ keepFileNames: Set<String>) {
        guard let directoryURL = imageDirectoryURL else { return }
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: directoryURL.path)
            for file in files where !keepFileNames.contains(file) {
                let fileURL = directoryURL.appendingPathComponent(file)
                try? FileManager.default.removeItem(at: fileURL)
            }
        } catch { }
    }

    static func deleteAllImages() {
        guard let directoryURL = imageDirectoryURL else { return }
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: directoryURL.path)
            for file in files {
                let fileURL = directoryURL.appendingPathComponent(file)
                try? FileManager.default.removeItem(at: fileURL)
            }
        } catch { }
    }

    private static func resizeForWidget(_ image: UIImage) -> UIImage {
        let size = image.size
        let maxDim = max(size.width, size.height)
        guard maxDim > maxWidgetDimension else { return image }
        let ratio = maxWidgetDimension / maxDim
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
    }
}
