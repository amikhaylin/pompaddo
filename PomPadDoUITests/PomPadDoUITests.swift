//
//  PomPadDoUITests.swift
//  PomPadDoUITests
//
//  Created by Andrey Mikhaylin on 22.10.2025.
//
// swiftlint:disable function_body_length

import XCTest

final class PomPadDoUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()

        app.launchEnvironment = ["IS_TESTING": "YES"]
        
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor func testAFullCycle() throws {
        var locale: String!
        if app.buttons["Today"].exists {
            locale = "en"
        } else if app.buttons["Сегодня"].exists {
            locale = "ru"
        }
        
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

        // MARK: Create groups
        for group in localeData.groups {
            app.buttons["NewProjectGroupButton"].tap()
            app.sheets.textFields["GroupNameField"].tap()
            
            app.sheets.textFields["GroupNameField"].typeText(group.name)
            app.buttons["SaveGroup"].tap()
        }
            
        // MARK: Fill projects
        for project in localeData.projects {
            app.buttons["NewProjectButton"].tap()
            app.sheets.textFields["ProjectNameField"].tap()
            app.sheets.textFields["ProjectNameField"].typeText(project.name)
            
            if project.isSimpleList {
                app.sheets.switches["CreateSimpleList"].tap()
            }
            
            app.buttons["SaveProject"].tap()
            
            // Add to group
            if let group = project.group {
                app.buttons[project.name].rightClick()
                
                app.menuItems["\(group)ContextMenuButton"].click()
            }
            
            // Move to project
            app.buttons[project.name].tap()
                            
            // MARK: Fill tasks
            for task in project.tasks {
                app.buttons["AddTaskToCurrentListButton"].firstMatch.click()
                
                app.sheets.textFields["TaskName"].tap()
                app.sheets.textFields["TaskName"].typeText(task.name)
                
                if task.dueToday {
                    app.sheets.switches["DueToday"].tap()
                }
                
                app.buttons["SaveTask"].tap()
                
                if let status = task.status {
                    app.staticTexts[task.name].rightClick()

                    snapshot("Apple Macbook Pro 13 Space Gray-03TaskMenu")
                    app.menuItems["\(status)ContextMenuButton"].click()
                }
            }
            
            //Switch to board view
            if project.isBoard {
                app/*@START_MENU_TOKEN@*/.radioButtons["rectangle.split.3x1"]/*[[".radioGroups[\"View Mode\"].radioButtons",".radioGroups",".radioButtons[\"Column View\"]",".radioButtons[\"rectangle.split.3x1\"]"],[[[-1,3],[-1,2],[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
                
                snapshot("Apple Macbook Pro 13 Space Gray-04ProjectView")
            }
        }

        snapshot("Apple Macbook Pro 13 Space Gray-02SectionsPanel")

        app.buttons["TodayNavButton"].tap()

        app.statusItems.firstMatch.click()

        snapshot("Apple Macbook Pro 13 Space Gray-05FocusTasksView")

        app.buttons["\(localeData.taskToFocus)PlayButton"].firstMatch.click()

        let exp = expectation(description: "Test after 5 seconds")
        _ = XCTWaiter.wait(for: [exp], timeout: 5.0)

        snapshot("Apple Macbook Pro 13 Space Gray-06FocusTimerView")

        app.buttons["TodayNavButton"].tap()

        let exp2 = expectation(description: "Test after 5 seconds")
        _ = XCTWaiter.wait(for: [exp2], timeout: 5.0)

        snapshot("Apple Macbook Pro 13 Space Gray-01TodayScreen")

        app/*@START_MENU_TOKEN@*/.buttons["Add task to Inbox"].buttons["AddTaskToInboxButton"].firstMatch/*[[".buttons.matching(identifier: \"AddTaskToInboxButton\").element(boundBy: 1)",".buttons[\"Add task to Inbox\"]",".buttons.firstMatch",".buttons[\"Add task to Inbox\"].firstMatch",".buttons[\"AddTaskToInboxButton\"].firstMatch"],[[[-1,1,1],[-1,0]],[[-1,4],[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        app.sheets.textFields["TaskName"].tap()

        app.sheets.textFields["TaskName"].typeText(localeData.inboxTask)
        snapshot("Apple Macbook Pro 13 Space Gray-07InboxTask")
        app.buttons["SaveTask"].tap()

        let exp4 = expectation(description: "Test after 5 seconds")
        _ = XCTWaiter.wait(for: [exp4], timeout: 5.0)
    }
    
    private func snapshot(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
// swiftlint:enable function_body_length

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
