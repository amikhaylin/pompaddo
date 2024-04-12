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
    var reviewDaysCount: Int = 7
    var note: String = ""
    var uid: String = UUID().uuidString
    
    @Relationship(deleteRule: .cascade)
    var statuses: [Status] = []
    
    @Relationship(deleteRule: .cascade)
    var tasks: [Todo] = []
    
    init(name: String, note: String = "") {
        self.name = name
        self.note = note
    }
}
