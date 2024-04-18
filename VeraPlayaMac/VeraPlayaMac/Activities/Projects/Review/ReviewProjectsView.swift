//
//  ReviewProjectsView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 15.04.2024.
//

import SwiftUI
import SwiftData

struct ReviewProjectsView: View {
    var projects: [Project]
    @State private var selectedProject: Project?
    @Binding var selectedTasks: Set<Todo>
    @Binding var currentTask: Todo?
    
    var body: some View {
        NavigationSplitView {
            List(projects, id: \.self, selection: $selectedProject) { project in
                Text(project.name)
                    .badge(project.tasks.count)
            }
            .listStyle(SidebarListStyle())
            .padding(.top, 5)
            .navigationSplitViewColumnWidth(min: 200, ideal: 200)
        } detail: {
            if let project = selectedProject {
                VStack {
                    HStack {
                        Spacer()
                        Button("Mark Reviewed") {
                            project.reviewDate = Date()
                        }
                    }
                    .padding(5)
                    ProjectView(selectedTasks: $selectedTasks,
                                currentTask: $currentTask,
                                project: project)
                }
            } else {
                Text("Select a project")
            }
        }
        .onChange(of: projects) { _, _ in
            selectedProject = projects.first
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        let projects: [Project] = [previewer.project]
        @State var selectedTasks = Set<Todo>()
        @State var currentTask: Todo?
        
        return ReviewProjectsView(projects: projects,
                                  selectedTasks: $selectedTasks,
                                  currentTask: $currentTask)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
