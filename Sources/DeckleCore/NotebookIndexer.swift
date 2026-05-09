import Foundation

public enum NotebookIndexError: Error {
    case rootMissing
}

public enum NotebookIndexer {
    /// Builds a tree that includes PDF files and only directories that contain PDFs directly
    /// or in their descendant folders.
    public static func buildTree(from root: URL, fileManager: FileManager = .default) throws -> [NotebookNode] {
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: root.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw NotebookIndexError.rootMissing
        }

        return try scanDirectory(root, fileManager: fileManager)
    }

    private static func scanDirectory(_ directory: URL, fileManager: FileManager) throws -> [NotebookNode] {
        let urls = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        var nodes: [NotebookNode] = []

        for url in urls {
            let values = try url.resourceValues(forKeys: [.isDirectoryKey])
            let directoryEntry = values.isDirectory ?? false

            if directoryEntry {
                let children = try scanDirectory(url, fileManager: fileManager)
                if !children.isEmpty {
                    nodes.append(NotebookNode(path: url, isDirectory: true, children: children))
                }
            } else if url.pathExtension.lowercased() == "pdf" {
                nodes.append(NotebookNode(path: url, isDirectory: false))
            }
        }

        return nodes.sorted { lhs, rhs in
            if lhs.isDirectory != rhs.isDirectory {
                return lhs.isDirectory && !rhs.isDirectory
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }
}
