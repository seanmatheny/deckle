import DeckleCore
import XCTest

final class AppThemeTests: XCTestCase {
    func testAllThemesHaveNonEmptyDisplayNames() {
        for theme in AppTheme.allCases {
            XCTAssertFalse(theme.displayName.isEmpty, "\(theme.rawValue) should have a display name")
        }
    }

    func testCustomThemeIsIncluded() {
        XCTAssertTrue(AppTheme.allCases.contains(.custom))
    }
}
