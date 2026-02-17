import SwiftUI
import WidgetKit
import PhotosUI
import Combine

/// メイン画面 — テーマ・壁紙スケジュール・カラー・オプションを1ページに統合
struct HomeView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var currentDate = Date()
    @State private var editingHour: Int?
    @State private var showResetConfirmation = false
    @State private var copiedWallpaper: WallpaperConfig?
    @State private var showOnboarding = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var currentHour: Int {
        Calendar.current.component(.hour, from: currentDate)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    clockPreview
                    styleSection
                    wallpaperScheduleSection
                    colorSection
                    optionsSection
                    widgetGuide
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(Color.black)
            .navigationTitle("Sync Clock")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onReceive(timer) { currentDate = $0 }
        .sheet(item: $editingHour) { hour in
            HourlyWallpaperEditView(initialHour: hour)
                .environmentObject(settingsManager)
        }
        .onAppear {
            if settingsManager.isFirstLaunch {
                showOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                showOnboarding = false
                settingsManager.markAsLaunched()
                // 最初の時間の壁紙編集を開く
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    editingHour = currentHour
                }
            } onSkip: {
                showOnboarding = false
                settingsManager.markAsLaunched()
            }
        }
        .alert("設定をリセット", isPresented: $showResetConfirmation) {
            Button("キャンセル", role: .cancel) {}
            Button("リセット", role: .destructive) { resetSettings() }
        } message: {
            Text("すべての設定を初期状態に戻します。")
        }
    }

    // MARK: - ライブプレビュー

    private var clockPreview: some View {
        AnalogClockView(
            date: currentDate,
            settings: settingsManager.settings,
            size: CGSize(width: 200, height: 200),
            showSecondHand: settingsManager.settings.showSecondHand
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .white.opacity(0.08), radius: 16)
        .padding(.top, 8)
    }

    // MARK: - スタイル

    private var styleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("スタイル")

            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(ClockFaceStyle.allCases) { style in
                    styleCard(style)
                }
            }
        }
    }

    private func styleCard(_ style: ClockFaceStyle) -> some View {
        let isSelected = settingsManager.settings.faceStyle == style
        var previewSettings = settingsManager.settings
        previewSettings.faceStyle = style

        return Button {
            withAnimation(.easeInOut(duration: 0.35)) {
                settingsManager.settings.faceStyle = style
            }
            WidgetCenter.shared.reloadAllTimelines()
        } label: {
            VStack(spacing: 6) {
                AnalogClockView(
                    date: currentDate,
                    settings: previewSettings,
                    size: CGSize(width: 80, height: 80),
                    showSecondHand: false
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.white.opacity(0.12),
                                lineWidth: isSelected ? 2.5 : 1)
                )

                Text(style.displayName)
                    .font(.caption2)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? .blue : .white.opacity(0.6))
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - 壁紙スケジュール

    private var wallpaperScheduleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                sectionHeader("壁紙スケジュール")
                Spacer()
                Button("すべてリセット") { resetAllWallpapers() }
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            timePeriodRow(title: "深夜", icon: "moon.stars.fill", hours: Array(0...5))
            timePeriodRow(title: "朝",   icon: "sunrise.fill",    hours: Array(6...11))
            timePeriodRow(title: "昼",   icon: "sun.max.fill",    hours: Array(12...17))
            timePeriodRow(title: "夜",   icon: "moon.fill",       hours: Array(18...23))
        }
    }

    private func timePeriodRow(title: String, icon: String, hours: [Int]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 時間帯ヘッダー
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.4))
            }

            // セル行（6列）
            HStack(spacing: 6) {
                ForEach(hours, id: \.self) { hour in
                    wallpaperCell(hour: hour)
                }
            }
        }
    }

    private func wallpaperCell(hour: Int) -> some View {
        let config = settingsManager.settings.wallpaper(forHour: hour)
        let isCurrent = hour == currentHour

        return Button {
            editingHour = hour
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    WallpaperBackgroundView(config: config)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    // 写真アイコン
                    if config.type == .userPhoto {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 7))
                                    .foregroundStyle(.white)
                                    .padding(3)
                                    .background(.black.opacity(0.5), in: Circle())
                            }
                        }
                        .padding(3)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isCurrent ? Color.blue : Color.white.opacity(0.1),
                                lineWidth: isCurrent ? 2 : 0.5)
                )
                .shadow(color: isCurrent ? .blue.opacity(0.3) : .clear, radius: 4)

                Text("\(hour)")
                    .font(.system(size: 10, weight: isCurrent ? .bold : .regular,
                                  design: .monospaced))
                    .foregroundStyle(isCurrent ? .blue : .white.opacity(0.45))
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            // コピー
            Button {
                copiedWallpaper = config
            } label: {
                Label("壁紙をコピー", systemImage: "doc.on.doc")
            }

            // ペースト
            if let copied = copiedWallpaper {
                Button {
                    pasteWallpaper(copied, toHour: hour)
                } label: {
                    Label("壁紙をペースト", systemImage: "doc.on.clipboard")
                }
            }

            Divider()

            // デフォルトに戻す
            Button(role: .destructive) {
                resetWallpaper(forHour: hour)
            } label: {
                Label("デフォルトに戻す", systemImage: "arrow.counterclockwise")
            }
        }
    }

    // MARK: - カラー

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("カラー")

            VStack(spacing: 0) {
                colorRow("時針", keyPath: \.hourHandColor)
                Divider().background(Color.white.opacity(0.1))
                colorRow("分針", keyPath: \.minuteHandColor)
                Divider().background(Color.white.opacity(0.1))
                colorRow("秒針", keyPath: \.secondHandColor)
                Divider().background(Color.white.opacity(0.1))
                colorRow("目盛り", keyPath: \.indexColor)
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.06))
            )
        }
    }

    private func colorRow(_ label: String, keyPath: WritableKeyPath<ClockSettings, CodableColor>) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white)

            Spacer()

            ColorPicker("", selection: colorBinding(keyPath), supportsOpacity: false)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func colorBinding(_ keyPath: WritableKeyPath<ClockSettings, CodableColor>) -> Binding<Color> {
        Binding<Color>(
            get: { settingsManager.settings[keyPath: keyPath].color },
            set: { newColor in
                settingsManager.settings[keyPath: keyPath] = CodableColor(newColor)
                WidgetCenter.shared.reloadAllTimelines()
            }
        )
    }

    // MARK: - オプション

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("オプション")

            VStack(spacing: 0) {
                toggleRow("数字を表示", binding: Binding(
                    get: { settingsManager.settings.showNumbers },
                    set: { newValue in
                        settingsManager.settings.showNumbers = newValue
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                ))
                Divider().background(Color.white.opacity(0.1))
                toggleRow("秒針を表示", binding: Binding(
                    get: { settingsManager.settings.showSecondHand },
                    set: { newValue in
                        settingsManager.settings.showSecondHand = newValue
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                ))
                Divider().background(Color.white.opacity(0.1))
                resetRow
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.06))
            )
        }
    }

    private func toggleRow(_ label: String, binding: Binding<Bool>) -> some View {
        Toggle(label, isOn: binding)
            .tint(.blue)
            .font(.subheadline)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
    }

    private var resetRow: some View {
        Button {
            showResetConfirmation = true
        } label: {
            HStack {
                Text("初期設定に戻す")
                    .font(.subheadline)
                Spacer()
                Image(systemName: "arrow.counterclockwise")
                    .font(.caption)
            }
            .foregroundStyle(.red)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    // MARK: - ウィジェットガイド

    private var widgetGuide: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.square.dashed")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.25))

            Text("ホーム画面を長押しして「＋」をタップすると\nウィジェットを追加できます")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.25))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.top, 12)
        .padding(.bottom, 20)
    }

    // MARK: - ヘルパー

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.white)
    }

    // MARK: - 壁紙操作

    private func pasteWallpaper(_ config: WallpaperConfig, toHour hour: Int) {
        cleanupOldPhoto(forHour: hour)
        withAnimation(.easeInOut(duration: 0.3)) {
            settingsManager.settings.setWallpaper(config, forHour: hour)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func resetWallpaper(forHour hour: Int) {
        cleanupOldPhoto(forHour: hour)
        let defaultWallpaper = WallpaperConfig(type: .userPhoto)
        withAnimation(.easeInOut(duration: 0.3)) {
            settingsManager.settings.setWallpaper(defaultWallpaper, forHour: hour)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func resetAllWallpapers() {
        let defaultWallpaper = WallpaperConfig(type: .userPhoto)
        withAnimation(.easeInOut(duration: 0.3)) {
            settingsManager.settings.hourlyWallpapers = Array(repeating: defaultWallpaper, count: 24)
        }
        ImageStorage.deleteImagesExcept(settingsManager.settings.allPhotoFileNames)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func resetSettings() {
        withAnimation(.easeInOut) {
            settingsManager.resetToDefaults()
        }
        WidgetCenter.shared.reloadAllTimelines()
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
}

// MARK: - Int: Identifiable (for sheet binding)

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}
