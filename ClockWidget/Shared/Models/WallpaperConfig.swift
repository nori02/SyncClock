import Foundation

enum WallpaperType: String, Codable, CaseIterable, Identifiable {
    case userPhoto
    case preset
    case solidColor

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .userPhoto:  return "写真"
        case .preset:     return "プリセット"
        case .solidColor: return "単色"
        }
    }
}

struct WallpaperConfig: Codable, Equatable {
    var type: WallpaperType
    var presetId: String?
    var solidColor: CodableColor?
    var photoFileName: String?

    static var `default`: WallpaperConfig {
        WallpaperConfig(type: .userPhoto)
    }
}
