//
//  ProjectListView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 06.05.2024.
//

import SwiftUI
import SwiftData

struct ProjectsListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("projectsExpanded") var projectsExpanded = true
    @Binding var selectedProject: Project?
    @Binding var selectedTasks: Set<Todo>
    @Binding var newProjectIsShowing: Bool
    @Binding var newProjectGroupShow: Bool
    
    var projects: [Project]
    var geometry: GeometryProxy
    
    var body: some View {
        List {
            DisclosureGroup(isExpanded: $projectsExpanded) {
                List(projects, id: \.self, selection: $selectedProject) { project in
                    NavigationLink(value: SideBarItem.projects) {
                        Text(project.name)
                            .badge(project.tasks.filter({ $0.completed == false }).count)
                    }
                    .dropDestination(for: Todo.self) { tasks, _ in
                        for task in tasks {
                            task.project = project
                            task.status = project.statuses.sorted(by: { $0.order < $1.order }).first
                            project.tasks.append(task)
                        }
                        return true
                    }
                    .contextMenu {
                        Button {
                            selectedTasks = []
                            project.deleteRelatives(context: modelContext)
                            modelContext.delete(project)
                        } label: {
                            Image(systemName: "trash")
                            Text("Delete project")
                        }
                    }
                }
                .frame(height: geometry.size.height > 150 ? geometry.size.height - 150 : 200)
                .listStyle(SidebarListStyle())
            } label: {
                HStack {
                    Image(systemName: "list.bullet")
                    Text("Projects")
                    Spacer()
                    Button {
                        newProjectIsShowing.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        newProjectGroupShow.toggle()
                    } label: {
                        Image(systemName: "folder.circle")
                    }
                    .buttonStyle(PlainButtonStyle())

                }
            }
        }
        .listStyle(SidebarListStyle())
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        let projects: [Project] = [previewer.project]
        @State var selectedTasks = Set<Todo>()
        
        @State var selectedProject: Project?
        @State var newProjectIsShowing: Bool = false
        @State var newProjectGroupShow: Bool = false
        
        return GeometryReader { geometry in
            ProjectsListView(selectedProject: $selectedProject,
                             selectedTasks: $selectedTasks,
                             newProjectIsShowing: $newProjectIsShowing,
                             newProjectGroupShow: $newProjectGroupShow,
                             projects: projects,
                             geometry: geometry)
            .modelContainer(previewer.container)
        }
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
