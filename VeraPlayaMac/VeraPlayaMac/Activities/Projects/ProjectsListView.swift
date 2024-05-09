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
    @AppStorage("groupsExpanded") var groupsExpanded = true
    @Binding var selectedProject: Project?
    @Binding var selectedTasks: Set<Todo>
    @Binding var newProjectIsShowing: Bool
    @Binding var newProjectGroupShow: Bool
    
//    @State private var editProjectGroup = false
//    @State private var groupToEdit: ProjectGroup?
    
    var projects: [Project]
    @Query var groups: [ProjectGroup]
    
    var body: some View {
        List(selection: $selectedProject) {
            DisclosureGroup(isExpanded: $projectsExpanded) {
                ForEach(projects.filter({ $0.group == nil })) { project in
                    NavigationLink(value: SideBarItem.projects) {
                        Text(project.name)
                            .badge(project.tasks.filter({ $0.completed == false }).count)
                    }
                    .tag(project)
                    .draggable(project)
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
                
                ForEach(groups) { group in
                    DisclosureGroup(group.name, isExpanded: $groupsExpanded) {
                        ForEach(projects.filter({ $0.group == group })) { project in
                            NavigationLink(value: SideBarItem.projects) {
                                Text(project.name)
                                    .badge(project.tasks.filter({ $0.completed == false }).count)
                            }
                            .tag(project)
                            .draggable(project)
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
                    }
                    .dropDestination(for: Project.self) { projects, _ in
                        for project in projects where project.group == nil || project.group != group {
                            project.group = group
                        }
                        return true
                    }
                    .contextMenu {
//                        Button {
//                            editProjectGroup.toggle()
//                        } label: {
//                            Image(systemName: "pencil")
//                            Text("Rename group")
//                        }
                        
                        Button {
                            for project in projects.filter({ $0.group == group }) {
                                project.group = nil
                                modelContext.delete(group)
                            }
                        } label: {
                            Image(systemName: "trash")
                            Text("Delete group")
                        }
                    }
//                    .sheet(isPresented: $editProjectGroup) {
//                        EditProjectGroupView(isVisible: self.$editProjectGroup, group: group)
//                    }
                }
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
                .foregroundColor(Color(#colorLiteral(red: 0.5486837626, green: 0.827090323, blue: 0.8101685047, alpha: 1)))
                .dropDestination(for: Project.self) { projects, _ in
                    for project in projects {
                        project.group = nil
                    }
                    return true
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
        
        return ProjectsListView(selectedProject: $selectedProject,
                             selectedTasks: $selectedTasks,
                             newProjectIsShowing: $newProjectIsShowing,
                             newProjectGroupShow: $newProjectGroupShow,
                             projects: projects)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
