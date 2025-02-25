//
//  PomPadDoMacUITests.swift
//  PomPadDoMacUITests
//
//  Created by Andrey Mikhaylin on 13.02.2024.
//
// swiftlint:disable function_body_length

import XCTest

final class PomPadDoMacUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testZInfo() throws {
        var locale: String!
        if app.windows["Today"].exists {
            locale = "en"
        } else if app.windows["Сегодня"].exists {
            locale = "ru"
        }
        
        print("Locale: \(locale)")
        
        print(app.debugDescription)
        
        print(app.outlines.matching(identifier: "Sidebar").buttons.debugDescription)
    }
    
    func screenshot(_ name: String) {
        let exp = expectation(description: "Screenshot after 1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 1.0)
        if result == XCTWaiter.Result.timedOut {
            let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func testAFullCycle() throws {
        var locale: String!
        if app.windows["Today"].exists {
            locale = "en"
        } else if app.windows["Сегодня"].exists {
            locale = "ru"
        }
        
        // MARK: Create groups
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
