import SwiftUI
import WidgetKit

/// ホーム画面用 Small ウィジェット — 正方形のアナログ時計表示
/// 背景は containerBackground が担当するため、ここでは時計のみ描画
struct SmallWidgetView: View {
    let entry: ClockTimelineEntry

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            AnalogClockView(
                date: entry.date,
                settings: entry.settings,
                size: CGSize(width: size, height: size),
                showSecondHand: false
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Current time: \(entry.date, style: .time)"))
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    ClockWidget()
} timeline: {
    ClockTimelineEntry(date: .now, settings: .default)
}
