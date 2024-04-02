//
//  GetTasks.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 13.03.2024.
//

import SwiftData
import SwiftUI

struct TasksQuery {
    static func predicate_today() -> Predicate<Todo> {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        return #Predicate<Todo> { task in
            if let date = task.dueDate {
                return date < tomorrow
            } else {
                return false
            }
        }
    }
    
    static func predicate_tomorrow() -> Predicate<Todo> {
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
    
    static func predicate_inbox() -> Predicate<Todo> {
        return #Predicate<Todo> { task in
            task.project == nil && task.parentTask == nil
        }
    }
}
