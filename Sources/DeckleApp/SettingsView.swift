#if os(macOS)
import DeckleCore
import SwiftUI

struct SettingsView: View {
    @AppStorage("deckle.theme") private var selectedThemeRaw = AppTheme.moleskine.rawValue
    @AppStorage("deckle.appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue
    @AppStorage("deckle.rootFolderPath") private var rootFolderPath = ""

    private var selectedTheme: AppTheme {
        get { AppTheme(rawValue: selectedThemeRaw) ?? .moleskine }
        set { selectedThemeRaw = newValue.rawValue }
    }

    private var appearanceMode: AppearanceMode {
        get { AppearanceMode(rawValue: appearanceModeRaw) ?? .system }
        set { appearanceModeRaw = newValue.rawValue }
    }

    var body: some View {
        Form {
            Section("Library") {
                HStack {
                    Text(rootFolderPath.isEmpty ? "No folder selected" : rootFolderPath)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer()
                    Button("Choose Folder") {
                        chooseRootFolder()
                    }
                }
            }

            Section("Appearance") {
                Picker("Theme", selection: Binding(
                    get: { AppTheme(rawValue: selectedThemeRaw) ?? .moleskine },
                    set: { selectedThemeRaw = $0.rawValue }
                )) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Text(theme.settingsDisplayName)
                            .tag(theme)
                    }
                }

                Picker("Mode", selection: Binding(
                    get: { AppearanceMode(rawValue: appearanceModeRaw) ?? .system },
                    set: { appearanceModeRaw = $0.rawValue }
                )) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }

                if !selectedTheme.isImplemented {
                    Text("This theme is not implemented yet. Moleskine Leather is used for now.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 520)
    }

    private func chooseRootFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let selected = panel.url {
            rootFolderPath = selected.path
        }
    }
}
#endif
