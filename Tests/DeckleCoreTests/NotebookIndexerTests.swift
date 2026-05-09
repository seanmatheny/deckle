import DeckleCore
import Foundation
import XCTest

final class NotebookIndexerTests: XCTestCase {
    func testIndexerBuildsPDFTree() throws {
        let fm = FileManager.default
        let root = fm.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fm.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: root) }

        let personal = root.appendingPathComponent("Personal", isDirectory: true)
        let work = root.appendingPathComponent("Work", isDirectory: true)
        try fm.createDirectory(at: personal, withIntermediateDirectories: true)
        try fm.createDirectory(at: work, withIntermediateDirectories: true)

        let nested = personal.appendingPathComponent("book notes", isDirectory: true)
        try fm.createDirectory(at: nested, withIntermediateDirectories: true)

        XCTAssertTrue(fm.createFile(atPath: personal.appendingPathComponent("Notebook 2.pdf").path, contents: Data()))
        XCTAssertTrue(fm.createFile(atPath: personal.appendingPathComponent("ignore.txt").path, contents: Data()))
        XCTAssertTrue(fm.createFile(atPath: nested.appendingPathComponent("Notebook 1.pdf").path, contents: Data()))
        XCTAssertTrue(fm.createFile(atPath: work.appendingPathComponent("Daily Work Notes.pdf").path, contents: Data()))

        let tree = try NotebookIndexer.buildTree(from: root)

        XCTAssertEqual(tree.count, 2)
        XCTAssertTrue(tree[0].isDirectory)
        XCTAssertEqual(tree[0].name, "Personal")
        XCTAssertEqual(tree[1].name, "Work")

        let personalChildren = tree[0].children.map(\.name)
        XCTAssertTrue(personalChildren.contains("Notebook 2.pdf"))
        XCTAssertTrue(personalChildren.contains("book notes"))
        XCTAssertFalse(personalChildren.contains("ignore.txt"))
    }

    func testThemesExposeImplementationStatus() {
        XCTAssertTrue(AppTheme.moleskine.isImplemented)
        XCTAssertFalse(AppTheme.linen.isImplemented)
        XCTAssertFalse(AppTheme.graphite.isImplemented)
    }
}
