//
//  ReviewProjectsView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 04.06.2024.
//

import SwiftUI

struct ReviewProjectsView: View {
    var projects: [Project]
    
    var body: some View {
        NavigationStack {
            Group {
                if projects.count > 0 {
                    List(projects) { project in
                        NavigationLink {
                            ProjectToReviewView(project: project)
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
