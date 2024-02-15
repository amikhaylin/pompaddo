//
//  Todo.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 14.02.2024.
//

import Foundation
import SwiftData

@Model
class Todo {
    var name: String = ""
    var dueDate: Date?
    var completed: Bool = false
    var status: Status?
    var note: String = ""
    var parentTask: Todo?
    var tomatoesCount: Int = 0
    
    init(name: String, dueDate: Date? = nil, completed: Bool, status: Status? = nil, note: String, parentTask: Todo? = nil, tomatoesCount: Int) {
        self.name = name
        self.dueDate = dueDate
        self.completed = completed
        self.status = status
        self.note = note
        self.parentTask = parentTask
        self.tomatoesCount = tomatoesCount
    }
}
