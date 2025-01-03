//
//  ReviewProjectsView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 04.06.2024.
//

import SwiftUI
import SwiftData

struct ReviewProjectsView: View {
    @EnvironmentObject var showInspector: InspectorToggler
    @EnvironmentObject var selectedTasks: SelectedTasks
    
    var projects: [Project]
    
    @Query var projectsAll: [Project]
    
    var body: some View {
        NavigationStack {
            Group {
                if projects.count > 0 {
                    List(projects) { project in
                        NavigationLink {
                            ProjectToReviewView(project: project)
                                .environmentObject(showInspector)
                                .environmentObject(selectedTasks)
                        } label: {
                            Text(project.name)
                                .badge(project.getTasks().filter({ $0.completed == false }).count)
                        }
                    }
                } else {
                    Text("No projects to review")
                }
            }
        }
        .toolbar {
            Button {
                for project in projectsAll {
                    for task in project.tasks ?? [] {
                        if task.status == nil {
                            if task.completed {
                                if let status = project.getStatuses().first(where: { $0.doCompletion }) {
                                    task.status = status
                                } else {
                                    task.status = project.getDefaultStatus()
                                }
                            } else {
                                task.status = project.getDefaultStatus()
                            }
                        }
                    }
                }
            } label: {
                Label("Fix sync issues", systemImage: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90")
            }
            .disabled(!checkIssues())
            .help("Fix sync issues")
        }
        .navigationTitle("Review")
    }
    
    private func checkIssues() -> Bool {
        for project in projectsAll {
            for task in project.tasks ?? [] {
                if task.status == nil {
                    return true
                }
            }
        }
        
        return false
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
