//
//  ProjectGroup.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 06.05.2024.
//

import Foundation
import SwiftData

@Model
class ProjectGroup {
    var name: String = ""
    
    init(name: String) {
        self.name = name
    }
}
