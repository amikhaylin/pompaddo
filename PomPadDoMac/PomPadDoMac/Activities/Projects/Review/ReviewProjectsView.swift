//
//  ReviewProjectsView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 15.04.2024.
//

import SwiftUI
import SwiftData

struct ReviewProjectsView: View {
    var projects: [Project]
    @State private var selectedProject: Project?
    @Binding var selectedTasks: Set<Todo>
    
    var body: some View {
        NavigationSplitView {
            Group {
                if projects.count > 0 {
                    List(projects, id: \.self, selection: $selectedProject) { project in
                        Text(project.name)
                            .badge(project.tasks.count)
                    }
                    .listStyle(SidebarListStyle())
                    .padding(.top, 5)
                } else {
                    Text("No projects to review")
                }
            }
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
                                project: project)
                }
            } else {
                Text("Select a project")
            }
        }
        .onChange(of: projects) { _, _ in
            selectedProject = projects.first
        }
        .navigationTitle("Review")
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        let projects: [Project] = [previewer.project]
        @State var selectedTasks = Set<Todo>()
        
        return ReviewProjectsView(projects: projects,
                                  selectedTasks: $selectedTasks)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
