import Foundation

public struct NotebookNode: Identifiable, Equatable {
    public let path: URL
    public let isDirectory: Bool
    public var children: [NotebookNode]

    public var id: String { path.path }
    public var name: String { path.lastPathComponent }

    public init(path: URL, isDirectory: Bool, children: [NotebookNode] = []) {
        self.path = path
        self.isDirectory = isDirectory
        self.children = children
    }
}

public enum AppTheme: String, CaseIterable, Codable {
    case moleskine
    case linen
    case graphite
    case custom

    public var displayName: String {
        switch self {
        case .moleskine:
            return "Moleskine Leather"
        case .linen:
            return "Classic Linen"
        case .graphite:
            return "Graphite"
        case .custom:
            return "Custom"
        }
    }
}

public enum AppearanceMode: String, CaseIterable, Codable {
    case system
    case light
    case dark

    public var displayName: String {
        switch self {
        case .system:
            return "Follow System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}
