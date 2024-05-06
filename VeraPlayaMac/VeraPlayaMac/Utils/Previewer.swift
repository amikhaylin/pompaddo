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
        container = try ModelContainer(for: Schema([Todo.self, Project.self]), 
                                       configurations: config)
        
        task = Todo(name: "Make soup",
                    dueDate: Date(),
                    link: "https://google.com",
                    repeation: .daily,
                    priority: 2)
        container.mainContext.insert(task)

        task.tomatoesCount += 1
        
        subtask = Todo(name: "Buy potatoes", parentTask: task)
        task.subtasks?.append(subtask)
        container.mainContext.insert(subtask)
        
        project = Project(name: "🦫 Some project")
        container.mainContext.insert(project)
        
        var order = 0
        for name in DefaultProjectStatuses.allCases {
            order += 1
            let doComplete = name == DefaultProjectStatuses.completed
            let status = Status(name: name.rawValue,
                                order: order,
                                doCompletion: doComplete)
            container.mainContext.insert(status)
            project.statuses.append(status)
        }
        
        projectTask = Todo(name: "Draw some sketches", 
                           status: project.statuses.first,
                           project: project)
        container.mainContext.insert(projectTask)
        
        let projectTaskWithSubtask = Todo(name: "Make a project",
                                          status: project.statuses.first,
                                          project: project)
        container.mainContext.insert(projectTaskWithSubtask)
        let projectSubtask = Todo(name: "Start Xcode", parentTask: projectTaskWithSubtask)
        projectTaskWithSubtask.subtasks?.append(projectSubtask)
        container.mainContext.insert(projectSubtask)
        
        let anotherProject = Project(name: "🦔 Another project")
        container.mainContext.insert(anotherProject)
    }
}
