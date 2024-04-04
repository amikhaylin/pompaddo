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
    case monthly = "Monthly"
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
    var repeation: RepeationMode? = RepeationMode.none
    
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
         repeation: RepeationMode? = RepeationMode.none) {
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
    }
}
