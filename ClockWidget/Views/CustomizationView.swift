import SwiftUI
import WidgetKit
import Combine

/// カスタマイズ画面 — 針の色・文字盤色・各種設定
struct CustomizationView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var currentDate = Date()
    @State private var showResetConfirmation = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        List {
            previewSection
            handColorSection
            faceColorSection
            otherSection
        }
        .navigationTitle("カスタマイズ")
        .onReceive(timer) { date in
            currentDate = date
        }
        .alert("設定をリセット", isPresented: $showResetConfirmation) {
            Button("キャンセル", role: .cancel) {}
            Button("リセット", role: .destructive) {
                resetSettings()
            }
        } message: {
            Text("すべての設定を初期状態に戻します。")
        }
    }

    // MARK: - プレビュー

    private var previewSection: some View {
        Section {
            HStack {
                Spacer()
                AnalogClockView(
                    date: currentDate,
                    settings: settingsManager.settings,
                    size: CGSize(width: 180, height: 180),
                    showSecondHand: true
                )
                Spacer()
            }
            .listRowBackground(Color.clear)
        }
    }

    // MARK: - 針の色

    private var handColorSection: some View {
        Section {
            colorPickerRow(title: "時針", color: colorBinding(\.hourHandColor))
            colorPickerRow(title: "分針", color: colorBinding(\.minuteHandColor))
            colorPickerRow(title: "秒針", color: colorBinding(\.secondHandColor))
            Toggle("秒針を表示", isOn: showSecondHandBinding)
        } header: {
            Text("針")
        }
    }

    // MARK: - 文字盤の色

    private var faceColorSection: some View {
        Section {
            colorPickerRow(title: "目盛りの色", color: colorBinding(\.indexColor))
            Toggle("数字を表示", isOn: showNumbersBinding)
        } header: {
            Text("文字盤")
        }
    }

    // MARK: - その他

    private var otherSection: some View {
        Section {
            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                HStack {
                    Spacer()
                    Label("初期設定に戻す", systemImage: "arrow.counterclockwise")
                    Spacer()
                }
            }
        } header: {
            Text("その他")
        }
    }

    // MARK: - ヘルパー

    private func colorPickerRow(title: String, color: Binding<Color>) -> some View {
        ColorPicker(title, selection: color, supportsOpacity: false)
            .onChange(of: color.wrappedValue) {
                WidgetCenter.shared.reloadAllTimelines()
            }
    }

    private func colorBinding(_ keyPath: WritableKeyPath<ClockSettings, CodableColor>) -> Binding<Color> {
        Binding<Color>(
            get: { settingsManager.settings[keyPath: keyPath].color },
            set: { newColor in
                withAnimation(.easeInOut) {
                    settingsManager.settings[keyPath: keyPath] = CodableColor(newColor)
                }
            }
        )
    }

    private var showNumbersBinding: Binding<Bool> {
        Binding<Bool>(
            get: { settingsManager.settings.showNumbers },
            set: { newValue in
                withAnimation(.easeInOut) {
                    settingsManager.settings.showNumbers = newValue
                }
                WidgetCenter.shared.reloadAllTimelines()
            }
        )
    }

    private var showSecondHandBinding: Binding<Bool> {
        Binding<Bool>(
            get: { settingsManager.settings.showSecondHand },
            set: { newValue in
                withAnimation(.easeInOut) {
                    settingsManager.settings.showSecondHand = newValue
                }
                WidgetCenter.shared.reloadAllTimelines()
            }
        )
    }

    private func resetSettings() {
        withAnimation(.easeInOut) {
            settingsManager.resetToDefaults()
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}
