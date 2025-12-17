//
//  PomPadDoMacTests.swift
//  PomPadDoMacTests
//
//  Created by Andrey Mikhaylin on 13.02.2024.
//
// swiftlint:disable function_body_length

import XCTest
import SwiftData
@testable import PomPadDo

final class PomPadDoTests: XCTestCase {
    var dataContainer: ModelContainer!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dataContainer = try ModelContainer(for: Schema([Todo.self, Project.self]),
                                                        configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor func fetchData<T: PersistentModel>(sort: [SortDescriptor<T>]? = nil) -> [T] {
        do {
            var descriptor = FetchDescriptor<T>()
            if let sort = sort {
                descriptor.sortBy = sort
            }
            let result: [T] = try dataContainer.mainContext.fetch(descriptor)
            return result
        } catch {
            print("Fetch failed")
        }
        return []
    }
    
    @MainActor func clearTasks() {
        try? dataContainer.mainContext.delete(model: Todo.self)
        try? dataContainer.mainContext.save()
    }
    
    @MainActor func clearProjects() {
        try? dataContainer.mainContext.delete(model: Project.self)
        try? dataContainer.mainContext.save()
    }
    
    @MainActor func clearStatuses() {
        try? dataContainer.mainContext.delete(model: Status.self)
        try? dataContainer.mainContext.save()
    }

    @MainActor func testAddTaskToInbox() throws {
        clearTasks()
        var tasks: [Todo] = fetchData()
        XCTAssertEqual(tasks.count, 0, "There should be 0 task.")
        
        // Adding task to Inbox
        let task = Todo(name: "Make soup",
                        dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
                        link: "https://google.com",
                        repeation: .daily,
                        priority: 2)
        dataContainer.mainContext.insert(task)
        
        tasks = fetchData()
        
        XCTAssertEqual(tasks.count, 1, "There should be 1 task.")
        
        if let date = task.dueDate {
            XCTAssertFalse(Calendar.current.isDateInToday(date), "There shouldn't due date be in today")
        }
        
        // Repeating
        XCTAssertTrue(task.completionDate == nil, "Task shouldn't have any completion date")
        
        task.complete(modelContext: dataContainer.mainContext)
        XCTAssertTrue(task.completionDate != nil, "Task should have any completion date")
        if let completionDate = task.completionDate {
            XCTAssertTrue(Calendar.current.isDateInToday(completionDate), "There should completion date be in today")
        }
        
        tasks = fetchData()
        
        XCTAssertEqual(tasks.count, 2, "There should be 2 task.")
    }
    
    @MainActor func testTaskCompletionAndReactivation() throws {
        clearTasks()
//        
//        var tasks: [Todo] = fetchData()
//        XCTAssertEqual(tasks.count, 0, "There should be 0 task.")
        
        // Adding task to Inbox
        let task = Todo(name: "Make soup",
                        dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()))
        dataContainer.mainContext.insert(task)
        
        XCTAssertTrue(!task.completed, "Task is not completed")
        XCTAssertTrue(task.completionDate == nil, "Task hasn't completion date")
        
        task.complete(modelContext: dataContainer.mainContext)
        
        XCTAssertTrue(task.completed, "Task is completed")
        XCTAssertTrue(task.completionDate != nil, "Task has completion date")
        
        task.reactivate()
        
        XCTAssertTrue(!task.completed, "Task is not completed")
        XCTAssertTrue(task.completionDate == nil, "Task hasn't completion date")
    }
    
    @MainActor func testAddAndDeleteSubtask() throws {
        clearTasks()
        var tasks: [Todo] = fetchData()
        XCTAssertEqual(tasks.count, 0, "There should be 0 task.")
        
        let task = Todo(name: "Make soup")
        dataContainer.mainContext.insert(task)
        
        tasks = fetchData()
        
        XCTAssertEqual(tasks.count, 1, "There should be 1 task.")
        
        var subtask = Todo(name: "Buy potatoes 1", parentTask: task)
        task.subtasks?.append(subtask)
        dataContainer.mainContext.insert(subtask)

        tasks = fetchData()

        XCTAssertEqual(tasks.count, 2, "There should be 2 tasks.")
        
        // Delete subtask
        TasksQuery.eraseTask(context: dataContainer.mainContext,
                              task: subtask)
        
        tasks = fetchData()
        
        XCTAssertTrue(task.subtasks?.count == 0, "There should be 0 subtasks")
        XCTAssertEqual(tasks.count, 1, "There should be 1 task.")

        subtask = Todo(name: "Buy potatoes 2", parentTask: task)
        task.subtasks?.append(subtask)
        dataContainer.mainContext.insert(subtask)

        tasks = fetchData()

        XCTAssertEqual(tasks.count, 2, "There should be 2 tasks.")
        
        // Delete parent task
        TasksQuery.eraseTask(context: dataContainer.mainContext,
                              task: task)
        
        tasks = fetchData()
        
        if let tempTask = tasks.first {
            print("\(tempTask.name)")
        }
        
        XCTAssertEqual(tasks.count, 0, "There should be 0 task.")
    }
    
