import SwiftUI

@main
struct ClockWidgetApp: App {
    @StateObject private var settingsManager = SettingsManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(settingsManager)
                .preferredColorScheme(.dark)
        }
    }
}
