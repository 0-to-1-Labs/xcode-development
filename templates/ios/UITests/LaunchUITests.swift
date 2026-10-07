import XCTest

/// Smoke test: the app launches and the main screen renders on iPhone and iPad.
final class LaunchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchAndTap() throws {
        let app = XCUIApplication()
        app.launch()

        let label = app.staticTexts["counterLabel"]
        XCTAssertTrue(label.waitForExistence(timeout: 5))
        XCTAssertEqual(label.label, "0")

        app.buttons["incrementButton"].tap()
        XCTAssertEqual(label.label, "1")
    }
}
