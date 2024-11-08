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

    func testAMainWindow() throws {
        // UI tests must launch the application that they test.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        app.navigationBars["Today"].buttons["Back"].tap()
        
        // MARK: Create groups
        app.collectionViews.matching(identifier: "Sidebar").disclosureTriangles["Move"].tap()
        app.popovers.textFields["Group name"].tap()
        
        app.popovers.textFields["Group name"].typeText("🦝Personal")
        app.buttons["SaveGroup"].tap()
        
        app.collectionViews.matching(identifier: "Sidebar")/*@START_MENU_TOKEN@*/.disclosureTriangles["Move"]/*[[".cells.disclosureTriangles[\"Move\"]",".disclosureTriangles[\"Move\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.popovers.textFields["Group name"].tap()
        
        app.popovers.textFields["Group name"].typeText("🏢Work")
        app.buttons["SaveGroup"].tap()

        // MARK: Create first project
        app.collectionViews.matching(identifier: "Sidebar").disclosureTriangles["Add"].tap()
        app.popovers.textFields["Project name"].tap()
        app.popovers.textFields["Project name"].typeText("🚗 Car")
        
        app.popovers.switches["CreateSimpleList"].children(matching: .switch).element.tap()
        
        app.buttons["SaveProject"].tap()

        app.collectionViews.matching(identifier: "Sidebar").buttons["🚗 Car"].press(forDuration: 1.6)
        app.collectionViews/*@START_MENU_TOKEN@*/.buttons["Add project to group"]/*[[".cells.buttons[\"Add project to group\"]",".buttons[\"Add project to group\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.collectionViews.buttons["🦝Personal"].tap()
        
        // MARK: Create second project
        app.collectionViews.matching(identifier: "Sidebar").disclosureTriangles["Add"].tap()
        app.popovers.textFields["Project name"].tap()
        app.popovers.textFields["Project name"].typeText("❤️Health")
        
        app.popovers.switches["CreateSimpleList"].children(matching: .switch).element.tap()
        
        app.buttons["SaveProject"].tap()

        app.collectionViews.matching(identifier: "Sidebar").buttons["❤️Health"].press(forDuration: 1.6)
        app.collectionViews/*@START_MENU_TOKEN@*/.buttons["Add project to group"]/*[[".cells.buttons[\"Add project to group\"]",".buttons[\"Add project to group\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.collectionViews.buttons["🦝Personal"].tap()
        
        // MARK: Create third project
        app.collectionViews.matching(identifier: "Sidebar").disclosureTriangles["Add"].tap()
        app.popovers.textFields["Project name"].tap()
        app.popovers.textFields["Project name"].typeText("💻John’s project")
        
        app.buttons["SaveProject"].tap()

        app.collectionViews.matching(identifier: "Sidebar").buttons["💻John’s project"].press(forDuration: 1.6)
        app.collectionViews/*@START_MENU_TOKEN@*/.buttons["Add project to group"]/*[[".cells.buttons[\"Add project to group\"]",".buttons[\"Add project to group\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.collectionViews.buttons["🏢Work"].tap()
        
        // MARK: Create first task
        app.collectionViews.matching(identifier: "Sidebar").buttons["Today"].tap()
        app.navigationBars["Today"].buttons["Add task to current list"].tap()

        
                
//        app.collectionViews.matching(identifier: "Sidebar").buttons["💻John’s project"].tap()
//        
//        app.navigationBars["🚗 Car"].buttons["Add task to current list"].tap()
//        
//        let collectionViewsQuery = app.collectionViews
//        collectionViewsQuery.textFields["EditTaskName"].tap()
//        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["Set due Date"]/*[[".cells",".buttons[\"Set due Date\"].staticTexts[\"Set due Date\"]",".staticTexts[\"Set due Date\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
                        

    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
// swiftlint:enable function_body_length
