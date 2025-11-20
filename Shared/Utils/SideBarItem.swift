//
//  SideBarItem.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 02.12.2024.
//

import Foundation

enum SideBarItem: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    case inbox
    case today
    case tomorrow
    case review
    case projects
    case deadlines
    case alltasks
    
    var name: String {
        switch self {
        case .inbox:
            return NSLocalizedString("Inbox", comment: "")
        case .today:
            return NSLocalizedString("Today", comment: "")
        case .tomorrow:
            return NSLocalizedString("Tomorrow", comment: "")
        case .review:
            return NSLocalizedString("Review", comment: "")
        case .projects:
            return NSLocalizedString("Projects", comment: "")
        case .deadlines:
            return NSLocalizedString("Deadlines", comment: "")
        case .alltasks:
            return NSLocalizedString("All", comment: "")
        }
    }
}
