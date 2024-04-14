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
    var order: Int
    var doCompletion: Bool = false
    
    init(name: String,
         order: Int,
         doCompletion: Bool = false) {
        self.name = name
        self.order = order
        self.doCompletion = doCompletion
    }
}
