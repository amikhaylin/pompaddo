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
    var group: ProjectGroup?
    var hasEstimate: Bool = false
    
    @Relationship(deleteRule: .cascade)
    var statuses: [Status] = []
    
    @Relationship(deleteRule: .cascade)
    var tasks: [Todo] = []
    
    init(name: String, note: String = "") {
        self.name = name
        self.note = note
    }
}

extension Project {
    // TODO: BE REMOVED WHEN `.cascade` is fixed
    func deleteRelatives(context: ModelContext) {
        for status in self.statuses {
            context.delete(status)
        }
        
        for task in self.tasks {
            task.deleteSubtasks(context: context)
            context.delete(task)
        }
    }
    
    func sumEstimateByProject(_ factor: Double) -> Int {
        var result = 0
        for task in self.tasks {
            result += task.sumEstimates(factor)
        }
        return result
    }
}
