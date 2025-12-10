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
            if task.deletionDate == nil {
                if let date = task.dueDate {
                    return date < tomorrow
                } else if let completeDate = task.completionDate {
                    return (completeDate >= today && completeDate < tomorrow)
                } else if let deadlineDate = task.deadline {
                    return deadlineDate < tomorrow
                } else {
                    return false
                }
            } else {
                return false
            }
        }
    }
    
    static func predicateTodayActive() -> Predicate<Todo> {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        return #Predicate<Todo> { task in
            if task.deletionDate == nil {
                if let date = task.dueDate {
                    return (date < tomorrow && !task.completed)
                } else if let deadlineDate = task.deadline {
                    return (deadlineDate < tomorrow && !task.completed)
                } else {
                    return false
                }
            } else {
                return false
            }
        }
    }
        
    static func predicateTomorrow() -> Predicate<Todo> {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        let future = Calendar.current.date(byAdding: .day, value: 1, to: tomorrow)!
        return #Predicate<Todo> { task in
            if task.deletionDate == nil {
                if let date = task.dueDate {
                    return date >= tomorrow && date < future
                } else if let deadlineDate = task.deadline {
                    return deadlineDate >= tomorrow && deadlineDate < future
                } else {
                    return false
                }
            } else {
                return false
            }
        }
    }
    
    static func predicateDeadlines() -> Predicate<Todo> {
        return #Predicate<Todo> { task in
            if task.deletionDate == nil {
                if task.deadline != nil {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
    }
    
    static func predicateDeadlinesActive() -> Predicate<Todo> {
        return #Predicate<Todo> { task in
            if task.deletionDate == nil {
                if task.deadline != nil {
                    return !task.completed
                } else {
                    return false
                }
            } else {
                return false
            }
        }
    }
    
    static func predicateTomorrowActive() -> Predicate<Todo> {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        let future = Calendar.current.date(byAdding: .day, value: 1, to: tomorrow)!
        return #Predicate<Todo> { task in
            if task.deletionDate == nil {
                if let date = task.dueDate {
                    return date >= tomorrow && date < future && !task.completed
                } else if let deadlineDate = task.deadline {
                    return deadlineDate >= tomorrow && deadlineDate < future && !task.completed
                } else {
                    return false
                }
            } else {
                return false
            }
        }
    }
    
    static func predicateInbox() -> Predicate<Todo> {
        return #Predicate<Todo> { task in
            if task.deletionDate == nil {
                return task.project == nil && task.parentTask == nil
            } else {
                return false
            }
        }
    }
    
    static func predicateInboxActive() -> Predicate<Todo> {
        return #Predicate<Todo> { task in
            if task.deletionDate == nil {
                return task.project == nil && task.parentTask == nil && !task.completed
            } else {
                return false
            }
        }
    }
    
    static func predicateAllTasks() -> Predicate<Todo> {
        return #Predicate<Todo> { task in
            task.deletionDate == nil
        }
    }
    
    static func predicateActive() -> Predicate<Todo> {
        return #Predicate<Todo> { task in
            !task.completed && task.deletionDate == nil
        }
    }
    
    static func predicateTrash() -> Predicate<Todo> {
        return #Predicate<Todo> { task in
            return task.deletionDate != nil
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
            task.parentTask == nil && !task.completed && task.deletionDate == nil
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
    
    static func sortDeleted(_ first: Todo, _ second: Todo) -> Bool {
        return first.deletionDate! > second.deletionDate!
    }
    
    static func sortingWithCompleted(_ first: Todo, _ second: Todo) -> Bool {
        if first.completed == false && second.completed == false {
            if first.dueDate == nil && second.dueDate == nil {
                return sortingDeadlines(first, second)
            }
            if first.dueDate == nil && second.dueDate != nil { return false }
            if first.dueDate != nil && second.dueDate == nil { return true }
            if first.dueDate! == second.dueDate! {
                return sortingDeadlines(first, second)
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
    
    static func sortingDeadlines(_ first: Todo, _ second: Todo) -> Bool {
        if first.deadline == nil && second.deadline == nil {
            return (first.priority > second.priority)
        }
        if first.deadline == nil && second.deadline != nil { return false }
        if first.deadline != nil && second.deadline == nil { return true }
        if first.deadline! == second.deadline! {
            return (first.priority > second.priority)
        }
        return (first.deadline! < second.deadline!)
    }
        
    static func eraseTask(context: ModelContext, task: Todo) {
        task.disconnectFromAll()
        task.eraseSubtasks(context: context)
        context.delete(task)
    }
    
    static func deleteTask(task: Todo) {
        task.deleteSubtasks()
        task.deletionDate = Date()
    }
    
    static func emptyTrash(context: ModelContext, tasks: [Todo]) {
        for task in tasks {
            eraseTask(context: context, task: task)
        }
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
