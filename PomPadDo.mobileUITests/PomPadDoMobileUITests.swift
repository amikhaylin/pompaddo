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
        
        // MARK: Create groups
        if model.lowercased().contains("ipad") {
            app.navigationBars[locale == "ru" ? "Сегодня" : "Today"].buttons["ToggleSidebar"].tap()
        } else {
            app.navigationBars[locale == "ru" ? "Сегодня" : "Today"].buttons[locale == "ru" ? "Назад" : "Back"].tap()
        }

        print(app.debugDescription)

        app.buttons["NewProjectGroupButton"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование группы" : "Group name"].tap()
        
        app.popovers.textFields[locale == "ru" ? "Наименование группы" : "Group name"].typeText(locale == "ru" ? "🦝 Личное" : "🦝 Personal")
        app.buttons["SaveGroup"].tap()
        
        app.buttons["NewProjectGroupButton"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование группы" : "Group name"].tap()
        
        app.popovers.textFields[locale == "ru" ? "Наименование группы" : "Group name"].typeText(locale == "ru" ? "🏢 Работа" : "🏢 Work")
        app.buttons["SaveGroup"].tap()

        // MARK: Fill projects
        // MARK: Create project **Vacation Planning**
        app.buttons["NewProjectButton"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование проекта" : "Project name"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование проекта" : "Project name"].typeText(locale == "ru" ? "🏖️ Планирование отпуска" : "🏖️ Vacation Planning")
        
        app.popovers.switches["CreateSimpleList"].children(matching: .switch).element.tap()
        
        app.buttons["SaveProject"].tap()

        app.collectionViews.matching(identifier: locale == "ru" ? "Боковое меню" : "Sidebar").buttons[locale == "ru" ? "🏖️ Планирование отпуска" : "🏖️ Vacation Planning"].press(forDuration: 1.6)
        app.collectionViews.buttons[locale == "ru" ? "Добавить проект в группу" : "Add project to group"].tap()
        
        print(app.collectionViews.buttons.debugDescription)
        app.collectionViews.buttons["\(locale == "ru" ? "🦝 Личное" : "🦝 Personal")ContextMenuButton"].tap()
        
        // MARK: Create project **App Development**
        app.buttons["NewProjectButton"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование проекта" : "Project name"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование проекта" : "Project name"].typeText(locale == "ru" ? "📱Разработка приложения" : "📱App Development")
        
        app.buttons["SaveProject"].tap()

        app.collectionViews.matching(identifier: locale == "ru" ? "Боковое меню" : "Sidebar").buttons[locale == "ru" ? "📱Разработка приложения" : "📱App Development"].press(forDuration: 1.6)
        app.collectionViews.buttons[locale == "ru" ? "Добавить проект в группу" : "Add project to group"].tap()
        
        print(app.collectionViews.buttons.debugDescription)
        app.collectionViews.buttons["\(locale == "ru" ? "🏢 Работа" : "🏢 Work")ContextMenuButton"].tap()
        
        if model.lowercased().contains("ipad") {
            app.collectionViews.matching(identifier: locale == "ru" ? "Боковое меню" : "Sidebar").buttons[locale == "ru" ? "🏖️ Планирование отпуска" : "🏖️ Vacation Planning"].tap()
            
            app.otherElements["PopoverDismissRegion"].tap()
        } else {
            app.collectionViews.matching(identifier: locale == "ru" ? "Боковое меню" : "Sidebar").staticTexts[locale == "ru" ? "🏖️ Планирование отпуска" : "🏖️ Vacation Planning"].tap()
        }

        // MARK: Fill Vacation planning tasks
        app.navigationBars[locale == "ru" ? "🏖️ Планирование отпуска" : "🏖️ Vacation Planning"].buttons[locale == "ru" ? "Добавить задачу в текущий список" : "Add task to current list"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].typeText(locale == "ru" ? "Забронировать авиабилеты" : "Book airline tickets")
        app.popovers.switches["DueToday"].children(matching: .switch).element.tap()
        app.buttons["SaveTask"].tap()
        
        app.navigationBars[locale == "ru" ? "🏖️ Планирование отпуска" : "🏖️ Vacation Planning"].buttons[locale == "ru" ? "Добавить задачу в текущий список" : "Add task to current list"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].typeText(locale == "ru" ? "Найти и забронировать отель" : "Find and reserve a hotel")
        app.buttons["SaveTask"].tap()
        
        app.navigationBars[locale == "ru" ? "🏖️ Планирование отпуска" : "🏖️ Vacation Planning"].buttons[locale == "ru" ? "Добавить задачу в текущий список" : "Add task to current list"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].typeText(locale == "ru" ? "Составить список мест для посещения" : "Create a list of places to visit")
        app.buttons["SaveTask"].tap()
        
        app.navigationBars[locale == "ru" ? "🏖️ Планирование отпуска" : "🏖️ Vacation Planning"].buttons[locale == "ru" ? "Добавить задачу в текущий список" : "Add task to current list"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].typeText(locale == "ru" ? "Оформить туристическую страховку" : "Arrange travel insurance")
        app.buttons["SaveTask"].tap()
        
        if model.lowercased().contains("ipad") {
            app.navigationBars[locale == "ru" ? "🏖️ Планирование отпуска" : "🏖️ Vacation Planning"].buttons["ToggleSidebar"].tap()
        } else {
            app.navigationBars[locale == "ru" ? "🏖️ Планирование отпуска" : "🏖️ Vacation Planning"].buttons[locale == "ru" ? "Назад" : "Back"].tap()
        }
            
        // MARK: Fill App Development tasks
        if model.lowercased().contains("ipad") {
            app.collectionViews.matching(identifier: locale == "ru" ? "Боковое меню" : "Sidebar").buttons[locale == "ru" ? "📱Разработка приложения" : "📱App Development"].tap()
            
            app/*@START_MENU_TOKEN@*/.otherElements["PopoverDismissRegion"]/*[[".otherElements[\"dismiss popup\"]",".otherElements[\"PopoverDismissRegion\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        } else {
            app.collectionViews.matching(identifier: locale == "ru" ? "Боковое меню" : "Sidebar").staticTexts[locale == "ru" ? "📱Разработка приложения" : "📱App Development"].tap()
        }
        
        app.navigationBars[locale == "ru" ? "📱Разработка приложения" : "📱App Development"].buttons[locale == "ru" ? "Добавить задачу в текущий список" : "Add task to current list"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].typeText(locale == "ru" ? "Определить функциональные требования" : "Define functional requirements")
        app.buttons["SaveTask"].tap()
        
        app.navigationBars[locale == "ru" ? "📱Разработка приложения" : "📱App Development"].buttons[locale == "ru" ? "Добавить задачу в текущий список" : "Add task to current list"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].typeText(locale == "ru" ? "Создать дизайн интерфейса" : "Create interface design")
        app.popovers.switches["DueToday"].children(matching: .switch).element.tap()
        app.buttons["SaveTask"].tap()
        
        app.navigationBars[locale == "ru" ? "📱Разработка приложения" : "📱App Development"].buttons[locale == "ru" ? "Добавить задачу в текущий список" : "Add task to current list"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].typeText(locale == "ru" ? "Протестировать бета-версию" : "Test the beta version")
        app.buttons["SaveTask"].tap()
        
        app.navigationBars[locale == "ru" ? "📱Разработка приложения" : "📱App Development"].buttons[locale == "ru" ? "Добавить задачу в текущий список" : "Add task to current list"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].tap()
        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].typeText(locale == "ru" ? "Запустить приложение в App Store" : "Launch the app in the App Store")
        app.buttons["SaveTask"].tap()
        
        // MARK: Switch project view
        app.navigationBars[locale == "ru" ? "📱Разработка приложения" : "📱App Development"].segmentedControls["ProjectViewMode"].tap()
        app.navigationBars[locale == "ru" ? "📱Разработка приложения" : "📱App Development"].segmentedControls["ProjectViewMode"].buttons["rectangle.split.3x1"].tap()
        
        app.scrollViews.otherElements.collectionViews.staticTexts[locale == "ru" ? "Определить функциональные требования" : "Define functional requirements"].press(forDuration: 1.6)
        
        snapshot("03TaskMenu")
        app.collectionViews.buttons[locale == "ru" ? "Переместить в состояние" : "Move to status"].tap()
        app.collectionViews.buttons["CompletedContextMenuButton"].tap()
        
        snapshot("04ProjectView")
        
        if model.lowercased().contains("ipad") {
            app.navigationBars[locale == "ru" ? "📱Разработка приложения" : "📱App Development"].buttons["ToggleSidebar"].tap()
        } else {
            app.navigationBars[locale == "ru" ? "📱Разработка приложения" : "📱App Development"].buttons[locale == "ru" ? "Назад" : "Back"].tap()
        }
        
        snapshot("02SectionsPanel")
        
        app.collectionViews.matching(identifier: locale == "ru" ? "Боковое меню" : "Sidebar").staticTexts[locale == "ru" ? "Сегодня" : "Today"].tap()

        app.buttons["FocusSection"].tap()
        
        snapshot("05FocusTasksView")
        
        app.collectionViews.buttons["\(locale == "ru" ? "Создать дизайн интерфейса" : "Create interface design")PlayButton"].tap()
        
        let exp = expectation(description: "Test after 5 seconds")
        _ = XCTWaiter.wait(for: [exp], timeout: 5.0)

        snapshot("06FocusTimerView")
        
        app.buttons["TasksSection"].tap()
        
        if model.lowercased().contains("iphone") {
            app.collectionViews.containing(.other, identifier: locale == "ru" ? "Вертикальная полоса прокрутки, 1 страница" : "Vertical scroll bar, 1 page").element.swipeDown()
        }
        
        let exp2 = expectation(description: "Test after 5 seconds")
        _ = XCTWaiter.wait(for: [exp2], timeout: 5.0)
        
        snapshot("01TodayScreen")
        
        app.buttons["AddTaskToInboxButton"].tap()
        app.popovers.textFields["TaskName"].tap()
        let exp3 = expectation(description: "Test after 5 seconds")
        _ = XCTWaiter.wait(for: [exp3], timeout: 2.0)

        app.popovers.textFields["TaskName"].typeText(locale == "ru" ? "Купить кофе" : "Buy coffee")

//        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].tap()
//        app.popovers.textFields[locale == "ru" ? "Наименование задачи" : "Task name"].typeText(locale == "ru" ? "Купить кофе" : "Buy coffee")
        snapshot("07InboxTask")
        app/*@START_MENU_TOKEN@*/.buttons["SaveTask"]/*[[".otherElements[\"SaveTask\"].buttons.firstMatch",".otherElements",".buttons[\"OK\"]",".buttons[\"SaveTask\"]"],[[[-1,3],[-1,2],[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.tap()
        
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
