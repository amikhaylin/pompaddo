//
//  PomPadDoMacTests.swift
//  PomPadDoMacTests
//
//  Created by Andrey Mikhaylin on 13.02.2024.
//
// swiftlint:disable function_body_length

import Testing
import Foundation
import SwiftData
@testable import PomPadDo

@Suite
final class PomPadDoTests {
    let dataContainer: ModelContainer

    init() throws {
        dataContainer = try ModelContainer(for: Schema([Todo.self, Project.self]),
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
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

    @Test
    @MainActor
    func addTaskToInbox() throws {
        clearTasks()
        var tasks: [Todo] = fetchData()
        #expect(tasks.count == 0)
        
        // Adding task to Inbox
        let task = Todo(name: "Make soup",
                        dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
                        link: "https://google.com",
                        repeation: .daily,
                        priority: 2)
        dataContainer.mainContext.insert(task)
        
        tasks = fetchData()
        
        #expect(tasks.count == 1)

        let date = try #require(task.dueDate)
        #expect(!Calendar.current.isDateInToday(date))
        
        // Repeating
        #expect(task.completionDate == nil)
        
        task.complete(modelContext: dataContainer.mainContext)
        let completionDate = try #require(task.completionDate)
        #expect(Calendar.current.isDateInToday(completionDate))
        
        tasks = fetchData()
        
        #expect(tasks.count == 2)
    }
    
    @Test
    @MainActor
    func taskCompletionAndReactivation() throws {
        clearTasks()
        
        // Adding task to Inbox
        let task = Todo(name: "Make soup",
                        dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()))
        dataContainer.mainContext.insert(task)
        
        #expect(!task.completed)
        #expect(task.completionDate == nil)
        
        task.complete(modelContext: dataContainer.mainContext)
        
        #expect(task.completed)
        #expect(task.completionDate != nil)
        
        task.reactivate()
        
        #expect(!task.completed)
        #expect(task.completionDate == nil)
    }
    
    @Test
    @MainActor
    func addAndDeleteSubtask() throws {
        clearTasks()
        var tasks: [Todo] = fetchData()
        #expect(tasks.count == 0)
        
        let task = Todo(name: "Make soup")
        dataContainer.mainContext.insert(task)
        
        tasks = fetchData()
        
        #expect(tasks.count == 1)
        
        var subtask = Todo(name: "Buy potatoes 1", parentTask: task)
        task.subtasks?.append(subtask)
        dataContainer.mainContext.insert(subtask)

        tasks = fetchData()

        #expect(tasks.count == 2) // main task + subtask
        #expect(task.visibleSubtasks?.count == 1)
        
        // Mark subtask as deleted
        TasksQuery.deleteTask(task: subtask)
        
        tasks = fetchData()
        #expect(tasks.count == 2) // main task + subtask
        #expect(task.subtasks?.count == 1)
        #expect(task.visibleSubtasks == nil || task.visibleSubtasks?.count == 0)

        // Real subtask deletion
        TasksQuery.eraseTask(context: dataContainer.mainContext,
                              task: subtask)
        
        tasks = fetchData()
        
        #expect(task.subtasks?.count == 0)
        #expect(tasks.count == 1)

        subtask = Todo(name: "Buy potatoes 2", parentTask: task)
        task.subtasks?.append(subtask)
        dataContainer.mainContext.insert(subtask)

        tasks = fetchData()

        #expect(tasks.count == 2)
        
        // Delete parent task
        TasksQuery.eraseTask(context: dataContainer.mainContext,
                              task: task)
        
        tasks = fetchData()
        
        if let tempTask = tasks.first {
            print("\(tempTask.name)")
        }
        
        #expect(tasks.count == 0)
    }
    
    @Test
    @MainActor
    func dublicatingSubtasks() throws {
        clearTasks()
        var tasks: [Todo] = fetchData()
        #expect(tasks.count == 0)
        
        let task = Todo(name: "Make soup")
        dataContainer.mainContext.insert(task)
        
        tasks = fetchData()
        #expect(tasks.count == 1)
        
        let subtask = Todo(name: "Buy potatoes 1", parentTask: task)
        task.subtasks?.append(subtask)
        dataContainer.mainContext.insert(subtask)

        tasks = fetchData()
        #expect(tasks.count == 2)
        
        let newTask = task.copy(modelContext: dataContainer.mainContext)
        newTask.name = "Make taco"
        newTask.reconnect()
        dataContainer.mainContext.insert(newTask)
        
        tasks = fetchData()
        #expect(tasks.count == 4)
        
        print("4 tasks")
        for task in tasks {
            task.printInfo()
        }
        
        TasksQuery.eraseTask(context: dataContainer.mainContext,
                              task: task)
        
        tasks = fetchData()
        
        #expect(tasks.count == 2)
    }
    
    @Test
    @MainActor
    func projects() throws {
        clearTasks()
        var tasks: [Todo] = fetchData()
        #expect(tasks.count == 0)
        
        clearProjects()
        var projects: [Project] = fetchData()
        #expect(projects.count == 0)
        
        clearStatuses()
        var statuses: [Status] = fetchData()
        #expect(statuses.count == 0)
        
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
        #expect(projects.count == 1)
        
        statuses = fetchData()
        #expect(statuses.count == 3 && project.getStatuses().count == 3)
        
        tasks = fetchData()
        #expect(tasks.count == 0)
        #expect(project.getTasks().count == 0)
        
        // Add task to project
        var task = Todo(name: "Some project task",
                        status: project.getDefaultStatus(),
                        project: project)
        dataContainer.mainContext.insert(task)
        
        tasks = fetchData()
        #expect(tasks.count == 1)
        #expect(project.getTasks().count == 1)
        
        // Delete task
        TasksQuery.deleteTask(task: task)

        tasks = fetchData()
        #expect(tasks.count == 1)
        #expect(project.getTasks().count == 0)
        
        TasksQuery.eraseTask(context: dataContainer.mainContext,
                              task: task)
        
        tasks = fetchData()
        #expect(tasks.count == 0)
        #expect(project.getTasks().count == 0)
        
        task = Todo(name: "Another project task",
                        status: project.getDefaultStatus(),
                        project: project)
        dataContainer.mainContext.insert(task)
        
        tasks = fetchData()
        #expect(tasks.count == 1)
        #expect(project.getTasks().count == 1)
        
        // Delete project with task
        project.deleteRelatives(context: dataContainer.mainContext)
        dataContainer.mainContext.delete(project)
        
        projects = fetchData()
        #expect(projects.count == 0)
        
        statuses = fetchData()
        #expect(statuses.count == 0)
        
        tasks = fetchData()
        #expect(tasks.count == 0)
    }
    
    @Test
    @MainActor
    func calculateEstimate() throws {
        clearTasks()
        let task = Todo(name: "Make soup",
                        dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()))
        
        task.priority = 3
        task.clarity = 1
        task.baseTimeHours = 1
        task.hasEstimate = true
        
        let estimate = task.calculateEstimate(1.7)
        
        #expect(estimate == 2)
    }
}
// swiftlint:enable function_body_length
