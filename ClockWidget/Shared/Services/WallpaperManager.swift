import SwiftUI
import UIKit
import WidgetKit
import Combine

@MainActor
final class WallpaperManager: ObservableObject {
    private let settingsManager: SettingsManager

    init(settingsManager: SettingsManager) { self.settingsManager = settingsManager }

    var currentConfig: WallpaperConfig { settingsManager.settings.wallpaper }

    func applyPreset(_ preset: PresetWallpaper) {
        var wallpaper = WallpaperConfig(type: .preset, presetId: preset.rawValue)
        wallpaper.solidColor = nil; wallpaper.photoFileName = nil
        settingsManager.settings.wallpaper = wallpaper
        reloadWidgets()
    }

    func applySolidColor(_ color: Color) {
        var wallpaper = WallpaperConfig(type: .solidColor, solidColor: CodableColor(color))
        wallpaper.presetId = nil; wallpaper.photoFileName = nil
        settingsManager.settings.wallpaper = wallpaper
        reloadWidgets()
    }

    func applyUserPhoto(_ image: UIImage) {
        if let oldFileName = currentConfig.photoFileName {
            var usedFiles = settingsManager.settings.allPhotoFileNames
            usedFiles.remove(oldFileName)
            if !usedFiles.contains(oldFileName) { ImageStorage.deleteImage(named: oldFileName) }
        }
        guard let fileName = ImageStorage.saveImage(image) else { return }
        var wallpaper = WallpaperConfig(type: .userPhoto, photoFileName: fileName)
        wallpaper.presetId = nil; wallpaper.solidColor = nil
        settingsManager.settings.wallpaper = wallpaper
        reloadWidgets()
    }

    private func reloadWidgets() { WidgetCenter.shared.reloadAllTimelines() }
}
