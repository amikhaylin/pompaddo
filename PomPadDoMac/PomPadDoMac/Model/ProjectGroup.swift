//
//  ProjectGroup.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 06.05.2024.
//

import Foundation
import SwiftData

@Model
class ProjectGroup {
    var name: String = ""
    
    @Relationship(inverse: \Project.group) var projects: [Project]? = [Project]()
    
    init(name: String) {
        self.name = name
    }
}
