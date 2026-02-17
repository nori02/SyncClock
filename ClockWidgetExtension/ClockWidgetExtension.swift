import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct ClockTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClockTimelineEntry {
        ClockTimelineEntry(date: .now, settings: .default)
    }

    func getSnapshot(in context: Context, completion: @escaping (ClockTimelineEntry) -> Void) {
        let settings = SettingsManager.loadSettings()
        completion(ClockTimelineEntry(date: .now, settings: settings))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockTimelineEntry>) -> Void) {
        let settings = SettingsManager.loadSettings()
        let currentDate = Date()

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
        guard let startOfMinute = calendar.date(from: components) else {
            let entry = ClockTimelineEntry(date: currentDate, settings: settings)
            completion(Timeline(entries: [entry], policy: .atEnd))
            return
        }

        var entries: [ClockTimelineEntry] = []
        for minuteOffset in 0..<60 {
            guard let entryDate = calendar.date(byAdding: .minute, value: minuteOffset, to: startOfMinute) else { continue }
            let entryHour = calendar.component(.hour, from: entryDate)
            // その時間の壁紙を解決し、軽量化のため全スロットに同一壁紙をセット
            var entrySettings = settings
            let resolved = settings.wallpaper(forHour: entryHour)
            entrySettings.hourlyWallpapers = Array(repeating: resolved, count: 24)
            entries.append(ClockTimelineEntry(date: entryDate, settings: entrySettings))
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Timeline Entry

struct ClockTimelineEntry: TimelineEntry {
    let date: Date
    let settings: ClockSettings
}

// MARK: - Widget Entry View

struct ClockWidgetEntryView: View {
    var entry: ClockTimelineProvider.Entry

    var body: some View {
        SmallWidgetView(entry: entry)
    }
}

// MARK: - Home Screen Widget

struct ClockWidget: Widget {
    let kind: String = "ClockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClockTimelineProvider()) { entry in
            ClockWidgetEntryView(entry: entry)
                .padding(-12) // マージンを詰めて時計を大きく表示
                .containerBackground(for: .widget) {
                    WallpaperBackgroundView(config: entry.settings.wallpaper)
                }
        }
        .configurationDisplayName("Sync Clock")
        .description("時間ごとに壁紙が変わるアナログ時計ウィジェット")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    ClockWidget()
} timeline: {
    ClockTimelineEntry(date: .now, settings: .default)
}
