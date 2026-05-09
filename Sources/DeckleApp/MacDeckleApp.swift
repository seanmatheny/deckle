#if os(macOS)
import DeckleCore
import SwiftUI

@main
struct DeckleAppMain: App {
    @AppStorage("deckle.appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue

    private var appearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceModeRaw) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(appearanceMode.colorScheme)
        }
        .windowStyle(.titleBar)

        Settings {
            SettingsView()
        }
    }
}
#endif
