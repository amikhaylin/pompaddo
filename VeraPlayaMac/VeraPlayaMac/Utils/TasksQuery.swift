//
//  GetTasks.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 13.03.2024.
//

import SwiftData
import SwiftUI

struct TasksQuery {
    static func predicateToday() -> Predicate<Todo> {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        return #Predicate<Todo> { task in
            if let date = task.dueDate {
                return date < tomorrow
            } else {
                return false
            }
        }
    }
    
    static func predicateTodayActive() -> Predicate<Todo> {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        return #Predicate<Todo> { task in
            if let date = task.dueDate {
                return date < tomorrow && !task.completed
            } else {
                return false
            }
        }
    }
    
    static func predicateTomorrow() -> Predicate<Todo> {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        let future = Calendar.current.date(byAdding: .day, value: 1, to: tomorrow)!
        return #Predicate<Todo> { task in
            if let date = task.dueDate {
                return date >= tomorrow && date < future
            } else {
                return false
            }
        }
    }
    
    static func predicateInbox() -> Predicate<Todo> {
        return #Predicate<Todo> { task in
            task.project == nil && task.parentTask == nil
        }
    }
    
    static func defaultTaskSortDescriptor() -> [SortDescriptor<Todo>] {
        return [SortDescriptor(\Todo.dueDate), SortDescriptor(\Todo.priority, order: .reverse)]
    }
    
    static func defaultSorting(_ first: Todo, _ second: Todo) -> Bool {
        if first.dueDate == nil && second.dueDate == nil {
            return (first.priority > second.priority)
        }
        if first.dueDate == nil && second.dueDate != nil { return false }
        if first.dueDate != nil && second.dueDate == nil { return true }
        if first.dueDate! == second.dueDate! {
            return (first.priority > second.priority)
        }
        return (first.dueDate! < second.dueDate!)
    }
    
    static func deleteTask(context: ModelContext, task: Todo) {
        task.disconnect()
        task.deleteSubtasks(context: context)
        context.delete(task)
    }
}
