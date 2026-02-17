import SwiftUI
import PhotosUI
import Combine

/// 壁紙設定画面 — プリセット / カラー / 写真 の3タブ切替
struct WallpaperSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @ObservedObject var wallpaperManager: WallpaperManager

    @State private var selectedTab: WallpaperType = .preset
    @State private var solidColor: Color = Color(red: 0.15, green: 0.15, blue: 0.2)
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var currentDate = Date()
    @State private var loadedImage: UIImage?
    @State private var showCropView = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            // 実際の時計でプレビュー
            clockPreview

            Picker("種類", selection: $selectedTab) {
                ForEach(WallpaperType.allCases) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            ScrollView {
                switch selectedTab {
                case .preset:
                    presetGrid
                case .solidColor:
                    colorPickerSection
                case .userPhoto:
                    photoPickerSection
                }
            }
        }
        .navigationTitle("壁紙")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { syncColorFromConfig() }
        .onReceive(timer) { currentDate = $0 }
        .onChange(of: selectedPhotoItem) { _, newItem in
            loadPhoto(from: newItem)
        }
        .fullScreenCover(isPresented: $showCropView) {
            if let loadedImage {
                ImageCropView(image: loadedImage, onCrop: { croppedImage in
                    wallpaperManager.applyUserPhoto(croppedImage)
                    showCropView = false
                    self.loadedImage = nil
                }, onCancel: {
                    showCropView = false
                    self.loadedImage = nil
                })
            }
        }
    }

    // MARK: - 時計プレビュー（実際の見た目）

    private var clockPreview: some View {
        AnalogClockView(
            date: currentDate,
            settings: settingsManager.settings,
            size: CGSize(width: 180, height: 180),
            showSecondHand: false
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    // MARK: - プリセットグリッド

    private var presetGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(PresetWallpaper.allCases) { preset in
                presetCell(preset)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }

    private func presetCell(_ preset: PresetWallpaper) -> some View {
        let isSelected = wallpaperManager.currentConfig.type == .preset
            && wallpaperManager.currentConfig.presetId == preset.rawValue

        return Button {
            wallpaperManager.applyPreset(preset)
        } label: {
            VStack(spacing: 4) {
                preset.makeView()
                    .frame(height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                    )

                Text(preset.displayName)
                    .font(.caption2)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - カラーピッカー

    private var colorPickerSection: some View {
        VStack(spacing: 20) {
            ColorPicker("背景色", selection: $solidColor, supportsOpacity: false)
                .padding(.horizontal)

            Button("この色を適用") {
                wallpaperManager.applySolidColor(solidColor)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top)
    }

    // MARK: - 写真選択

    private var photoPickerSection: some View {
        VStack(spacing: 20) {
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("写真を選ぶ", systemImage: "photo.on.rectangle")
            }
            .buttonStyle(.borderedProminent)

            if wallpaperManager.currentConfig.type == .userPhoto {
                Text("写真が設定されています")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("写真を解除") {
                    wallpaperManager.applyPreset(.marble)
                }
                .font(.caption)
                .foregroundStyle(.red)
            }
        }
        .padding(.top)
    }

    // MARK: - ヘルパー

    private func syncColorFromConfig() {
        if let codableColor = wallpaperManager.currentConfig.solidColor {
            solidColor = codableColor.color
        }
        selectedTab = wallpaperManager.currentConfig.type
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
