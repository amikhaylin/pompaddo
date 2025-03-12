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
    @EnvironmentObject var refresher: Refresher
    
    @AppStorage("projectsExpanded") var projectsExpanded = true
    @Binding var selectedProject: Project?
    
    @State private var editProjectGroup: ProjectGroup?
    @State private var editProjectName: Project?
    
    var projects: [Project]
    @Query var groups: [ProjectGroup]
    
    @Binding var selectedSideBarItem: SideBarItem?
    
    var body: some View {
        if projectsExpanded {
            List(selection: $selectedProject) {
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
                            task.status = project.getDefaultStatus()
                            project.tasks?.append(task)
                        }
                        return true
                    }
                    .contextMenu {
                        Button {
                            editProjectName = project
                        } label: {
                            Image(systemName: "pencil")
                            Text("Rename project")
                        }
                        
                        Menu {
                            ForEach(groups) { group in
                                Button {
                                    project.group = group
                                } label: {
                                    Text(group.name)
                                }
                                .accessibility(identifier: "\(group.name)ContextMenuButton")
                            }
                        } label: {
                            Image(systemName: "folder")
                            Text("Add project to group")
                        }
                        
                        Button {
                            deleteProject(project)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(Color.red)
                            Text("Delete project")
                        }
                    }
                }
                
                ForEach(groups) { group in
                    @Bindable var group: ProjectGroup = group
                    DisclosureGroup(isExpanded: $group.expanded) {
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
                                    task.status = project.getDefaultStatus()
                                    project.tasks?.append(task)
                                }
                                return true
                            }
                            .contextMenu {
                                Button {
                                    editProjectName = project
                                } label: {
                                    Image(systemName: "pencil")
                                    Text("Rename project")
                                }
                                
                                Button {
                                    project.group = nil
                                } label: {
                                    Image(systemName: "clear")
                                    Text("Remove project from group")
                                }
                                
                                Button {
                                    deleteProject(project)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(Color.red)
                                    Text("Delete project")
                                }
                            }
                        }
                    } label: {
                        Text(group.name)
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
                            }
                    }
                    .dropDestination(for: Project.self) { projects, _ in
                        for project in projects where project.group == nil || project.group != group {
                            project.group = group
                        }
                        return true
                    }
                }
            }
            .listStyle(SidebarListStyle())
            #if os(macOS)
            .sheet(item: $editProjectGroup, onDismiss: {
                editProjectGroup = nil
            }, content: { editGroup in
                EditProjectGroupView(group: editGroup)
                    .presentationDetents([.height(200)])
            })
            .sheet(item: $editProjectName, onDismiss: {
                editProjectName = nil
            }, content: { editProject in
                EditProjectNameView(project: editProject)
                    .presentationDetents([.height(200)])
            })
            #else
            .popover(item: $editProjectGroup, attachmentAnchor: .point(.bottomLeading), content: { editGroup in
                EditProjectGroupView(group: editGroup)
                    .frame(minWidth: 200, maxWidth: 300, maxHeight: 100)
                    .presentationCompactAdaptation(.popover)
            })
            .popover(item: $editProjectName, attachmentAnchor: .point(.bottomLeading), content: { editProject in
                EditProjectNameView(project: editProject)
                    .frame(minWidth: 200, maxWidth: 300, maxHeight: 100)
                    .presentationCompactAdaptation(.popover)
            })
            #endif
        } else {
            Spacer()
        }
    }
    
    private func deleteProject(_ project: Project) {
        if let projectSelected = selectedProject, projectSelected == project {
            selectedProject = nil
            selectedSideBarItem = .today
        }
        
        project.deleteRelatives(context: modelContext)
        modelContext.delete(project)
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        let projects: [Project] = [previewer.project]
        
        @State var selectedProject: Project?
        
        @State var selectedSideBarItem: SideBarItem? = .today
        
        return ProjectsListView(selectedProject: $selectedProject,
                                projects: projects,
                                selectedSideBarItem: $selectedSideBarItem)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
