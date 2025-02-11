//
//  Common.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 06.06.2024.
//

import Foundation

struct Common {
    static func formatSeconds(_ seconds: Int) -> String {
        if seconds <= 0 {
            return "00:00"
        }
        let hours: Int = seconds / 3600
        let minutes: Int = (seconds % 3600) / 60
        let secs: Int = seconds % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
    
    static func formatSecondsToMinutes(_ seconds: Int) -> String {
        let hours: Int = seconds / 3600
        let minutes: Int = (seconds % 3600) / 60
        if hours > 0 {
            if minutes > 0 {
                return String(format: "%dh %dm", hours, minutes)
            } else {
                return String(format: "%dh", hours)
            }
        } else {
            return String(format: "%dm", minutes)
        }
    }
}

class InspectorToggler: ObservableObject {
    @Published var on = false
}

class SelectedTasks: ObservableObject {
    @Published var tasks = Set<Todo>()
}
