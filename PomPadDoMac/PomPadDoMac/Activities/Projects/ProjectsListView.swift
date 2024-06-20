//
//  ProjectListView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 06.05.2024.
//

import SwiftUI
import SwiftData

struct ProjectsListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("projectsExpanded") var projectsExpanded = true
    @Binding var selectedProject: Project?
    @State private var newProjectIsShowing = false
    @State private var newProjectGroupShow = false
    
    @State private var editProjectGroup: ProjectGroup?
    
    var projects: [Project]
    @Query var groups: [ProjectGroup]
    
    var body: some View {
        List(selection: $selectedProject) {
            DisclosureGroup(isExpanded: $projectsExpanded) {
                ForEach(projects.filter({ $0.group == nil })) { project in
                    NavigationLink(value: SideBarItem.projects) {
                        Text(project.name)
                            .badge(project.getTasks().filter({ $0.completed == false }).count)
                    }
                    .tag(project)
                    .draggable(project)
                    .dropDestination(for: Todo.self) { tasks, _ in
                        for task in tasks {
                            task.project = project
                            task.status = project.getStatuses().sorted(by: { $0.order < $1.order }).first
                            project.tasks?.append(task)
                        }
                        return true
                    }
                    .contextMenu {
                        Menu {
                            ForEach(groups) { group in
                                Button {
                                    project.group = group
                                } label: {
                                    Text(group.name)
                                }
                            }
                        } label: {
                            Image(systemName: "folder")
                            Text("Add project to group")
                        }
                        
                        Button {
                            project.deleteRelatives(context: modelContext)
                            modelContext.delete(project)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(Color.red)
                            Text("Delete project")
                        }
                    }
                }
                
                ForEach(groups) { group in
                    @Bindable var group = group
                    DisclosureGroup(group.name, isExpanded: $group.expanded) {
                        ForEach(projects.filter({ $0.group == group })) { project in
                            NavigationLink(value: SideBarItem.projects) {
                                Text(project.name)
                                    .badge(project.getTasks().filter({ $0.completed == false }).count)
                            }
                            .tag(project)
                            .draggable(project)
                            .dropDestination(for: Todo.self) { tasks, _ in
                                for task in tasks {
                                    task.project = project
                                    task.status = project.getStatuses().sorted(by: { $0.order < $1.order }).first
                                    project.tasks?.append(task)
                                }
                                return true
                            }
                            .contextMenu {
                                Button {
                                    editProjectGroup = group
                                } label: {
                                    Image(systemName: "pencil")
                                    Text("Rename group")
                                }
                                
                                Button {
                                    for project in projects.filter({ $0.group == group }) {
                                        project.group = nil
                                        modelContext.delete(group)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(Color.red)
                                    Text("Delete group")
                                }
                                
                                Divider()
                                
                                Button {
                                    project.group = nil
                                } label: {
                                    Image(systemName: "clear")
                                    Text("Remove project from group")
                                }
                                
                                Button {
                                    project.deleteRelatives(context: modelContext)
                                    modelContext.delete(project)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(Color.red)
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
        .sheet(item: $editProjectGroup, onDismiss: {
            editProjectGroup = nil
        }, content: { editGroup in
            EditProjectGroupView(group: editGroup)
                .presentationDetents([.height(200)])
        })
        .sheet(isPresented: $newProjectIsShowing) {
            NewProjectView(isVisible: self.$newProjectIsShowing)
        }
        .sheet(isPresented: $newProjectGroupShow) {
            NewProjectGroupView(isVisible: self.$newProjectGroupShow)
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        let projects: [Project] = [previewer.project]
        
        @State var selectedProject: Project?
        
        return ProjectsListView(selectedProject: $selectedProject,
                             projects: projects)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
