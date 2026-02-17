import SwiftUI
import WidgetKit
import Combine

/// 文字盤選択画面 — グリッドでスタイルをプレビュー・選択
struct FaceSelectionView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var currentDate = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                selectedPreview
                styleGrid
            }
            .padding()
        }
        .navigationTitle("文字盤スタイル")
        .onReceive(timer) { date in
            currentDate = date
        }
    }

    // MARK: - 選択中プレビュー

    private var selectedPreview: some View {
        VStack(spacing: 12) {
            AnalogClockView(
                date: currentDate,
                settings: settingsManager.settings,
                size: CGSize(width: 200, height: 200),
                showSecondHand: true
            )

            Text(settingsManager.settings.faceStyle.displayName)
                .font(.headline)

            Text(settingsManager.settings.faceStyle.description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - スタイルグリッド

    private var styleGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(ClockFaceStyle.allCases) { style in
                FaceStyleCard(
                    style: style,
                    isSelected: settingsManager.settings.faceStyle == style,
                    settings: settingsManager.settings,
                    currentDate: currentDate
                ) {
                    selectStyle(style)
                }
            }
        }
    }

    private func selectStyle(_ style: ClockFaceStyle) {
        withAnimation(.easeInOut) {
            settingsManager.settings.faceStyle = style
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - FaceStyleCard

private struct FaceStyleCard: View {
    let style: ClockFaceStyle
    let isSelected: Bool
    let settings: ClockSettings
    let currentDate: Date
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    AnalogClockView(
                        date: currentDate,
                        settings: previewSettings,
                        size: CGSize(width: 120, height: 120),
                        showSecondHand: false
                    )

                    if isSelected {
                        Circle()
                            .strokeBorder(Color.accentColor, lineWidth: 3)
                            .frame(width: 124, height: 124)
                    }
                }

                HStack(spacing: 4) {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.accentColor)
                            .font(.caption)
                    }

                    Text(style.displayName)
                        .font(.subheadline)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundStyle(isSelected ? Color.accentColor : .primary)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.accentColor.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(style.displayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "選択中" : "ダブルタップで選択")
    }

    private var previewSettings: ClockSettings {
        var s = settings
        s.faceStyle = style
        return s
    }
}
