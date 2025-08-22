//
//  GetTasks.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 13.03.2024.
//

import SwiftData
import SwiftUI

struct TasksQuery {
    static func checkToday(date: Date?) -> Bool {
        if let date = date {
            return Calendar.current.isDateInToday(date)
        } else {
            return true
        }
    }
    
    // TasksQuery.checkToday(date: $0.completionDate)
    static func predicateToday() -> Predicate<Todo> {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return #Predicate<Todo> { task in
            if let date = task.dueDate {
                return date < tomorrow
            } else if let completeDate = task.completionDate {
                return (completeDate >= today && completeDate < tomorrow)
            } else {
                return false
            }
        }
    }
    
    static func predicateTodayActive() -> Predicate<Todo> {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        return #Predicate<Todo> { task in
            if let date = task.dueDate {
                return (date < tomorrow && !task.completed)
            } else {
                return false
            }
        }
    }
    
    static func predicateTodayAssign() -> Predicate<Todo> {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return #Predicate<Todo> { task in
            if let date = task.dueDate {
                return date < tomorrow
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
    
    static func predicateTomorrowActive() -> Predicate<Todo> {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        let future = Calendar.current.date(byAdding: .day, value: 1, to: tomorrow)!
        return #Predicate<Todo> { task in
            if let date = task.dueDate {
                return date >= tomorrow && date < future && !task.completed
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
    
    static func predicateInboxActive() -> Predicate<Todo> {
        return #Predicate<Todo> { task in
            task.project == nil && task.parentTask == nil && !task.completed
        }
    }
    
    static func predicateAllTasks() -> Predicate<Todo> {
        return #Predicate<Todo> { _ in
            true
        }
    }
    
    static func predicateActive() -> Predicate<Todo> {
        return #Predicate<Todo> { task in
            !task.completed
        }
    }
    
    static func filterProjectToReview(_ project: Project) -> Bool {
        if project.showInReview == false {
            return false
        }
        let today = Date()
        if let dateToReview = Calendar.current.date(byAdding: .day,
                                                    value: project.reviewDaysCount,
                                                    to: project.reviewDate) {
            return Calendar.current.isDateInToday(dateToReview) || dateToReview < today
        } else {
            return false
        }
    }
    
    static func predicateAll() -> Predicate<Todo> {
        return #Predicate<Todo> { task in
            task.parentTask == nil
        }
    }
    
    static func predicateAllActive() -> Predicate<Todo> {
        return #Predicate<Todo> { task in
            task.parentTask == nil && !task.completed
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
    
    static func sortCompleted(_ first: Todo, _ second: Todo) -> Bool {
        if first.completed == false && second.completed == false { return true }
        if first.completed == false && second.completed { return true }
        if first.completed && second.completed == false { return false }
        return (first.completed && second.completed)
    }
    
    static func sortingWithCompleted(_ first: Todo, _ second: Todo) -> Bool {
        if first.completed == false && second.completed == false {
            if first.dueDate == nil && second.dueDate == nil {
                return (first.priority > second.priority)
            }
            if first.dueDate == nil && second.dueDate != nil { return false }
            if first.dueDate != nil && second.dueDate == nil { return true }
            if first.dueDate! == second.dueDate! {
                return (first.priority > second.priority)
            }
            return (first.dueDate! < second.dueDate!)
        } else {
            if first.completed == false && second.completed { return true }
            if first.completed && second.completed == false { return false }
            
            if let firstCompletionDate = first.completionDate, let secondCompletionDate = second.completionDate {
                return (firstCompletionDate >= secondCompletionDate)
            }
            
            return (first.completed && second.completed)
        }
    }
        
    static func deleteTask(context: ModelContext, task: Todo) {
        task.disconnectFromAll()
        task.deleteSubtasks(context: context)
        context.delete(task)
    }
    
    @MainActor static func fetchData<T: PersistentModel>(context: ModelContext, 
                                                         predicate: Predicate<T>? = nil,
                                                         sort: [SortDescriptor<T>]? = nil) -> [T] {
        do {
            var descriptor = FetchDescriptor<T>()
            if let sort = sort {
                descriptor.sortBy = sort
            }
            descriptor.predicate = predicate
            let result: [T] = try context.fetch(descriptor)
            return result
        } catch {
            print("Fetch failed")
        }
        return []
    }
}
