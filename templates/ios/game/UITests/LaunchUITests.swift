import XCTest

/// Smoke test: the game launches and stays in the foreground.
final class LaunchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunches() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertEqual(app.state, .runningForeground)
        app.tap()
        XCTAssertEqual(app.state, .runningForeground)
    }
}
