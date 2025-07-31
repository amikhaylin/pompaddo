//
//  ProjectListView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 06.05.2024.
//
// swiftlint:disable type_body_length

import SwiftUI
import SwiftData

struct ProjectsListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    
    @Binding var selectedProject: Project?
    
    @State private var editProjectGroup: ProjectGroup?
    @State private var editProjectName: Project?
    @State private var newProjectIsShowing = false
    @State private var newProjectGroupShow = false
    @AppStorage("projectsExpanded") var projectsExpanded = true
    
    var projects: [Project]
    @Query var groups: [ProjectGroup]
    
    @Binding var selectedSideBarItem: SideBarItem?
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    projectsExpanded.toggle()
                } label: {
                    Image(systemName: "list.bullet")
                    Text("Projects")
                    Spacer()
                    Image(systemName: projectsExpanded ? "chevron.down" : "chevron.forward")
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    newProjectIsShowing.toggle()
                } label: {
                    Image(systemName: "plus.circle")
                }
                .buttonStyle(PlainButtonStyle())
                .accessibility(identifier: "NewProjectButton")
                .help("Create project")
                #if os(iOS)
                .popover(isPresented: $newProjectIsShowing, attachmentAnchor: .point(.bottomTrailing)) {
                    NewProjectView(isVisible: self.$newProjectIsShowing)
                        .frame(minWidth: 200, maxWidth: 300, maxHeight: 160)
                        .presentationCompactAdaptation(.popover)
                }
                #endif
                
                Button {
                    newProjectGroupShow.toggle()
                } label: {
                    Image(systemName: "folder.circle")
                }
                .buttonStyle(PlainButtonStyle())
                .accessibility(identifier: "NewProjectGroupButton")
                .help("Create group")
                #if os(iOS)
                .popover(isPresented: $newProjectGroupShow, attachmentAnchor: .point(.bottomTrailing)) {
                    NewProjectGroupView(isVisible: self.$newProjectGroupShow)
                        .frame(minWidth: 200, maxWidth: 300, maxHeight: 140)
                        .presentationCompactAdaptation(.popover)
                }
                #endif
            }
            #if os(iOS)
            .padding([.leading, .trailing], 20)
            #else
            .padding([.leading, .trailing], 16)
            #endif
            .dropDestination(for: Project.self) { projects, _ in
                for project in projects {
                    project.group = nil
                }
                return true
            }

            if projectsExpanded {
                List(selection: $selectedProject) {
                    ForEach(projects.filter({ $0.group == nil })
                        .sorted(by: ProjectsQuery.defaultSorting), id: \.self) { project in
                            NavigationLink(value: SideBarItem.projects) {
                                Text(project.name)
                                    .badge(project.getTasks().filter({ $0.completed == false }).count)
                            }
                            .tag(project as Project)
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
                                    ForEach(groups.sorted(by: { $0.order < $1.order })) { group in
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
                        .onMove(perform: { from, toInt in
                            var projectsList = projects.filter({ $0.group == nil })
                                .sorted(by: ProjectsQuery.defaultSorting)
                            projectsList.move(fromOffsets: from, toOffset: toInt)
                            
                            var order = 0
                            for project in projectsList {
                                order += 1
                                project.order = order
                            }
                        })
                    
                    ForEach(groups.sorted(by: { $0.order < $1.order })) { group in
                        DisclosureGroup(isExpanded: Binding<Bool>(
                            get: { group.expanded },
                            set: { newValue in group.expanded = newValue }
                        )) {
                            ForEach(projects.filter({ $0.group == group })
                                .sorted(by: ProjectsQuery.defaultSorting), id: \.self) { project in
                                    NavigationLink(value: SideBarItem.projects) {
                                        Text(project.name)
                                            .badge(project.getTasks().filter({ $0.completed == false }).count)
                                    }
                                    .tag(project as Project)
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
                                            if let lastProject = projects.filter({ $0.group == nil })
                                                .sorted(by: ProjectsQuery.defaultSorting)
                                                .last {
                                                project.order = lastProject.order + 1
                                            }
                                        } label: {
                                            Image(systemName: "folder")
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
                                .onMove(perform: { from, toInt in
                                    var projectsList = projects.filter({ $0.group == group })
                                        .sorted(by: ProjectsQuery.defaultSorting)
                                    projectsList.move(fromOffsets: from, toOffset: toInt)
                                    
                                    var order = 0
                                    for project in projectsList {
                                        order += 1
                                        project.order = order
                                    }
                                })
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
                    .onMove(perform: { from, toInt in
                        var groupsList = groups.sorted(by: { $0.order < $1.order })
                        groupsList.move(fromOffsets: from, toOffset: toInt)
                        
                        var order = 0
                        for group in groupsList {
                            order += 1
                            group.order = order
                        }
                    })
                }
                .listStyle(SidebarListStyle())
            } else {
                Spacer()
            }
        }
        .foregroundColor(Color("ProjectsColor"))
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
        .sheet(isPresented: $newProjectIsShowing) {
            NewProjectView(isVisible: self.$newProjectIsShowing)
        }
        .sheet(isPresented: $newProjectGroupShow) {
            NewProjectGroupView(isVisible: self.$newProjectGroupShow)
        }
        #else
        .popover(item: $editProjectGroup, attachmentAnchor: .point(.bottomLeading), content: { editGroup in
            EditProjectGroupView(group: editGroup)
                .frame(minWidth: 200, maxWidth: 300, maxHeight: 140)
                .presentationCompactAdaptation(.popover)
        })
        .popover(item: $editProjectName, attachmentAnchor: .point(.bottomLeading), content: { editProject in
            EditProjectNameView(project: editProject)
                .frame(minWidth: 200, maxWidth: 300, maxHeight: 140)
                .presentationCompactAdaptation(.popover)
        })
        #endif
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
    @Previewable @State var selectedSideBarItem: SideBarItem? = .today
    @Previewable @State var selectedProject: Project?
    let previewer = try? Previewer()
    let projects: [Project] = [previewer!.project]
    
    ProjectsListView(selectedProject: $selectedProject,
                            projects: projects,
                            selectedSideBarItem: $selectedSideBarItem)
        .modelContainer(previewer!.container)
}
// swiftlint:enable type_body_length
