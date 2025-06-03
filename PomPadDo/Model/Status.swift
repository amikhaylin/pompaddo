//
//  Status.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 14.02.2024.
//

import Foundation
import SwiftData

@Model
class Status: Hashable {
    var name: String = ""
    var order: Int = 0
    var doCompletion: Bool = false
    var expanded: Bool = true
    var clearDueDate: Bool = false
    var width: Double = 300.0
    var uid: String = UUID().uuidString
    
    @Relationship(inverse: \Project.statuses) var project: Project?
    @Relationship(inverse: \Todo.status) var tasks: [Todo]? = [Todo]()
    
    init(name: String,
         order: Int,
         doCompletion: Bool = false,
         expanded: Bool = true,
         clearDueDate: Bool = false,
         width: Double = 300.0,
         project: Project? = nil,
         tasks: [Todo]? = [Todo](),
         uid: String = UUID().uuidString) {
        self.name = name
        self.order = order
        self.doCompletion = doCompletion
        self.expanded = expanded
        self.clearDueDate = clearDueDate
        self.width = width
        self.project = project
        self.tasks = tasks
        self.uid = uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid) // UUID
    }
}
