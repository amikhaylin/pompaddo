//
//  ProjectsQuery.swift
//  PomPadDo
//
//  Created by Andrey Mikhaylin on 29.04.2025.
//

import SwiftData

struct ProjectsQuery {
    static func defaultSorting(_ first: Project, _ second: Project) -> Bool {
        if first.group == nil && second.group == nil {
            return (first.order < second.order)
        }
        if first.group == nil && second.group != nil { return true }
        if first.group != nil && second.group == nil { return false }
        return (first.order < second.order)
    }
}
