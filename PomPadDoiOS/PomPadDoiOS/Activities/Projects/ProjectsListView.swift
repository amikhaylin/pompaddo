//
//  ProjectsListView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 20.05.2024.
//

import SwiftUI
import SwiftData

struct ProjectsListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    
    @AppStorage("projectsExpanded") private var projectsExpanded = true
    @Binding var selectedProject: Project?
    @State private var newProjectIsShowing = false
    @State private var newProjectGroupShow = false
    
    @State private var editProjectGroup: ProjectGroup?
    @State private var editProjectName: Project?
    
    var projects: [Project]
    @Query var groups: [ProjectGroup]
    
    var body: some View {
        List(selection: $selectedProject) {
            DisclosureGroup(isExpanded: $projectsExpanded) {
                ForEach(projects.filter({ $0.group == nil })) { project in
                    NavigationLink(value: project) {
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
                        refresher.refresh.toggle()
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
                                    task.status = project.getStatuses().sorted(by: { $0.order < $1.order }).first
                                    project.tasks?.append(task)
                                }
                                refresher.refresh.toggle()
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
                                    project.deleteRelatives(context: modelContext)
                                    modelContext.delete(project)
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
                    .popover(isPresented: $newProjectIsShowing, attachmentAnchor: .point(.bottomLeading)) {
                        NewProjectView(isVisible: self.$newProjectIsShowing)
                            .frame(minWidth: 200, maxWidth: 300, maxHeight: 130)
                            .presentationCompactAdaptation(.popover)
                    }
                    
                    Button {
                        newProjectGroupShow.toggle()
                    } label: {
                        Image(systemName: "folder.circle")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .popover(isPresented: $newProjectGroupShow, attachmentAnchor: .point(.bottomLeading)) {
                        NewProjectGroupView(isVisible: self.$newProjectGroupShow)
                            .frame(minWidth: 200, maxWidth: 300, maxHeight: 100)
                            .presentationCompactAdaptation(.popover)
                    }
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
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        let projects: [Project] = [previewer.project]
        @State var selectedTasks = Set<Todo>()
        
        @State var selectedProject: Project?
        
        return ProjectsListView(selectedProject: $selectedProject,
                             projects: projects)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
