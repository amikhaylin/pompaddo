//
//  Previewer.swift
//  PomPadDoMac
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
    var projectStatus: Status
    
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema([
            ProjectGroup.self,
            Status.self,
            Todo.self,
            Project.self
        ])
        container = try ModelContainer(for: schema,
                                       configurations: config)
        
        task = Todo(name: "Make soup",
                    dueDate: Date(),
                    link: "https://google.com",
                    repeation: .daily,
                    priority: 2)
        container.mainContext.insert(task)

        task.tomatoesCount += 1
        
        task.priority = 3
        task.clarity = 1
        task.baseTimeHours = 1
        task.hasEstimate = true
        
        subtask = Todo(name: "Buy potatoes", parentTask: task)
        task.subtasks?.append(subtask)
        container.mainContext.insert(subtask)
        
        project = Project(name: "🦫 Some project")
        container.mainContext.insert(project)
        
        var order = 0
        for name in DefaultProjectStatuses.allCases {
            order += 1
            let status = Status(name: name.localizedString(),
                                order: order,
                                doCompletion: name.competion)
            container.mainContext.insert(status)
            project.statuses?.append(status)
        }
        
        if let firstStatus = project.statuses?.first {
            projectStatus = firstStatus
        } else {
            projectStatus = Status(name: "Status", order: 1)
        }
        
        projectTask = Todo(name: "Draw some sketches", 
                           status: project.statuses?.first,
                           project: project)
        container.mainContext.insert(projectTask)
        
        let projectTaskWithSubtask = Todo(name: "Make a project",
                                          status: project.statuses?.first,
                                          project: project)
        container.mainContext.insert(projectTaskWithSubtask)
        let projectSubtask = Todo(name: "Start Xcode", parentTask: projectTaskWithSubtask)
        projectTaskWithSubtask.subtasks?.append(projectSubtask)
        container.mainContext.insert(projectSubtask)
        
        let anotherProject = Project(name: "🦔 Another project")
        container.mainContext.insert(anotherProject)
    }
}
