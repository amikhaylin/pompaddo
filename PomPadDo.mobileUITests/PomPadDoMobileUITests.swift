//
//  PomPadDo_mobileUITests.swift
//  PomPadDo.mobileUITests
//
//  Created by Andrey Mikhaylin on 16.02.2025.
//
// swiftlint:disable function_body_length

import XCTest

final class PomPadDoMobileUITests: XCTestCase {

    var app: XCUIApplication!

    @MainActor override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // In UI tests it is usually best to stop immediately when a failure occurs.

        continueAfterFailure = false

        app = XCUIApplication()

        if ProcessInfo.processInfo.environment["IS_FASTLANE"] == "YES" {
            setupSnapshot(app)
        }

        app.launchEnvironment = ["UITEST_DISABLE_ANIMATIONS": "YES"]
        
        app.launch()

        addUIInterruptionMonitor(withDescription: "Tracking Usage Permission Alert") { (alert) -> Bool in
            print("Alert appeared: \(alert)")
            if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
                self.app.activate()
                return true
            }
            return false
        }
        
        addUIInterruptionMonitor(withDescription: "App Store Review Alert") { (alert) -> Bool in
            print("Alert appeared: \(alert)")
            if alert.buttons["Not Now"].exists {
                alert.buttons["Not Now"].tap()
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
        var locale: String!
        if app.navigationBars["Today"].exists {
            locale = "en"
        } else if app.navigationBars["Сегодня"].exists {
            locale = "ru"
        }
        
        let model = UIDevice.current.model

        let exp0 = expectation(description: "Test after 5 seconds")
        _ = XCTWaiter.wait(for: [exp0], timeout: 5.0)
        
        // MARK: Load from testData
        let testBundle = Bundle(for: type(of: self))

        // Find the URL of a JSON file by name
        guard let url = testBundle.url(forResource: "testData", withExtension: "json") else {
            XCTFail("The testsData.json file was not found in the bundle.")
            return
        }

        // Loading data from a JSON file
        guard let data = try? Data(contentsOf: url) else {
            XCTFail("No test data")
            return
        }

        // Decode JSON
        let decodedData = try JSONDecoder().decode([LocaleData].self, from: data)

        guard let localeData = decodedData.first(where: { $0.locale == locale }) else {
            XCTFail("No data for current locale")
            return
        }

        if !model.lowercased().contains("ipad") {
            app.navigationBars[localeData.today].buttons[localeData.back].tap()
        }

        // MARK: Create groups
        for group in localeData.groups {
            app.buttons["NewProjectGroupButton"].tap()
            app.textFields["GroupNameField"].tap()
            
            app.textFields["GroupNameField"].typeText(group.name)
            app.buttons["SaveGroup"].tap()
        }
            
        // MARK: Fill projects
        for project in localeData.projects {
            app.buttons["NewProjectButton"].tap()
            app.textFields["ProjectNameField"].tap()
            app.textFields["ProjectNameField"].typeText(project.name)
            
            if project.isSimpleList {
                app.switches["CreateSimpleList"].children(matching: .switch).element.tap()
            }
            
            app.buttons["SaveProject"].tap()
            
            // Add to group
            if let group = project.group {
                app.buttons[project.name].press(
                        forDuration: 1.6)
                
                app.buttons[localeData.addGroup].tap()

                app.collectionViews.buttons["\(group)ContextMenuButton"].tap()
            }
            
            // Move to project
            app.buttons[project.name].tap()
                            
            // MARK: Fill tasks
            for task in project.tasks {
                app.navigationBars[project.name]
                    .buttons["AddTaskToCurrentListButton"].tap()
                
                app.textFields["TaskName"].tap()
                app.textFields["TaskName"].typeText(task.name)
                
                if task.dueToday {
                    app/*@START_MENU_TOKEN@*/.staticTexts["Due Date"]/*[[".buttons[\"DueDate\"].staticTexts",".buttons.staticTexts[\"Due Date\"]",".staticTexts[\"Due Date\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
                    app/*@START_MENU_TOKEN@*/.buttons["todayButton"]/*[[".cells",".buttons[\"Today\"]",".buttons[\"todayButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
                }
                
                app.buttons["SaveTask"].tap()
                
                if let status = task.status {
                    print(app.debugDescription)
                    
                    app.collectionViews.staticTexts[task.name].press(forDuration: 1.6)

                    snapshot("03TaskMenu")
                    app.collectionViews.buttons[localeData.moveToStatus].tap()
                    app.collectionViews.buttons["\(status)ContextMenuButton"].tap()
                }
            }
            
            // Switch to board view
            if project.isBoard {
                app.navigationBars[project.name]
                    .segmentedControls["ProjectViewMode"].tap()
                app.navigationBars[project.name]
                    .segmentedControls["ProjectViewMode"].buttons["rectangle.split.3x1"].tap()
                
                if model.lowercased().contains("ipad") {
                    app.buttons[localeData.hideSidebar].firstMatch.tap()
                }
                snapshot("04ProjectView")
                
                if model.lowercased().contains("ipad") {
                    app.buttons[localeData.showSidebar].firstMatch.tap()
                }
            }
            
            if !model.lowercased().contains("ipad") {
                app.navigationBars[project.name].buttons[localeData.back].tap()
            }
        }

        snapshot("02SectionsPanel")

        app.buttons["TodayNavButton"].tap()

        app.buttons["FocusSection"].tap()

        snapshot("05FocusTasksView")

        app.collectionViews.buttons[
            "\(localeData.taskToFocus)PlayButton"
        ].tap()

        let exp = expectation(description: "Test after 5 seconds")
        _ = XCTWaiter.wait(for: [exp], timeout: 5.0)

        snapshot("06FocusTimerView")

        app.buttons["TasksSection"].tap()

        if model.lowercased().contains("iphone") {
            app.collectionViews.containing(
                .other,
                identifier: localeData.scroll
            ).element.swipeDown()
        }

        let exp2 = expectation(description: "Test after 5 seconds")
        _ = XCTWaiter.wait(for: [exp2], timeout: 5.0)

        snapshot("01TodayScreen")

        app.buttons["AddTaskToInboxButton"].tap()
        app.textFields["TaskName"].tap()
        let exp3 = expectation(description: "Test after 5 seconds")
        _ = XCTWaiter.wait(for: [exp3], timeout: 2.0)

        app.textFields["TaskName"].typeText(localeData.inboxTask)
        snapshot("07InboxTask")
        app.buttons[
            "SaveTask"
        ].tap()

        let exp4 = expectation(description: "Test after 5 seconds")
        _ = XCTWaiter.wait(for: [exp4], timeout: 5.0)
    }
}
// swiftlint:enable function_body_length

extension XCUIElement {
    func forceTap() {
        coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }
}

private struct LocaleData: Codable {
    let locale: String
    let today: String
    let back: String
    let addGroup: String
    let moveToStatus: String
    let hideSidebar: String
    let showSidebar: String
    let taskToFocus: String
    let scroll: String
    let inboxTask: String
    let groups: [GroupData]
    let projects: [ProjectData]
}

private struct GroupData: Codable {
    let name: String
}

private struct ProjectData: Codable {
    let name: String
    let isSimpleList: Bool
    let isBoard: Bool
    let group: String?
    let tasks: [TaskData]
}

private struct TaskData: Codable {
    let name: String
    let status: String?
    let dueToday: Bool
}
