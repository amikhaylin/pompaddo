//
//  Item.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 13.02.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
