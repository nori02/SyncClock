import SwiftUI

/// WallpaperConfig に基づいて壁紙を描画する共通ビュー
/// ウィジェットとメインアプリの両方で使用
struct WallpaperBackgroundView: View {
    let config: WallpaperConfig

    var body: some View {
        Group {
            switch config.type {
            case .preset:
                presetView

            case .solidColor:
                solidColorView

            case .userPhoto:
                userPhotoView
            }
        }
    }

    // MARK: - Preset

    @ViewBuilder
    private var presetView: some View {
        if let presetId = config.presetId,
           let preset = PresetWallpaper(rawValue: presetId) {
            preset.makeView()
        } else {
            // フォールバック: デフォルトの暗色
            Color(red: 0.15, green: 0.15, blue: 0.2)
        }
    }

    // MARK: - Solid Color

    @ViewBuilder
    private var solidColorView: some View {
        if let codableColor = config.solidColor {
            codableColor.color
        } else {
            Color(red: 0.15, green: 0.15, blue: 0.2)
        }
    }

    // MARK: - User Photo

    @ViewBuilder
    private var userPhotoView: some View {
        if let fileName = config.photoFileName,
           let uiImage = ImageStorage.loadImage(named: fileName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            // 画像がない場合のフォールバック
            Color(red: 0.15, green: 0.15, blue: 0.2)
        }
    }
}
