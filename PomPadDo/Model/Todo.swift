//
//  Todo.swift
//  PomPadDoMac
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
    case custom = "Custom"
    
    func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

enum CustomRepeationType: String, Identifiable, CaseIterable, Codable {
    var id: String { rawValue }
    
    case days
    case months
    case years
    
    var calendarComponent: Calendar.Component {
        switch self {
        case .days:
            return .day
        case .months:
            return .month
        case .years:
            return .year
        }
    }
    
    func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

@Model
class Todo: Hashable {
    var name: String = ""
    var dueDate: Date?
    var completed: Bool = false
    @Relationship var status: Status?
    var note: String = ""
    var tomatoesCount: Int = 0
    @Relationship var project: Project?
    @Relationship var parentTask: Todo?
    var link: String = ""
    var repeation: RepeationMode = RepeationMode.none
    var priority: Int = 0
    var uid: String = UUID().uuidString
    var completionDate: Date?
    var alertDate: Date?
    var hasEstimate: Bool = false
    var clarity: Int = 0
    var baseTimeHours: Int = 0
    var customRepeatValue: Int = 2
    var customRepeatType: CustomRepeationType? = CustomRepeationType.days
    
    @Relationship(deleteRule: .cascade, inverse: \Todo.parentTask)
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
         completionDate: Date? = nil,
         alertDate: Date? = nil) {
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
        self.alertDate = alertDate
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid) // UUID
    }
}

extension Todo {
    func copy(modelContext: ModelContext) -> Todo {
        let task = Todo(name: self.name,
                        dueDate: self.dueDate,
                        completed: self.completed,
                        status: self.status,
                        note: self.note,
                        project: self.project,
                        parentTask: self.parentTask,
                        link: self.link,
                        repeation: self.repeation,
                        priority: self.priority,
                        completionDate: self.completionDate)
        task.customRepeatType = self.customRepeatType
        task.customRepeatValue = self.customRepeatValue
        if let subtasks = self.subtasks {
            for subtask in subtasks {
                let newSubtask = subtask.copy(modelContext: modelContext)
                newSubtask.parentTask = task
                task.subtasks?.append(newSubtask)
                modelContext.insert(newSubtask)
            }
        }
        return task
    }
    
    func reconnect() {
        if let project = self.project {
            project.tasks?.append(self)
        }
        if let parentTask = self.parentTask {
            parentTask.subtasks?.append(self)
        }
    }
    
    func disconnectFromAll() {
        if self.status != nil {
            self.status = nil
        }
        if self.project != nil {
            self.project = nil
        }
        if let parentTask = self.parentTask, let index = parentTask.subtasks?.firstIndex(of: self) {
            parentTask.subtasks?.remove(at: index)
        }
    }
    
    func disconnectFromParentTask() {
        if let parentTask = self.parentTask, let index = parentTask.subtasks?.firstIndex(of: self) {
            parentTask.subtasks?.remove(at: index)
        }
    }
    
    func complete(modelContext: ModelContext) {
        if repeation != .none {
            let newTask = self.copy(modelContext: modelContext)
            
            newTask.skip()

            modelContext.insert(newTask)
            newTask.reconnect()
            
            if let status = self.status {
                newTask.status = status
            }
        }
        
        self.completed = true
        self.completionDate = Date()
        
        if let project = self.project, project.completedMoving {
            if let status = project.getStatuses().first(where: { $0.doCompletion }) {
                self.status = status
            }
        }
    }
    
    func skip() {
        guard let dueDate = self.dueDate else { return }
        guard repeation != .none else { return }
        
        switch repeation {
        case .none:
            break
        case .daily:
            self.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: dueDate))
        case .weekly:
            self.dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Calendar.current.startOfDay(for: dueDate))
        case .monthly:
            self.dueDate = Calendar.current.date(byAdding: .month, value: 1, to: Calendar.current.startOfDay(for: dueDate))
        case .yearly:
            self.dueDate = Calendar.current.date(byAdding: .year, value: 1, to: Calendar.current.startOfDay(for: dueDate))
        case .custom:
            if let repeatType = self.customRepeatType {
                self.dueDate = Calendar.current.date(byAdding: repeatType.calendarComponent,
                                                        value: self.customRepeatValue,
                                                        to: Calendar.current.startOfDay(for: dueDate))
            }
        }
    }
    
    func nextWeek() {
        let dueDate = Date()
        
        let weekday = Calendar.current.component(.weekday, from: dueDate)
        let startWeek = Calendar.current.firstWeekday
        self.dueDate = Calendar.current.date(byAdding: .day,
                                             value: (7 - (weekday - startWeek)),
                                             to: Calendar.current.startOfDay(for: dueDate))
    }
    
    func reactivate() {
        self.completed = false
        self.completionDate = nil
    }
    
    // TODO: BE REMOVED WHEN `.cascade` is fixed
//    func deleteSubtasks(context: ModelContext) {
//        if let subtasks = self.subtasks {
//            for task in subtasks {
//                print("deleting subtask")
//                task.printInfo()
//                task.deleteSubtasks(context: context)
//                context.delete(task)
//            }
//        }
//    }
    
    func getTotalFocus() -> Int {
        var result: Int = self.tomatoesCount
        
        if let subtasks = self.subtasks {
            for subtask in subtasks {
                result += subtask.getTotalFocus()
            }
        }
        
        return result
    }
    
    func printInfo() {
        let name = self.name
        let uid = self.uid
        print("Task name: \(name) - \(uid)")
        
        if let parentTask = self.parentTask {
            let parentName = parentTask.name
            let parentUID = parentTask.uid
            print("parent: \(parentName) - \(parentUID)")
        }
        
        if let subtasks = self.subtasks {
            print("Subtasks begin")
            for subtask in subtasks {
                subtask.printInfo()
            }
            print("Subtasks end")
        }
    }
    
    func calculateEstimate(_ factor: Double) -> Int {
        if self.hasEstimate {
            var priorityValue = 0.0
            
            switch self.priority {
            case 3:
                priorityValue = 1.0 // High
            case 2:
                priorityValue = 1.5 // Medium
            case 1:
                priorityValue = 2 // Low
            default:
                priorityValue = 0.0
            }
            
            var clarityValue = 0.0
            
            switch self.clarity {
            case 1:
                clarityValue = 1.0 // Clear
            case 2:
                clarityValue = 1.5 // Half clear
            case 3:
                clarityValue = 2.0 // Not clear
            default:
                clarityValue = 0.0
            }
            
            return Int(ceil((Double(self.baseTimeHours) * clarityValue * priorityValue) * factor))
        }
        return 0
    }
    
    func sumEstimates(_ factor: Double) -> Int {
        var result = self.calculateEstimate(factor)
        if let subtasks = self.subtasks {
            for subtask in subtasks {
                result += subtask.sumEstimates(factor)
            }
        }
        return result
    }
    
    func moveToStatus(status: Status, 
                      project: Project,
                      context: ModelContext) {
        
        if self.parentTask != nil {
            self.disconnectFromParentTask()
            self.parentTask = nil
            self.project = project
        }
            
        if status.doCompletion {
            if !self.completed {
                self.complete(modelContext: context)
            }
        } else {
            self.reactivate()
        }
        
        if status.clearDueDate {
            self.dueDate = nil
        }
        
        self.status = status
    }
}
