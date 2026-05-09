import DeckleCore
import XCTest

final class AppThemeTests: XCTestCase {
    func testThemesExposeImplementationStatus() {
        XCTAssertTrue(AppTheme.moleskine.isImplemented)
        XCTAssertFalse(AppTheme.linen.isImplemented)
        XCTAssertFalse(AppTheme.graphite.isImplemented)
    }
}
