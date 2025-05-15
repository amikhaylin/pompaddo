//
//  ProjectGroup.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 06.05.2024.
//

import Foundation
import SwiftData

@Model
class ProjectGroup: Hashable {
    var name: String = ""
    var expanded: Bool = true
    var order: Int = 0
    var uid: String = UUID().uuidString
    
    @Relationship(inverse: \Project.group) var projects: [Project]? = [Project]()
    
    init(name: String) {
        self.name = name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid) // UUID
    }
}
