//
//  Status.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 14.02.2024.
//

import Foundation
import SwiftData

@Model
class Status {
    var name: String = ""
    
    init(name: String) {
        self.name = name
    }
}
