//
//  Status.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 14.02.2024.
//

import Foundation
import SwiftData

@Model
class Status {
    var name: String = ""
    var order: Int = 0
    var doCompletion: Bool = false
    var expanded: Bool = true
    
    @Relationship(inverse: \Project.statuses) var project: Project?
    @Relationship(inverse: \Todo.status) var tasks: [Todo]? = [Todo]()
    
    init(name: String,
         order: Int,
         doCompletion: Bool = false) {
        self.name = name
        self.order = order
        self.doCompletion = doCompletion
    }
}
