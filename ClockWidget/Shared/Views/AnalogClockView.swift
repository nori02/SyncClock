import SwiftUI

/// メインのアナログ時計ビュー
/// ウィジェットおよびメインアプリの両方で使用される
struct AnalogClockView: View {
    let date: Date
    let settings: ClockSettings
    let size: CGSize
    /// 秒針表示（メインアプリプレビュー用のみ true にする）
    var showSecondHand: Bool = false

    @Environment(\.colorScheme) private var colorScheme

    /// 正方形を前提とするため、短い辺を使用
    private var clockSize: CGFloat { min(size.width, size.height) }
    private var radius: CGFloat { clockSize / 2 }

    // MARK: - Colors

    private var indexColor: Color { settings.indexColor.color }

    private var isDarkMode: Bool { colorScheme == .dark }

    // MARK: - Accessibility

    private var accessibilityTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            backgroundLayer

            // Outer ring（影付き）
            Circle()
                .strokeBorder(indexColor.opacity(0.25), lineWidth: clockSize * 0.008)
                .frame(width: clockSize, height: clockSize)
                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)

            // Face indices (numbers/markers)
            clockFaceView

            // Clock hands
            ClockHandsView(
                date: date,
                settings: settings,
                size: clockSize,
                showSecondHand: showSecondHand
            )
        }
        .frame(width: size.width, height: size.height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Analog clock showing \(accessibilityTimeString)"))
        .accessibilityAddTraits(.updatesFrequently)
    }

    // MARK: - Background Layer

    @ViewBuilder
    private var backgroundLayer: some View {
        WallpaperBackgroundView(config: settings.wallpaper)
            .frame(width: size.width, height: size.height)
            .clipped()
    }

    // MARK: - Face Dispatch

    @ViewBuilder
    private var clockFaceView: some View {
        switch settings.faceStyle {
        case .classic:
            ClassicClockFace(size: clockSize, indexColor: indexColor, isDarkMode: isDarkMode)
        case .modern:
            ModernClockFace(size: clockSize, indexColor: indexColor, isDarkMode: isDarkMode)
        case .sport:
            SportClockFace(size: clockSize, indexColor: indexColor, isDarkMode: isDarkMode)
        case .minimal:
            MinimalClockFace(size: clockSize, indexColor: indexColor, isDarkMode: isDarkMode)
        case .elegant:
            ElegantClockFace(size: clockSize, indexColor: indexColor, isDarkMode: isDarkMode)
        case .nordic:
            NordicClockFace(size: clockSize, indexColor: indexColor, isDarkMode: isDarkMode)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct AnalogClockView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnalogClockView(
                date: Date(),
                settings: .default,
                size: CGSize(width: 300, height: 300),
                showSecondHand: true
            )
            .previewDisplayName("Classic - Light")

            AnalogClockView(
                date: Date(),
                settings: ClockSettings(
                    faceStyle: .modern,
                    hourlyWallpapers: Array(repeating: .default, count: 24),
                    hourHandColor: .defaultHourHand,
                    minuteHandColor: .defaultMinuteHand,
                    secondHandColor: .defaultSecondHand,
                    indexColor: .defaultIndex,
                    showNumbers: false,
                    showSecondHand: false
                ),
                size: CGSize(width: 300, height: 300)
            )
            .previewDisplayName("Modern - Light")

            AnalogClockView(
                date: Date(),
                settings: ClockSettings(
                    faceStyle: .sport,
                    hourlyWallpapers: Array(repeating: .default, count: 24),
                    hourHandColor: .defaultHourHand,
                    minuteHandColor: .defaultMinuteHand,
                    secondHandColor: .defaultSecondHand,
                    indexColor: .defaultIndex,
                    showNumbers: true,
                    showSecondHand: true
                ),
                size: CGSize(width: 300, height: 300),
                showSecondHand: true
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("Sport - Dark")

            // Widget-sized previews
            AnalogClockView(
                date: Date(),
                settings: .default,
                size: CGSize(width: 155, height: 155)
            )
            .previewDisplayName("Small Widget")

            AnalogClockView(
                date: Date(),
                settings: .default,
                size: CGSize(width: 329, height: 329)
            )
            .previewDisplayName("Large Widget")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif
