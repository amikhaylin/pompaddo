//
//  PomPadDo_watchUITests.swift
//  PomPadDo.watchUITests
//
//  Created by Andrey Mikhaylin on 29.10.2025.
//

import XCTest

final class PomPadDoWatchUITests: XCTestCase {
    var app: XCUIApplication!
    
    @MainActor override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        
        if ProcessInfo.processInfo.environment["IS_FASTLANE"] == "YES" {
            setupSnapshot(app)
        }

        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor func testAFullCycle() throws {
        app/*@START_MENU_TOKEN@*/.otherElements["Inbox"].otherElements.firstMatch/*[[".otherElements.element(boundBy: 11)",".otherElements[\"Inbox\"].otherElements.firstMatch"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.switches["0"].firstMatch.tap()
        app.textFields["TaskName"].firstMatch.tap()
        typeText("Book airline tickets")
        app/*@START_MENU_TOKEN@*/.buttons["Done"]/*[[".otherElements.buttons[\"Done\"]",".buttons[\"Done\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let exp0 = expectation(description: "Test after 2 seconds")
        _ = XCTWaiter.wait(for: [exp0], timeout: 1.0)
        
        app/*@START_MENU_TOKEN@*/.buttons["List"]/*[[".navigationBars.buttons[\"List\"]",".buttons[\"List\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let exp1 = expectation(description: "Test after 2 seconds")
        _ = XCTWaiter.wait(for: [exp1], timeout: 1.0)
        
        app/*@START_MENU_TOKEN@*/.staticTexts["Focus"]/*[[".buttons[\"FocusNavButton\"].staticTexts",".buttons.staticTexts[\"Focus\"]",".staticTexts[\"Focus\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["StartTimerButton"]/*[[".toolbars",".buttons",".buttons[\"Play\"]",".buttons[\"StartTimerButton\"]"],[[[-1,3],[-1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let exp2 = expectation(description: "Test after 5 seconds")
        _ = XCTWaiter.wait(for: [exp2], timeout: 5.0)
        
        snapshot("04FocusTimer")
        
        app/*@START_MENU_TOKEN@*/.buttons["List"]/*[[".navigationBars.buttons[\"List\"]",".buttons[\"List\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        snapshot("02SectionsPanel")
        
        app/*@START_MENU_TOKEN@*/.staticTexts["Today"]/*[[".buttons[\"TodayNavButton\"].staticTexts",".buttons.staticTexts[\"Today\"]",".staticTexts[\"Today\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        let exp11 = expectation(description: "Test after 2 seconds")
        _ = XCTWaiter.wait(for: [exp11], timeout: 1.0)
        
        snapshot("01TodayScreen")
        
        app.cells["Square, Book airline tickets"].firstMatch.tap()

        let exp3 = expectation(description: "Test after 5 seconds")
        _ = XCTWaiter.wait(for: [exp3], timeout: 2.0)
        
        snapshot("03TaskDetails")

        app/*@START_MENU_TOKEN@*/.buttons["BackButton"]/*[[".navigationBars",".buttons",".buttons[\"Back\"]",".buttons[\"BackButton\"]"],[[[-1,3],[-1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
       
    }
    
    private func typeText(_ text: String) {
        let chars = Array(text)
        for char in chars {
            if String(char) == " " {
                app.keys["space"].firstMatch.tap()
                continue
            }
            app.keys[String(char)].firstMatch.tap()
        }
    }
}
