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
            var result: [T] = try dataContainer.mainContext.fetch(descriptor)
            return result
        } catch {
            print("Fetch failed")
        }
        return []
    }

    @MainActor func testAddTaskToInbox() throws {
        // MARK: Adding task to Inbox
        let task = Todo(name: "Make soup",
                        dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
                        link: "https://google.com",
                        repeation: .daily,
                        priority: 2)
        dataContainer.mainContext.insert(task)
        
        var tasks: [Todo] = fetchData()
        
        XCTAssertEqual(tasks.count, 1, "There should be 1 task.")
        
        if let date = task.dueDate {
            XCTAssertFalse(Calendar.current.isDateInToday(date), "There shouldn't due date be in today")
        }
        
        if let newTask = task.complete() {
            dataContainer.mainContext.insert(newTask)
            if let date = newTask.dueDate {
                XCTAssertTrue(Calendar.current.isDateInToday(date), "There should due date be in today")
            }
        }
        
        tasks = fetchData()
        
        XCTAssertEqual(tasks.count, 2, "There should be 2 task.")
    }
}
