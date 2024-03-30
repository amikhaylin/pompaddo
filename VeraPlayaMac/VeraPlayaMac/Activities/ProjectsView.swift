//
//  ProjectsView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 29.03.2024.
//

import SwiftUI
import SwiftData

struct ProjectsView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var selectedProject: Project?
    @Binding var selectedTasks: Set<Todo>
    @Binding var currentTask: Todo?
    @Query var projects: [Project]
    
    var body: some View {
        NavigationSplitView {
            List(projects, selection: $selectedProject) { project in
                NavigationLink(value: project) {
                    Text(project.name)
                        .badge(project.tasks.count)
                }
                .contextMenu {
                    Button {
                        selectedTasks = []
                        modelContext.delete(project)
                    } label: {
                        Image(systemName: "trash")
                        Text("Delete project")
                    }
                }
            }
        } detail: {
            if let project = selectedProject {
                ProjectTasksListView(selectedTasks: $selectedTasks,
                                     currentTask: $currentTask,
                                     project: project)
            } else {
                Text("Select a project")
            }
        }

    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var selectedTasks = Set<Todo>()
        @State var currentTask: Todo?
        
        return ProjectsView(selectedTasks: $selectedTasks,
                            currentTask: $currentTask)
        .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
