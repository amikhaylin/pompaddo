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
    
    @Query var projects: [Project]
    
    var body: some View {
        NavigationStack {
            Group {
                if projects.filter({ TasksQuery.filterProjectToReview($0) }).count > 0 {
                    List(projects.filter({ TasksQuery.filterProjectToReview($0) }).sorted(by: ProjectsQuery.defaultSorting)) { project in
                        NavigationLink {
                            ProjectToReviewView(project: project)
                                .environmentObject(showInspector)
                                .environmentObject(selectedTasks)
                        } label: {
                            Text(project.name)
                                .badge(project.getTasks().filter({ $0.completed == false }).count)
                        }
                        .listRowSeparator(.hidden)
                    }
                } else {
                    VStack {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .foregroundStyle(Color.gray)
                            .frame(width: 100, height: 100)
                        
                        Text("No projects to review")
                    }
                }
            }
        }
        .navigationTitle("Review")
    }
}

#Preview {
    @Previewable @StateObject var selectedTasks = SelectedTasks()
    @Previewable @StateObject var showInspector = InspectorToggler()
    @Previewable @State var refresher = Refresher()
    let previewer = try? Previewer()
    
    ReviewProjectsView()
        .environmentObject(showInspector)
        .environmentObject(selectedTasks)
        .environmentObject(refresher)
        .modelContainer(previewer!.container)
}
