#if os(macOS)
import AppKit
import DeckleCore
import SwiftUI

// MARK: - NotebookTheme

struct NotebookTheme {
    let background: Color
    let sidebar: Color
    let paper: Color
    let text: Color
}

extension NotebookTheme {
    static let moleskine = NotebookTheme(
        background: Color(red: 0.20, green: 0.14, blue: 0.09),
        sidebar:    Color(red: 0.27, green: 0.19, blue: 0.11),
        paper:      Color(red: 0.94, green: 0.90, blue: 0.82),
        text:       Color(red: 0.93, green: 0.86, blue: 0.74)
    )

    static let linen = NotebookTheme(
        background: Color(red: 0.78, green: 0.72, blue: 0.62),
        sidebar:    Color(red: 0.68, green: 0.61, blue: 0.50),
        paper:      Color(red: 0.97, green: 0.95, blue: 0.90),
        text:       Color(red: 0.17, green: 0.12, blue: 0.06)
    )

    static let graphite = NotebookTheme(
        background: Color(red: 0.18, green: 0.18, blue: 0.18),
        sidebar:    Color(red: 0.12, green: 0.12, blue: 0.12),
        paper:      Color(red: 0.95, green: 0.95, blue: 0.95),
        text:       Color(red: 0.92, green: 0.92, blue: 0.92)
    )
}

// MARK: - AppTheme resolved theme

extension AppTheme {
    /// Resolves the preset colour values for built-in themes.
    /// For `.custom` the caller supplies the individual hex values.
    var presetTheme: NotebookTheme? {
        switch self {
        case .moleskine: return .moleskine
        case .linen:     return .linen
        case .graphite:  return .graphite
        case .custom:    return nil
        }
    }
}

// MARK: - UserDefaults keys for custom colours

enum CustomThemeKey {
    static let background = "deckle.customBackground"
    static let sidebar    = "deckle.customSidebar"
    static let paper      = "deckle.customPaper"
    static let text       = "deckle.customText"

    // Defaults: start with Moleskine values so switching to Custom looks familiar.
    static let defaultBackground = "#33231A"
    static let defaultSidebar    = "#453018"
    static let defaultPaper      = "#F0E6D0"
    static let defaultText       = "#EDD9BD"
}

// MARK: - Color ↔ hex string helpers

extension Color {
    /// Initialises a `Color` from a 6-character RGB hex string such as `"#1A2B3C"` or `"1A2B3C"`.
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >>  8) & 0xFF) / 255
        let b = Double( value        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    /// Returns a `"#RRGGBB"` hex string for this colour using the sRGB colour space.
    var hexString: String {
        guard let ns = NSColor(self).usingColorSpace(.sRGB) else { return "#000000" }
        let r = Int((ns.redComponent   * 255).rounded())
        let g = Int((ns.greenComponent * 255).rounded())
        let b = Int((ns.blueComponent  * 255).rounded())
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - Colour-picker row (label + hex field + swatch picker)

struct ColorPickerRow: View {
    let label: String
    @Binding var hex: String

    @State private var editingHex: String = ""
    @FocusState private var hexFocused: Bool

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("#RRGGBB", text: $editingHex)
                .frame(width: 88)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
                .focused($hexFocused)
                .onAppear { editingHex = hex }
                .onChange(of: hex) { _, newHex in
                    if !hexFocused { editingHex = newHex }
                }
                .onSubmit { commitHex() }
                .onChange(of: hexFocused) { _, focused in
                    if !focused { commitHex() }
                }
            ColorPicker("", selection: Binding(
                get: { Color(hex: hex) },
                set: { newColor in
                    let h = newColor.hexString
                    hex = h
                    editingHex = h
                }
            ), supportsOpacity: false)
            .labelsHidden()
            .frame(width: 36)
        }
    }

    private func commitHex() {
        let cleaned = editingHex.trimmingCharacters(in: .alphanumerics.inverted)
        guard cleaned.count == 6, cleaned.allSatisfy(\.isHexDigit) else {
            editingHex = hex  // revert invalid input
            return
        }
        let normalised = "#\(cleaned.uppercased())"
        hex = normalised
        editingHex = normalised
    }
}

// MARK: - Theme preview swatch

struct ThemeSwatchView: View {
    let theme: NotebookTheme

    var body: some View {
        HStack(spacing: 0) {
            theme.sidebar.frame(width: 16)
            theme.paper.frame(width: 24)
            theme.background.frame(width: 12)
        }
        .frame(height: 18)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.primary.opacity(0.15), lineWidth: 1))
    }
}
#endif
