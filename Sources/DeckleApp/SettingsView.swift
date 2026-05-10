#if os(macOS)
import DeckleCore
import SwiftUI

struct SettingsView: View {
    @AppStorage("deckle.theme") private var selectedThemeRaw = AppTheme.moleskine.rawValue
    @AppStorage("deckle.appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue
    @AppStorage("deckle.rootFolderPath") private var rootFolderPath = ""

    @AppStorage(CustomThemeKey.background) private var customBackgroundHex = CustomThemeKey.defaultBackground
    @AppStorage(CustomThemeKey.sidebar)    private var customSidebarHex    = CustomThemeKey.defaultSidebar
    @AppStorage(CustomThemeKey.paper)      private var customPaperHex      = CustomThemeKey.defaultPaper
    @AppStorage(CustomThemeKey.text)       private var customTextHex       = CustomThemeKey.defaultText

    private var selectedTheme: AppTheme {
        get { AppTheme(rawValue: selectedThemeRaw) ?? .moleskine }
        set { selectedThemeRaw = newValue.rawValue }
    }

    private var resolvedPreview: NotebookTheme {
        if let preset = selectedTheme.presetTheme { return preset }
        return NotebookTheme(
            background: Color(hex: customBackgroundHex),
            sidebar:    Color(hex: customSidebarHex),
            paper:      Color(hex: customPaperHex),
            text:       Color(hex: customTextHex)
        )
    }

    var body: some View {
        Form {
            librarySection
            appearanceSection
            if selectedTheme == .custom {
                customColourSection
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 540)
        .frame(minHeight: selectedTheme == .custom ? 480 : 280)
        .animation(.easeInOut(duration: 0.2), value: selectedTheme)
    }

    // MARK: - Library

    private var librarySection: some View {
        Section("Library") {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if rootFolderPath.isEmpty {
                        Text("No folder selected")
                            .foregroundStyle(.secondary)
                    } else {
                        Text(URL(fileURLWithPath: rootFolderPath).lastPathComponent)
                            .fontWeight(.medium)
                        Text(rootFolderPath)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                Spacer()
                Button("Choose Folder…") {
                    chooseRootFolder()
                }
            }
        }
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Mode", selection: Binding(
                get: { AppearanceMode(rawValue: appearanceModeRaw) ?? .system },
                set: { appearanceModeRaw = $0.rawValue }
            )) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }

            Picker("Theme", selection: Binding(
                get: { AppTheme(rawValue: selectedThemeRaw) ?? .moleskine },
                set: { selectedThemeRaw = $0.rawValue }
            )) {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    HStack(spacing: 8) {
                        if let preset = theme.presetTheme {
                            ThemeSwatchView(theme: preset)
                        } else {
                            ThemeSwatchView(theme: NotebookTheme(
                                background: Color(hex: customBackgroundHex),
                                sidebar:    Color(hex: customSidebarHex),
                                paper:      Color(hex: customPaperHex),
                                text:       Color(hex: customTextHex)
                            ))
                        }
                        Text(theme.displayName)
                    }
                    .tag(theme)
                }
            }
        }
    }

    // MARK: - Custom colours

    private var customColourSection: some View {
        Section("Custom Colours") {
            ColorPickerRow(label: "Background",    hex: $customBackgroundHex)
            ColorPickerRow(label: "Sidebar",       hex: $customSidebarHex)
            ColorPickerRow(label: "Paper / Viewer", hex: $customPaperHex)
            ColorPickerRow(label: "Text",          hex: $customTextHex)

            HStack {
                Spacer()
                Button("Reset to Moleskine") {
                    customBackgroundHex = CustomThemeKey.defaultBackground
                    customSidebarHex    = CustomThemeKey.defaultSidebar
                    customPaperHex      = CustomThemeKey.defaultPaper
                    customTextHex       = CustomThemeKey.defaultText
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .font(.footnote)
            }
        }
    }

    // MARK: - Helpers

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