    @MainActor func testDublicatingSubtasks() throws {
        clearTasks()
        var tasks: [Todo] = fetchData()
        XCTAssertEqual(tasks.count, 0, "There should be 0 task.")
        
        let task = Todo(name: "Make soup")
        dataContainer.mainContext.insert(task)
        
        tasks = fetchData()
        XCTAssertEqual(tasks.count, 1, "There should be 1 task.")
        
        let subtask = Todo(name: "Buy potatoes 1", parentTask: task)
        task.subtasks?.append(subtask)
        dataContainer.mainContext.insert(subtask)

        tasks = fetchData()
        XCTAssertEqual(tasks.count, 2, "There should be 2 tasks.")
        
        let newTask = task.copy(modelContext: dataContainer.mainContext)
        newTask.name = "Make taco"
        newTask.reconnect()
        dataContainer.mainContext.insert(newTask)
        
        tasks = fetchData()
        XCTAssertEqual(tasks.count, 4, "There should be 4 tasks.")
        
        print("4 tasks")
        for task in tasks {
            task.printInfo()
        }
        
        TasksQuery.eraseTask(context: dataContainer.mainContext,
                              task: task)
        
        tasks = fetchData()
        
//        print("final")
//        for task in tasks {
//            task.printInfo()
//        }
        
        XCTAssertEqual(tasks.count, 2, "There should be 2 tasks.")
    }
    
    @MainActor func testProjects() throws {
        clearTasks()
        var tasks: [Todo] = fetchData()
        XCTAssertEqual(tasks.count, 0, "There should be 0 task.")
        
        clearProjects()
        var projects: [Project] = fetchData()
        XCTAssertEqual(projects.count, 0, "There should be 0 projects.")
        
        clearStatuses()
        var statuses: [Status] = fetchData()
        XCTAssertEqual(statuses.count, 0, "There should be 0 statuses.")
        
        let project = Project(name: "🦫 Some project")
        dataContainer.mainContext.insert(project)
        
        var order = 0
        for name in DefaultProjectStatuses.allCases {
            order += 1
            let status = Status(name: name.localizedString(),
                                order: order,
                                doCompletion: name.completion)
            dataContainer.mainContext.insert(status)
            project.statuses?.append(status)
        }
        
        projects = fetchData()
        XCTAssertEqual(projects.count, 1, "There should be 1 project.")
        
        statuses = fetchData()
        XCTAssertTrue(statuses.count == 3 && project.getStatuses().count == 3, "There should be 3 statuses")
        
        tasks = fetchData()
        XCTAssertEqual(tasks.count, 0, "There should be 0 task")
        XCTAssertEqual(project.getTasks().count, 0, "There should be 0 task")
        
        // Add task to project
        var task = Todo(name: "Some project task",
                        status: project.getDefaultStatus(),
                        project: project)
        dataContainer.mainContext.insert(task)
        
        tasks = fetchData()
        XCTAssertEqual(tasks.count, 1, "There should be 1 task")
        XCTAssertEqual(project.getTasks().count, 1, "There should be 1 task")
        
        // Delete task
        TasksQuery.eraseTask(context: dataContainer.mainContext,
                              task: task)
        
        tasks = fetchData()
        XCTAssertEqual(tasks.count, 0, "There should be 0 task")
        XCTAssertEqual(project.getTasks().count, 0, "There should be 0 task")
        
        task = Todo(name: "Another project task",
                        status: project.getDefaultStatus(),
                        project: project)
        dataContainer.mainContext.insert(task)
        
        tasks = fetchData()
        XCTAssertEqual(tasks.count, 1, "There should be 1 task")
        XCTAssertEqual(project.getTasks().count, 1, "There should be 1 task")
        
        // Delete project with task
        project.deleteRelatives(context: dataContainer.mainContext)
        dataContainer.mainContext.delete(project)
        
        projects = fetchData()
        XCTAssertEqual(projects.count, 0, "There should be 0 project.")
        
        statuses = fetchData()
        XCTAssertEqual(statuses.count, 0, "There should be 0 statuses")
        
        tasks = fetchData()
        XCTAssertEqual(tasks.count, 0, "There should be 0 task")
    }
    
    @MainActor func testCalculateEstimate() throws {
        clearTasks()
        let task = Todo(name: "Make soup",
                        dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()))
        
        task.priority = 3
        task.clarity = 1
        task.baseTimeHours = 1
        task.hasEstimate = true
        
        let estimate = task.calculateEstimate(1.7)
        
        XCTAssertEqual(estimate, 2, "Estimate value should be 2 hours")
    }
}
// swiftlint:enable function_body_length
