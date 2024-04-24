//
//  Todo.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 14.02.2024.
//

import Foundation
import SwiftData

enum RepeationMode: String, Identifiable, CaseIterable, Codable {
    var id: String { rawValue }
    
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

@Model
class Todo {
    var name: String = ""
    var dueDate: Date?
    var completed: Bool = false
    var status: Status?
    var note: String = ""
    var tomatoesCount: Int = 0
    var project: Project?
    var parentTask: Todo?
    var link: String = ""
    var repeation: RepeationMode = RepeationMode.none
    var priority: Int = 0
    var uid: String = UUID().uuidString
    var completionDate: Date?
    
    @Relationship(deleteRule: .cascade)
    var subtasks: [Todo]? = [Todo]()
    
    init(name: String,
         dueDate: Date? = nil,
         completed: Bool = false,
         status: Status? = nil,
         note: String = "",
         tomatoesCount: Int = 0,
         project: Project? = nil,
         subtasks: [Todo]? = [Todo](),
         parentTask: Todo? = nil,
         link: String = "",
         repeation: RepeationMode = RepeationMode.none,
         priority: Int = 0,
         completionDate: Date? = nil) {
        self.name = name
        self.dueDate = dueDate
        self.completed = completed
        self.status = status
        self.note = note
        self.tomatoesCount = tomatoesCount
        self.project = project
        self.subtasks = subtasks
        self.parentTask = parentTask
        self.link = link
        self.repeation = repeation
        self.priority = priority
        self.completionDate = completionDate
    }
}

extension Todo {
    func copy() -> Todo {
        let task = Todo(name: self.name,
                        dueDate: self.dueDate,
                        completed: self.completed,
                        status: self.status,
                        note: self.note,
                        tomatoesCount: self.tomatoesCount,
                        project: self.project,
                        subtasks: self.subtasks,
                        parentTask: self.parentTask,
                        link: self.link,
                        repeation: self.repeation,
                        completionDate: self.completionDate)
        return task
    }
    
    func reconnect() {
        if let project = self.project {
            project.tasks.append(self)
        }
        if let parentTask = self.parentTask {
            parentTask.subtasks?.append(self)
        }
    }
    
    func disconnect() {
        if let project = self.project, let index = project.tasks.firstIndex(of: self) {
            project.tasks.remove(at: index)
        }
        if let parentTask = self.parentTask, let index = parentTask.subtasks?.firstIndex(of: self) {
            parentTask.subtasks?.remove(at: index)
        }
    }
    
    func complete() -> Todo? {
        self.completed = true
        self.completionDate = Date()
        guard let dueDate = self.dueDate else { return nil }
        guard repeation != .none else { return nil }
        
        let newTask = self.copy()
        newTask.completed = false
        newTask.completionDate = nil
        switch repeation {
        case .none:
            break
        case .daily:
            newTask.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: dueDate))
        case .weekly:
            newTask.dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Calendar.current.startOfDay(for: dueDate))
        case .monthly:
            newTask.dueDate = Calendar.current.date(byAdding: .month, value: 1, to: Calendar.current.startOfDay(for: dueDate))
        case .yearly:
            newTask.dueDate = Calendar.current.date(byAdding: .year, value: 1, to: Calendar.current.startOfDay(for: dueDate))
        }
        newTask.reconnect()
        
        return newTask
    }
    
    func reactivate() {
        self.completed = false
        self.completionDate = nil
    }
    
    // TODO: BE REMOVED WHEN `.cascade` is fixed
    func deleteSubtasks(context: ModelContext) {
        if let subtasks = self.subtasks {
            for task in subtasks {
                task.deleteSubtasks(context: context)
                context.delete(task)
            }
        }
    }
}
