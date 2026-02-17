import SwiftUI
import Combine

@MainActor
final class SettingsManager: ObservableObject {

    static let appGroupID = "group.com.clockwidget.shared"
    private static let settingsKey = "clock_settings"
    private static let hasLaunchedKey = "has_launched_before"

    @Published var settings: ClockSettings {
        didSet { save() }
    }

    private let defaults: UserDefaults?

    init() {
        self.defaults = UserDefaults(suiteName: Self.appGroupID)
        self.settings = Self.load(from: UserDefaults(suiteName: Self.appGroupID))
    }

    private static func load(from defaults: UserDefaults?) -> ClockSettings {
        guard let defaults, let data = defaults.data(forKey: settingsKey) else { return .default }
        do { return try JSONDecoder().decode(ClockSettings.self, from: data) }
        catch { return .default }
    }

    private func save() {
        guard let defaults else { return }
        do { let data = try JSONEncoder().encode(settings); defaults.set(data, forKey: Self.settingsKey) }
        catch { }
    }

    var isFirstLaunch: Bool {
        guard let defaults else { return true }
        return !defaults.bool(forKey: Self.hasLaunchedKey)
    }

    func markAsLaunched() { defaults?.set(true, forKey: Self.hasLaunchedKey) }

    func resetToDefaults() { settings = .default }

    nonisolated static func loadSettings() -> ClockSettings {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: settingsKey) else { return .default }
        do { return try JSONDecoder().decode(ClockSettings.self, from: data) }
        catch { return .default }
    }
}
