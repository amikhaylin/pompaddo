//
//  VeraPlayaMacTests.swift
//  VeraPlayaMacTests
//
//  Created by Andrey Mikhaylin on 13.02.2024.
//

import XCTest
import SwiftData
@testable import VeraPlayaMac

final class VeraPlayaMacTests: XCTestCase {
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

    @MainActor func testAddTaskToInbox() throws {
        clearTasks()
        var tasks: [Todo] = fetchData()
        XCTAssertEqual(tasks.count, 0, "There should be 0 task.")
        
        // MARK: Adding task to Inbox
        let task = Todo(name: "Make soup",
                        dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
                        link: "https://google.com",
                        repeation: .daily,
                        priority: 2)
        dataContainer.mainContext.insert(task)
        
        XCTAssertEqual(tasks.count, 1, "There should be 1 task.")
        
        if let date = task.dueDate {
            XCTAssertFalse(Calendar.current.isDateInToday(date), "There shouldn't due date be in today")
        }
        
        // MARK: Repeating
        
        if let newTask = task.complete() {
            dataContainer.mainContext.insert(newTask)
            if let date = newTask.dueDate {
                XCTAssertTrue(Calendar.current.isDateInToday(date), "There should due date be in today")
            }
        }
        
        tasks = fetchData()
        
        XCTAssertEqual(tasks.count, 2, "There should be 2 task.")
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
        
        // MARK: Delete subtask
        TasksQuery.deleteTask(context: dataContainer.mainContext,
                              task: subtask)
        
        tasks = fetchData()
        
        XCTAssertTrue(task.subtasks?.count == 0, "There should be 0 subtasks")
        XCTAssertEqual(tasks.count, 1, "There should be 1 task.")

        subtask = Todo(name: "Buy potatoes 2", parentTask: task)
        task.subtasks?.append(subtask)
        dataContainer.mainContext.insert(subtask)

        tasks = fetchData()

        XCTAssertEqual(tasks.count, 2, "There should be 2 tasks.")
        
        // MARK: Delete parent task
        TasksQuery.deleteTask(context: dataContainer.mainContext,
                              task: task)
        
        tasks = fetchData()
        
        if let tempTask = tasks.first {
            print("\(tempTask.name)")
        }
        
        XCTAssertEqual(tasks.count, 0, "There should be 0 task.")
    }
}
