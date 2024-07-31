//
//  ReviewProjectsView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 15.04.2024.
//

import SwiftUI
import SwiftData

struct ReviewProjectsView: View {
    @Environment(\.modelContext) private var modelContext
    var projects: [Project]
    @State private var selectedProject: Project?
    
    var body: some View {
        NavigationSplitView {
            Group {
                if projects.count > 0 {
                    List(projects, id: \.self, selection: $selectedProject) { project in
                        Text(project.name)
                            .badge(project.getTasks().filter({ $0.completed == false }).count)
                    }
                    .listStyle(SidebarListStyle())
                    .padding(.top, 5)
                } else {
                    Text("No projects to review")
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 200, max: 400)
        } detail: {
            if let project = selectedProject {
                VStack {
                    HStack {
                        Spacer()
                        Button("Delete project") {
                            project.deleteRelatives(context: modelContext)
                            modelContext.delete(project)
                        }
                        
                        Button("Mark Reviewed") {
                            project.reviewDate = Date()
                        }
                    }
                    .padding(5)
                    ProjectView(project: project)
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
        
        return ReviewProjectsView(projects: projects)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
