#if os(macOS)
import DeckleCore
import PDFKit
import SwiftUI

private enum RefreshPolicy {
    static let fallbackRescanIntervalSeconds: TimeInterval = 30
}

final class NotebookLibraryViewModel: ObservableObject {
    @Published var tree: [NotebookNode] = []
    @Published var selectedPDF: URL?
    @Published var rootFolder: URL?
    private let rootFolderDefaultsKey = "deckle.rootFolderPath"

    private var folderMonitor: FolderMonitor?
    private var timer: Timer?

    init() {
        let rootFolderPath = UserDefaults.standard.string(forKey: rootFolderDefaultsKey) ?? ""
        if !rootFolderPath.isEmpty {
            setRootFolder(URL(fileURLWithPath: rootFolderPath))
        }
    }

    deinit {
        folderMonitor?.stop()
        timer?.invalidate()
    }

    func chooseRootFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let selected = panel.url {
            setRootFolder(selected)
        }
    }

    func setRootFolder(_ url: URL) {
        rootFolder = url
        UserDefaults.standard.set(url.path, forKey: rootFolderDefaultsKey)
        reloadTree()
        startMonitoring()
    }

    func reloadTree() {
        guard let rootFolder else {
            tree = []
            selectedPDF = nil
            return
        }

        do {
            let newTree = try NotebookIndexer.buildTree(from: rootFolder)
            tree = newTree
            if let selectedPDF, !FileManager.default.fileExists(atPath: selectedPDF.path) {
                self.selectedPDF = nil
            }
        } catch {
            tree = []
            selectedPDF = nil
        }
    }

    private func startMonitoring() {
        folderMonitor?.stop()
        timer?.invalidate()

        guard let rootFolder else { return }

        folderMonitor = FolderMonitor(url: rootFolder) { [weak self] in
            DispatchQueue.main.async {
                self?.reloadTree()
            }
        }
        folderMonitor?.start()

        timer = Timer.scheduledTimer(withTimeInterval: RefreshPolicy.fallbackRescanIntervalSeconds, repeats: true) { [weak self] _ in
            self?.reloadTree()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = NotebookLibraryViewModel()
    @AppStorage("deckle.theme") private var selectedThemeRaw = AppTheme.moleskine.rawValue
    @AppStorage("deckle.rootFolderPath") private var rootFolderPath = ""

    // Custom theme colours — kept in sync with SettingsView via shared AppStorage keys.
    @AppStorage(CustomThemeKey.background) private var customBackgroundHex = CustomThemeKey.defaultBackground
    @AppStorage(CustomThemeKey.sidebar)    private var customSidebarHex    = CustomThemeKey.defaultSidebar
    @AppStorage(CustomThemeKey.paper)      private var customPaperHex      = CustomThemeKey.defaultPaper
    @AppStorage(CustomThemeKey.text)       private var customTextHex       = CustomThemeKey.defaultText

    @Environment(\.openSettings) private var openSettings

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: selectedThemeRaw) ?? .moleskine
    }

    private var resolvedTheme: NotebookTheme {
        if let preset = selectedTheme.presetTheme { return preset }
        return NotebookTheme(
            background: Color(hex: customBackgroundHex),
            sidebar:    Color(hex: customSidebarHex),
            paper:      Color(hex: customPaperHex),
            text:       Color(hex: customTextHex)
        )
    }

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailView
        }
        .background(resolvedTheme.background)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    openSettings()
                } label: {
                    Image(systemName: "gear")
                }
                .help("Open Preferences")
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Choose Library") {
                    viewModel.chooseRootFolder()
                }
            }
        }
        .onChange(of: rootFolderPath) { _, newValue in
            guard !newValue.isEmpty else { return }
            let url = URL(fileURLWithPath: newValue)
            if url != viewModel.rootFolder {
                viewModel.setRootFolder(url)
            }
        }
    }

    private var sidebar: some View {
        List(selection: $viewModel.selectedPDF) {
            if let root = viewModel.rootFolder {
                Section(root.lastPathComponent) {
                    ForEach(viewModel.tree) { node in
                        NotebookTreeNodeView(node: node, selectedPDF: $viewModel.selectedPDF)
                    }
                }
            } else {
                Text("Select a folder in Settings or use the toolbar button.")
                    .foregroundStyle(.secondary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(resolvedTheme.sidebar)
        .foregroundStyle(resolvedTheme.text)
        .navigationTitle("Deckle")
    }

    @ViewBuilder
    private var detailView: some View {
        if let url = viewModel.selectedPDF {
            PDFDocumentView(url: url)
                .background(resolvedTheme.paper)
        } else {
            VStack(spacing: 12) {
                Text("Open a notebook")
                    .font(.title2.weight(.medium))
                    .foregroundStyle(resolvedTheme.text.opacity(0.6))
                Text("Choose a PDF in the sidebar to view it.")
                    .foregroundStyle(resolvedTheme.text.opacity(0.4))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(resolvedTheme.paper)
        }
    }
}

struct NotebookTreeNodeView: View {
    let node: NotebookNode
    @Binding var selectedPDF: URL?

    var body: some View {
        if node.isDirectory {
            DisclosureGroup(node.name) {
                ForEach(node.children) { child in
                    NotebookTreeNodeView(node: child, selectedPDF: $selectedPDF)
                }
            }
        } else {
            Button {
                selectedPDF = node.path
            } label: {
                Label(node.name, systemImage: "doc.richtext")
            }
            .buttonStyle(.plain)
            .tag(node.path)
        }
    }
}

struct PDFDocumentView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displaysPageBreaks = true
        return view
    }

    func updateNSView(_ nsView: PDFView, context: Context) {
        if nsView.document?.documentURL != url {
            nsView.document = PDFDocument(url: url)
        }
    }
}

extension AppearanceMode {
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
#endif
