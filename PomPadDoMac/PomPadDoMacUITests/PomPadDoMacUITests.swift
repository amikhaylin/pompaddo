//
//  PomPadDoMacUITests.swift
//  PomPadDoMacUITests
//
//  Created by Andrey Mikhaylin on 13.02.2024.
//
// swiftlint:disable function_body_length

import XCTest

final class PomPadDoMacUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // TODO: Make UI tests
    func testMainWindow() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let moveButton = app/*@START_MENU_TOKEN@*/.outlines.matching(identifier: "Sidebar").buttons["Move"]/*[[".splitGroups[\"SwiftUI.ModifiedContent<PomPadDo.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Swift.Optional<PomPadDo.Refresher>>>-1-AppWindow-1, SidebarNavigationSplitView\"]",".groups",".scrollViews.outlines.matching(identifier: \"Sidebar\")",".outlineRows",".cells.buttons[\"Move\"]",".buttons[\"Move\"]",".outlines.matching(identifier: \"Sidebar\")"],[[[-1,6,3],[-1,2,3],[-1,1,2],[-1,0,1]],[[-1,6,3],[-1,2,3],[-1,1,2]],[[-1,6,3],[-1,2,3]],[[-1,5],[-1,4],[-1,3,4]],[[-1,5],[-1,4]]],[0,0]]@END_MENU_TOKEN@*/
        moveButton.click()
        
        let inboxCell = app.outlines.matching(identifier: "Sidebar").cells.containing(.button, identifier: "Inbox").element
        inboxCell.typeText("🦝Personal")
        
        let sheetsQuery = app.sheets
        let okButton = sheetsQuery/*@START_MENU_TOKEN@*/.buttons["OK"]/*[[".groups.buttons[\"OK\"]",".buttons[\"OK\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        okButton.click()
        moveButton.click()
        inboxCell.typeText("🏢Work")
        okButton.click()
        
        let addButton = app/*@START_MENU_TOKEN@*/.outlines.matching(identifier: "Sidebar").buttons["Add"]/*[[".splitGroups[\"SwiftUI.ModifiedContent<PomPadDo.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Swift.Optional<PomPadDo.Refresher>>>-1-AppWindow-1, SidebarNavigationSplitView\"]",".groups",".scrollViews.outlines.matching(identifier: \"Sidebar\")",".outlineRows",".cells.buttons[\"Add\"]",".buttons[\"Add\"]",".outlines.matching(identifier: \"Sidebar\")"],[[[-1,6,3],[-1,2,3],[-1,1,2],[-1,0,1]],[[-1,6,3],[-1,2,3],[-1,1,2]],[[-1,6,3],[-1,2,3]],[[-1,5],[-1,4],[-1,3,4]],[[-1,5],[-1,4]]],[0,0]]@END_MENU_TOKEN@*/
        addButton.click()
        inboxCell.typeText("🚗 Car")
        
        let switch2 = sheetsQuery.groups.children(matching: .switch).element
        switch2.click()
        okButton.click()
        app.outlines.matching(identifier: "Sidebar").buttons["🚗 Car"].rightClick()
        app.outlines.matching(identifier: "Sidebar").menuItems["🦝Personal"].click()
        addButton.click()
        inboxCell.typeText("❤️Health")
        switch2.click()
        okButton.click()
        app.outlines.matching(identifier: "Sidebar").buttons["❤️Health"].rightClick()
        app.outlines.matching(identifier: "Sidebar").menuItems["🦝Personal"].click()
        addButton.click()
        inboxCell.typeText("💻John’s project")
        okButton.click()
        app.outlines.matching(identifier: "Sidebar").buttons["💻John’s project"].rightClick()
        app.outlines.matching(identifier: "Sidebar").menuItems["🏢Work"].click()
        
        let addtocurrentlistButton = app.toolbars/*@START_MENU_TOKEN@*/.children(matching: .button)["AddToCurrentList"].children(matching: .button)["AddToCurrentList"]/*[[".children(matching: .button)[\"Add task to current list\"]",".children(matching: .button)[\"AddToCurrentList\"]"],[[[-1,1,1],[-1,0,1]],[[-1,1],[-1,0]]],[0,0]]@END_MENU_TOKEN@*/
        addtocurrentlistButton.click()
        app.outlines.cells.containing(.button, identifier: "Square").element.click()
        
        let groupsQuery = app/*@START_MENU_TOKEN@*/.groups/*[[".splitGroups[\"SwiftUI.ModifiedContent<PomPadDo.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Swift.Optional<PomPadDo.Refresher>>>-1-AppWindow-1, SidebarNavigationSplitView\"]",".splitGroups",".scrollViews.groups",".groups"],[[[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/
        let edittasknameTextField = groupsQuery.textFields["EditTaskName"]
        edittasknameTextField.click()
        
        inboxCell.typeText("Read a book")
        
        let edittaskrepeationPopUpButton = groupsQuery.popUpButtons["EditTaskRepeation"]
        edittaskrepeationPopUpButton.click()
        app/*@START_MENU_TOKEN@*/.groups.menuItems["Daily"]/*[[".splitGroups[\"SwiftUI.ModifiedContent<PomPadDo.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Swift.Optional<PomPadDo.Refresher>>>-1-AppWindow-1, SidebarNavigationSplitView\"]",".splitGroups",".scrollViews.groups",".popUpButtons[\"EditTaskRepeation\"]",".menus.menuItems[\"Daily\"]",".menuItems[\"Daily\"]",".groups"],[[[-1,6,3],[-1,2,3],[-1,1,2],[-1,0,1]],[[-1,6,3],[-1,2,3],[-1,1,2]],[[-1,6,3],[-1,2,3]],[[-1,5],[-1,4],[-1,3,4]],[[-1,5],[-1,4]]],[0,0]]@END_MENU_TOKEN@*/.click()
        
        app.outlines.matching(identifier: "Sidebar").buttons["🚗 Car"].click()
        app.toolbars.children(matching: .button)["Add task to current list"].children(matching: .button)["Add task to current list"].click()
        app/*@START_MENU_TOKEN@*/.groups/*[[".splitGroups[\"SwiftUI.ModifiedContent<PomPadDo.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Swift.Optional<PomPadDo.Refresher>>>-1-AppWindow-1, SidebarNavigationSplitView\"]",".splitGroups",".scrollViews.groups",".groups"],[[[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.textFields["EditTaskName"].click()
        app/*@START_MENU_TOKEN@*/.outlines.matching(identifier: "Sidebar").cells.containing(.button, identifier:"Inbox").element/*[[".splitGroups[\"SwiftUI.ModifiedContent<PomPadDo.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Swift.Optional<PomPadDo.Refresher>>>-1-AppWindow-1, SidebarNavigationSplitView\"]",".groups",".scrollViews.outlines.matching(identifier: \"Sidebar\")",".outlineRows.cells.containing(.button, identifier:\"Inbox\").element",".cells.containing(.button, identifier:\"Inbox\").element",".outlines.matching(identifier: \"Sidebar\")"],[[[-1,5,3],[-1,2,3],[-1,1,2],[-1,0,1]],[[-1,5,3],[-1,2,3],[-1,1,2]],[[-1,5,3],[-1,2,3]],[[-1,4],[-1,3]]],[0,0]]@END_MENU_TOKEN@*/.typeText("Maintenance")
        app.groups.buttons["Set due Date"].click()
        
        app.outlines.matching(identifier: "Sidebar").buttons["❤️Health"].click()
        app.toolbars.children(matching: .button)["Add task to current list"].children(matching: .button)["Add task to current list"].click()
        app/*@START_MENU_TOKEN@*/.groups/*[[".splitGroups[\"SwiftUI.ModifiedContent<PomPadDo.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Swift.Optional<PomPadDo.Refresher>>>-1-AppWindow-1, SidebarNavigationSplitView\"]",".splitGroups",".scrollViews.groups",".groups"],[[[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.textFields["EditTaskName"].click()
        app/*@START_MENU_TOKEN@*/.outlines.matching(identifier: "Sidebar").cells.containing(.button, identifier:"Inbox").element/*[[".splitGroups[\"SwiftUI.ModifiedContent<PomPadDo.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Swift.Optional<PomPadDo.Refresher>>>-1-AppWindow-1, SidebarNavigationSplitView\"]",".groups",".scrollViews.outlines.matching(identifier: \"Sidebar\")",".outlineRows.cells.containing(.button, identifier:\"Inbox\").element",".cells.containing(.button, identifier:\"Inbox\").element",".outlines.matching(identifier: \"Sidebar\")"],[[[-1,5,3],[-1,2,3],[-1,1,2],[-1,0,1]],[[-1,5,3],[-1,2,3],[-1,1,2]],[[-1,5,3],[-1,2,3]],[[-1,4],[-1,3]]],[0,0]]@END_MENU_TOKEN@*/.typeText("Workout")
        app.groups.buttons["Set due Date"].click()

        app.outlines.matching(identifier: "Sidebar").buttons["💻John’s project"].click()
        app.toolbars.children(matching: .button)["Add task to current list"].children(matching: .button)["Add task to current list"].click()
        app/*@START_MENU_TOKEN@*/.groups/*[[".splitGroups[\"SwiftUI.ModifiedContent<PomPadDo.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Swift.Optional<PomPadDo.Refresher>>>-1-AppWindow-1, SidebarNavigationSplitView\"]",".splitGroups",".scrollViews.groups",".groups"],[[[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.textFields["EditTaskName"].click()
        app/*@START_MENU_TOKEN@*/.outlines.matching(identifier: "Sidebar").cells.containing(.button, identifier:"Inbox").element/*[[".splitGroups[\"SwiftUI.ModifiedContent<PomPadDo.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Swift.Optional<PomPadDo.Refresher>>>-1-AppWindow-1, SidebarNavigationSplitView\"]",".groups",".scrollViews.outlines.matching(identifier: \"Sidebar\")",".outlineRows.cells.containing(.button, identifier:\"Inbox\").element",".cells.containing(.button, identifier:\"Inbox\").element",".outlines.matching(identifier: \"Sidebar\")"],[[[-1,5,3],[-1,2,3],[-1,1,2],[-1,0,1]],[[-1,5,3],[-1,2,3],[-1,1,2]],[[-1,5,3],[-1,2,3]],[[-1,4],[-1,3]]],[0,0]]@END_MENU_TOKEN@*/.typeText("Design data model")
        app/*@START_MENU_TOKEN@*/.groups.radioButtons["Medium"]/*[[".splitGroups[\"SwiftUI.ModifiedContent<PomPadDo.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Swift.Optional<PomPadDo.Refresher>>>-1-AppWindow-1, SidebarNavigationSplitView\"]",".splitGroups",".scrollViews.groups",".radioGroups.radioButtons[\"Medium\"]",".radioButtons[\"Medium\"]",".groups"],[[[-1,5,3],[-1,2,3],[-1,1,2],[-1,0,1]],[[-1,5,3],[-1,2,3],[-1,1,2]],[[-1,5,3],[-1,2,3]],[[-1,4],[-1,3]]],[0,0]]@END_MENU_TOKEN@*/.click()
        app/*@START_MENU_TOKEN@*/.groups/*[[".splitGroups[\"SwiftUI.ModifiedContent<PomPadDo.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Swift.Optional<PomPadDo.Refresher>>>-1-AppWindow-1, SidebarNavigationSplitView\"]",".splitGroups",".scrollViews.groups",".groups"],[[[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.buttons["Estimate"].click()
        app/*@START_MENU_TOKEN@*/.groups.radioButtons["Half clear"]/*[[".splitGroups[\"SwiftUI.ModifiedContent<PomPadDo.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Swift.Optional<PomPadDo.Refresher>>>-1-AppWindow-1, SidebarNavigationSplitView\"]",".splitGroups",".scrollViews.groups",".radioGroups.radioButtons[\"Half clear\"]",".radioButtons[\"Half clear\"]",".groups"],[[[-1,5,3],[-1,2,3],[-1,1,2],[-1,0,1]],[[-1,5,3],[-1,2,3],[-1,1,2]],[[-1,5,3],[-1,2,3]],[[-1,4],[-1,3]]],[0,0]]@END_MENU_TOKEN@*/.click()
        app/*@START_MENU_TOKEN@*/.groups/*[[".splitGroups[\"SwiftUI.ModifiedContent<PomPadDo.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Swift.Optional<PomPadDo.Refresher>>>-1-AppWindow-1, SidebarNavigationSplitView\"]",".splitGroups",".scrollViews.groups",".groups"],[[[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.popUpButtons["1"].click()
        app/*@START_MENU_TOKEN@*/.groups.menuItems["3"]/*[[".splitGroups[\"SwiftUI.ModifiedContent<PomPadDo.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Swift.Optional<PomPadDo.Refresher>>>-1-AppWindow-1, SidebarNavigationSplitView\"]",".splitGroups",".scrollViews.groups",".popUpButtons[\"1\"]",".menus.menuItems[\"3\"]",".menuItems[\"3\"]",".groups"],[[[-1,6,3],[-1,2,3],[-1,1,2],[-1,0,1]],[[-1,6,3],[-1,2,3],[-1,1,2]],[[-1,6,3],[-1,2,3]],[[-1,5],[-1,4],[-1,3,4]],[[-1,5],[-1,4]]],[0,0]]@END_MENU_TOKEN@*/.click()
        app.groups.buttons["Set due Date"].click()

        app.outlines.matching(identifier: "Sidebar").buttons["Today"].click()
        
        
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Filled projects and tasks"
        attachment.lifetime = .keepAlways
        add(attachment)
        
//        app.buttons["AddToCurrentList"].firstMatch.tap()
        
//        print(app.debugDescription)
    }
    
    func testAddSubtasks() throws {
        let app = XCUIApplication()
        app.launch()
        
        
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
