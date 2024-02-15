//
//  Project.swift
//  TarragonaMac
//
//  Created by Andrey Mikhaylin on 12.02.2024.
//

import Foundation
import SwiftData

@Model
class Project {
    var name: String = ""
    var reviewDate: Date = Date()
    var note: String = ""
    var parent: Project?
    
    @Relationship(deleteRule: .cascade)
    var statuses: [Status] = []
    
    @Relationship(deleteRule: .cascade)
    var tasks: [Todo] = []
    
    init(name: String, note: String, parent: Project? = nil) {
        self.name = name
        self.note = note
        self.parent = parent
    }
}
