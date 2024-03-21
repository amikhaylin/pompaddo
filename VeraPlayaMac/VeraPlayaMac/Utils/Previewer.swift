//
//  Previewer.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 15.02.2024.
//

import Foundation
import SwiftData

@MainActor
struct Previewer {
    let container: ModelContainer
    let task: Todo
    let subtask: Todo
    
    let project: Project
    let projectTask: Todo
    
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Schema([Todo.self, Project.self]), configurations: config)
        
        task = Todo(name: "Make soup", dueDate: Date())
        container.mainContext.insert(task)

        subtask = Todo(name: "Buy potatoes", parentTask: task)
        task.subtasks?.append(subtask)
        container.mainContext.insert(subtask)
        
        project = Project(name: "Some project")
        container.mainContext.insert(project)
        
        projectTask = Todo(name: "Draw some sketches", project: project)
        container.mainContext.insert(projectTask)
        
        let anotherProject = Project(name: "👀 Another project")
        container.mainContext.insert(anotherProject)
    }
}
