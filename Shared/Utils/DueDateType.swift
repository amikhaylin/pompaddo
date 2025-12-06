//
//  DueDateType.swift
//  PomPadDo
//
//  Created by Andrey Mikhaylin on 01.12.2025.
//

import Foundation

enum DueDateType: String, Identifiable, CaseIterable {
    var id: String { rawValue }

    case none
    case today
    case tomorrow
    case nextweek
    case custom
    
    var name: String {
        switch self {
        case .none:
            return NSLocalizedString("None", comment: "")
        case .today:
            return NSLocalizedString("Today", comment: "")
        case .tomorrow:
            return NSLocalizedString("Tomorrow", comment: "")
        case .nextweek:
            return NSLocalizedString("Next week", comment: "")
        case .custom:
            return NSLocalizedString("Custom", comment: "")
        }
    }
}
