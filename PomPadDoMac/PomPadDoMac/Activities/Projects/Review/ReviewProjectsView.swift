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
    @State private var deletionRequested = false
    
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
                        Button(role: .destructive) {
                            deletionRequested.toggle()
                        } label: {
                            Text("Delete project")
                                .foregroundStyle(Color.red)
                        }
                        .popover(isPresented: $deletionRequested, attachmentAnchor: .point(.top)) {
                            VStack {
                                Text("This project will be permanently deleted")
                                Button(role: .destructive) {
                                    project.deleteRelatives(context: modelContext)
                                    modelContext.delete(project)
                                    deletionRequested.toggle()
                                } label: {
                                    Label("Delete Project", systemImage: "trash")
                                        .foregroundStyle(Color.red)
                                }
                            }
                            .padding(10)
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
    /*
     .popover(isPresented: $newProjectGroupShow, attachmentAnchor: .point(.bottomLeading)) {
         NewProjectGroupView(isVisible: self.$newProjectGroupShow)
             .frame(minWidth: 200, maxWidth: 300, maxHeight: 100)
             .presentationCompactAdaptation(.popover)
     }
     */
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
