//
//  PomPadDoiOSUITests.swift
//  PomPadDoiOSUITests
//
//  Created by Andrey Mikhaylin on 13.05.2024.
//
// swiftlint:disable function_body_length

import XCTest

final class PomPadDoiOSUITests: XCTestCase {
    
    var app: XCUIApplication!

    @MainActor override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // In UI tests it is usually best to stop immediately when a failure occurs.
        
        continueAfterFailure = false

        app = XCUIApplication()

        if ProcessInfo.processInfo.environment["IS_FASTLANE"] == "YES" {
            setupSnapshot(app)
        }
        
        app.launch()

        addUIInterruptionMonitor(withDescription: "Tracking Usage Permission Alert") { (alert) -> Bool in
                if alert.buttons["Allow"].exists {
                    alert.buttons["Allow"].tap()
                    self.app.activate()
                    return true
                }
                return false
            }
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor func testAFullCycle() throws {
        // MARK: Create groups
        app.navigationBars["Today"].buttons["Back"].tap()

        app.collectionViews.matching(identifier: "Sidebar").buttons["folder.circle"].tap()
        app.popovers.textFields["Group name"].tap()
        
        app.popovers.textFields["Group name"].typeText("🦝Personal")
        app.buttons["SaveGroup"].tap()
        
        app.collectionViews.matching(identifier: "Sidebar").buttons["folder.circle"].tap()
        app.popovers.textFields["Group name"].tap()
        
        app.popovers.textFields["Group name"].typeText("🏢Work")
        app.buttons["SaveGroup"].tap()

        app.collectionViews.matching(identifier: "Sidebar").staticTexts["Today"].tap()
        
        // MARK: Fill projects
        app.navigationBars["Today"].buttons["Back"].tap()

        // MARK: Create project **Vacation Planning**
        app.collectionViews.matching(identifier: "Sidebar").buttons["plus.circle"].tap()
        app.popovers.textFields["Project name"].tap()
        app.popovers.textFields["Project name"].typeText("🏖️ Vacation Planning")
        
        app.popovers.switches["CreateSimpleList"].children(matching: .switch).element.tap()
        
        app.buttons["SaveProject"].tap()

        app.collectionViews.matching(identifier: "Sidebar").buttons["🏖️ Vacation Planning"].press(forDuration: 1.6)
        app.collectionViews.buttons["Add project to group"].tap()
        
        print(app.collectionViews.buttons.debugDescription)
        app.collectionViews.buttons["🦝PersonalContextMenuButton"].tap()
        
        // MARK: Create project **App Development**
        app.collectionViews.matching(identifier: "Sidebar").buttons["plus.circle"].tap()
        app.popovers.textFields["Project name"].tap()
        app.popovers.textFields["Project name"].typeText("📱App Development")
        
        app.buttons["SaveProject"].tap()

        app.collectionViews.matching(identifier: "Sidebar").buttons["📱App Development"].press(forDuration: 1.6)
        app.collectionViews.buttons["Add project to group"].tap()
        
        print(app.collectionViews.buttons.debugDescription)
        app.collectionViews.buttons["🏢WorkContextMenuButton"].tap()
        
        app.collectionViews.matching(identifier: "Sidebar").staticTexts["Today"].tap()

        // MARK: Fill Vacation planning tasks
        app.navigationBars["Today"].buttons["Back"].tap()
        
        app.collectionViews.matching(identifier: "Sidebar").staticTexts["🏖️ Vacation Planning"].tap()
        
        app.navigationBars["🏖️ Vacation Planning"].buttons["Add task to current list"].tap()
        app.popovers.textFields["Task name"].tap()
        app.popovers.textFields["Task name"].typeText("Book airline tickets")
        app.popovers.switches["DueToday"].children(matching: .switch).element.tap()
        app.buttons["SaveTask"].tap()
        
        app.navigationBars["🏖️ Vacation Planning"].buttons["Add task to current list"].tap()
        app.popovers.textFields["Task name"].tap()
        app.popovers.textFields["Task name"].typeText("Find and reserve a hotel")
        app.buttons["SaveTask"].tap()
        
        app.navigationBars["🏖️ Vacation Planning"].buttons["Add task to current list"].tap()
        app.popovers.textFields["Task name"].tap()
        app.popovers.textFields["Task name"].typeText("Create a list of places to visit")
        app.buttons["SaveTask"].tap()
        
        app.navigationBars["🏖️ Vacation Planning"].buttons["Add task to current list"].tap()
        app.popovers.textFields["Task name"].tap()
        app.popovers.textFields["Task name"].typeText("Arrange travel insurance")
        app.buttons["SaveTask"].tap()
        
        app.navigationBars["🏖️ Vacation Planning"].buttons["Back"].tap()
        
        app.collectionViews.matching(identifier: "Sidebar").staticTexts["Today"].tap()

        // MARK: Fill App Development tasks
        app.navigationBars["Today"].buttons["Back"].tap()
        
        app.collectionViews.matching(identifier: "Sidebar").staticTexts["📱App Development"].tap()
        
        app.navigationBars["📱App Development"].buttons["Add task to current list"].tap()
        app.popovers.textFields["Task name"].tap()
        app.popovers.textFields["Task name"].typeText("Define functional requirements")
        app.buttons["SaveTask"].tap()
        
        app.navigationBars["📱App Development"].buttons["Add task to current list"].tap()
        app.popovers.textFields["Task name"].tap()
        app.popovers.textFields["Task name"].typeText("Create interface design")
        app.popovers.switches["DueToday"].children(matching: .switch).element.tap()
        app.buttons["SaveTask"].tap()
        
        app.navigationBars["📱App Development"].buttons["Add task to current list"].tap()
        app.popovers.textFields["Task name"].tap()
        app.popovers.textFields["Task name"].typeText("Test the beta version")
        app.buttons["SaveTask"].tap()
        
        app.navigationBars["📱App Development"].buttons["Add task to current list"].tap()
        app.popovers.textFields["Task name"].tap()
        app.popovers.textFields["Task name"].typeText("Launch the app in the App Store")
        app.buttons["SaveTask"].tap()
        
        // MARK: Switch project view
        app.navigationBars["📱App Development"].segmentedControls["ProjectViewMode"].tap()
        app.navigationBars["📱App Development"].segmentedControls["ProjectViewMode"].buttons["rectangle.split.3x1"].tap()
        
        app.scrollViews.otherElements.collectionViews.staticTexts["Define functional requirements"].press(forDuration: 1.6)
        
        snapshot("02TaskMenu")
        app.collectionViews.buttons["Move to status"].tap()
        app.collectionViews.buttons["CompletedContextMenuButton"].tap()
        
        snapshot("03ProjectView")
        
        app.navigationBars["📱App Development"].buttons["Back"].tap()
        
        app.collectionViews.matching(identifier: "Sidebar").staticTexts["Today"].tap()
        
        snapshot("01TodayScreen")
        
        app.toolbars["Toolbar"].buttons["FocusSection"].forceTap()
        
        snapshot("04FocusTasksView")
        
        app.collectionViews.buttons["Create interface designPlayButton"].tap()
        
        let exp = expectation(description: "Test after 5 seconds")
        _ = XCTWaiter.wait(for: [exp], timeout: 5.0)

        snapshot("05FocusTimerView")
        
        app.toolbars["Toolbar"].buttons["TasksSection"].tap()
    }
    
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
// swiftlint:enable function_body_length


extension XCUIElement {
    func forceTap() {
        coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }
}
