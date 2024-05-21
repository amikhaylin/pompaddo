//
//  Project.swift
//  TarragonaMac
//
//  Created by Andrey Mikhaylin on 12.02.2024.
//

import Foundation
import SwiftData

enum DefaultProjectStatuses: String, CaseIterable {
    case todo = "To do"
    case progress = "In progress"
    case completed = "Completed"
    
    var competion: Bool {
        switch self {
        case .completed:
            return true
        default:
            return false
        }
    }
}

@Model
class Project {
    var name: String = ""
    var reviewDate: Date = Date()
    var reviewDaysCount: Int = 7
    var note: String = ""
    var projectViewMode: Int = 0
    @Relationship var group: ProjectGroup?
    var hasEstimate: Bool = false
    
    @Relationship(deleteRule: .cascade)
    var statuses: [Status]? = [Status]()
    
    @Relationship(deleteRule: .cascade, inverse: \Todo.project)
    var tasks: [Todo]? = [Todo]()
    
    init(name: String, note: String = "") {
        self.name = name
        self.note = note
    }
}

extension Project {
    // TODO: BE REMOVED WHEN `.cascade` is fixed
    func deleteRelatives(context: ModelContext) {
        for status in self.getStatuses() {
            context.delete(status)
        }
        
        for task in self.getTasks() {
            task.deleteSubtasks(context: context)
            context.delete(task)
        }
    }
    
    func sumEstimateByProject(_ factor: Double) -> Int {
        var result = 0
        for task in self.getTasks() {
            result += task.sumEstimates(factor)
        }
        return result
    }
    
    func getStatuses() -> [Status] {
        if let statuses = self.statuses {
            return statuses
        } else {
            return []
        }
    }
    
    func getTasks() -> [Todo] {
        if let tasks = self.tasks {
            return tasks
        } else {
            return []
        }
    }
}
