import SwiftUI
import PhotosUI
import WidgetKit

/// 時間別壁紙の編集シート — プリセット・カラー・写真を自由に設定
struct HourlyWallpaperEditView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) private var dismiss

    let initialHour: Int

    @State private var selectedTab: WallpaperType = .preset
    @State private var solidColor: Color = Color(red: 0.15, green: 0.15, blue: 0.2)
    @State private var applyScope: ApplyScope = .thisHour
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var loadedImage: UIImage?
    @State private var showCropView = false

    // MARK: - Apply Scope

    enum ApplyScope: Hashable {
        case thisHour
        case night      // 0–5
        case morning    // 6–11
        case afternoon  // 12–17
        case evening    // 18–23
        case allHours

        var displayName: String {
            switch self {
            case .thisHour:  return "この時間"
            case .night:     return "深夜 (0–5)"
            case .morning:   return "朝 (6–11)"
            case .afternoon: return "昼 (12–17)"
            case .evening:   return "夜 (18–23)"
            case .allHours:  return "全時間"
            }
        }

        var hours: [Int] {
            switch self {
            case .thisHour:  return [] // 呼び出し元で initialHour を使う
            case .night:     return Array(0...5)
            case .morning:   return Array(6...11)
            case .afternoon: return Array(12...17)
            case .evening:   return Array(18...23)
            case .allHours:  return Array(0...23)
            }
        }

        static var allScopes: [ApplyScope] {
            [.thisHour, .night, .morning, .afternoon, .evening, .allHours]
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 現在の壁紙プレビュー
                    previewSection

                    // 適用範囲
                    scopeSection

                    // 種類切替
                    Picker("種類", selection: $selectedTab) {
                        ForEach(WallpaperType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // コンテンツ
                    switch selectedTab {
                    case .preset:    presetGrid
                    case .solidColor: colorPickerSection
                    case .userPhoto:  photoPickerSection
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color.black)
            .navigationTitle("\(initialHour):00 の壁紙")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") { dismiss() }
                }
            }
        }
        .onAppear { syncState() }
        .onChange(of: selectedPhotoItem) { _, newItem in
            loadPhoto(from: newItem)
        }
        .fullScreenCover(isPresented: $showCropView) {
            if let loadedImage {
                ImageCropView(image: loadedImage, onCrop: { croppedImage in
                    applyPhoto(croppedImage)
                    showCropView = false
                    self.loadedImage = nil
                }, onCancel: {
                    showCropView = false
                    self.loadedImage = nil
                })
            }
        }
    }

    // MARK: - Preview

    private var previewSection: some View {
        let config = settingsManager.settings.wallpaper(forHour: initialHour)
        return WallpaperBackgroundView(config: config)
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.top, 8)
    }

    // MARK: - Scope

    private var scopeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("適用範囲")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ApplyScope.allScopes, id: \.self) { scope in
                        scopeChip(scope)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func scopeChip(_ scope: ApplyScope) -> some View {
        let isSelected = applyScope == scope
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                applyScope = scope
            }
        } label: {
            Text(scope.displayName)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color.white.opacity(0.08))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Preset Grid

    private var presetGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(PresetWallpaper.allCases) { preset in
                presetCell(preset)
            }
        }
        .padding(.horizontal)
    }

    private func presetCell(_ preset: PresetWallpaper) -> some View {
        let currentConfig = settingsManager.settings.wallpaper(forHour: initialHour)
        let isSelected = currentConfig.type == .preset
            && currentConfig.presetId == preset.rawValue

        return Button {
            let config = WallpaperConfig(type: .preset, presetId: preset.rawValue)
            applyWallpaper(config)
        } label: {
            VStack(spacing: 4) {
                preset.makeView()
                    .frame(height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.blue : Color.white.opacity(0.12),
                                    lineWidth: isSelected ? 2.5 : 1)
                    )

                Text(preset.displayName)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .blue : .white.opacity(0.6))
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Color Picker

    private var colorPickerSection: some View {
        VStack(spacing: 16) {
            ColorPicker("背景色", selection: $solidColor, supportsOpacity: false)
                .foregroundStyle(.white)
                .padding(.horizontal)

            Button {
                let config = WallpaperConfig(
                    type: .solidColor,
                    solidColor: CodableColor(solidColor)
                )
                applyWallpaper(config)
            } label: {
                Text("この色を適用")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
        .padding(.top, 8)
    }

    // MARK: - Photo Picker

    private var photoPickerSection: some View {
        VStack(spacing: 16) {
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.title3)
                    Text("写真を選ぶ")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

            let currentConfig = settingsManager.settings.wallpaper(forHour: initialHour)
            if currentConfig.type == .userPhoto {
                Text("写真が設定されています")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Apply Logic

    private func targetHours() -> [Int] {
        if applyScope == .thisHour {
            return [initialHour]
        }
        return applyScope.hours
    }

    private func applyWallpaper(_ config: WallpaperConfig) {
        let hours = targetHours()
        withAnimation(.easeInOut(duration: 0.3)) {
            for hour in hours {
                // 古い写真クリーンアップ
                cleanupOldPhoto(forHour: hour)
                settingsManager.settings.setWallpaper(config, forHour: hour)
            }
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func applyPhoto(_ image: UIImage) {
        guard let fileName = ImageStorage.saveImage(image) else { return }
        let config = WallpaperConfig(type: .userPhoto, photoFileName: fileName)
        applyWallpaper(config)
    }

    private func cleanupOldPhoto(forHour hour: Int) {
        let oldConfig = settingsManager.settings.wallpaper(forHour: hour)
        guard let oldFileName = oldConfig.photoFileName else { return }
        var usedFiles = settingsManager.settings.allPhotoFileNames
        usedFiles.remove(oldFileName)
        if !usedFiles.contains(oldFileName) {
            ImageStorage.deleteImage(named: oldFileName)
        }
    }

    // MARK: - Helpers

    private func syncState() {
        let config = settingsManager.settings.wallpaper(forHour: initialHour)
        selectedTab = config.type
        if let codableColor = config.solidColor {
            solidColor = codableColor.color
        }
    }

    private func loadPhoto(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }
            loadedImage = uiImage
            showCropView = true
            selectedPhotoItem = nil
        }
    }
}
