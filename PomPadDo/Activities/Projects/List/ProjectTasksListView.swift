//
//  ProjectTasksListView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 27.03.2024.
//

import SwiftUI
import SwiftData

struct ProjectTasksListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var showInspector: InspectorToggler
    @EnvironmentObject var selectedTasks: SelectedTasks
    
    @Bindable var project: Project
    
    @State private var refresher = Refresher()
    
    @State private var searchText = ""
    @State private var groupsExpanded: Set<String> = ["To do", "Completed"]
    @State private var statusToEdit: Status?
    
    var searchResults: [Todo] {
        if searchText.isEmpty {
            return project.getTasks()
        } else {
            return project.getTasks().filter { $0.name.localizedStandardContains(searchText) }
        }
    }
    
    var body: some View {
        List(selection: $selectedTasks.tasks) {
            // MARK:Show tasks with statuses
            if let statuses = project.statuses, statuses.count > 0 {
                ForEach(project.getStatuses().sorted(by: { $0.order < $1.order })) { status in
                    DisclosureGroup(isExpanded: Binding<Bool>(
                        get: { status.expanded },
                        set: { newValue in status.expanded = newValue }
                    )) {
                        ForEach(searchResults
                            .filter({ $0.status == status && $0.parentTask == nil })
                            .sorted(by: TasksQuery.defaultSorting),
                                id: \.self) { task in
                            if let subtasks = task.subtasks, subtasks.count > 0 {
                                OutlineGroup([task],
                                             id: \.self,
                                             children: \.subtasks) { maintask in
                                    TaskRowView(task: maintask, showingProject: false)
                                        .modifier(ProjectTaskModifier(task: maintask,
                                                                      selectedTasksSet: $selectedTasks.tasks,
                                                                      project: project,
                                                                      tasks: Binding(
                                                                        get: { project.tasks ?? [] },
                                                                        set: { project.tasks = $0 })))
                                        .modifier(TaskSwipeModifier(task: maintask, list: .projects, tasks: Binding(
                                            get: { project.tasks ?? [] },
                                            set: { project.tasks = $0 })))
                                        .tag(maintask)
                                }
                            } else {
                                TaskRowView(task: task, showingProject: false)
                                    .modifier(ProjectTaskModifier(task: task,
                                                                  selectedTasksSet: $selectedTasks.tasks,
                                                                  project: project,
                                                                  tasks: Binding(
                                                                    get: { project.tasks ?? [] },
                                                                    set: { project.tasks = $0 })))
                                    .modifier(TaskSwipeModifier(task: task, list: .projects, tasks: Binding(
                                        get: { project.tasks ?? [] },
                                        set: { project.tasks = $0 })))
                                    .tag(task)
                            }
                        }
                    } label: {
                        HStack {
                            #if os(macOS)
                            Button {
                                statusToEdit = status
                            } label: {
                                Text(status.name == "" ? "Unnamed" : status.name)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .sheet(item: $statusToEdit, content: { status in
                                StatusSettingsView(status: status,
                                                    project: self.project)
                            })
                            #else
                            NavigationLink {
                                StatusSettingsView(status: status,
                                                   project: self.project)
                            } label: {
                                Text(status.name == "" ? "Unnamed" : status.name)
                            }
                            .buttonStyle(PlainButtonStyle())
                            #endif
                            
                            Text(" \(project.getTasks().filter({ $0.status == status && $0.parentTask == nil }).count)")
                                .foregroundStyle(Color.gray)
                                .font(.caption)
                        }
                    }
                    .dropDestination(for: Todo.self) { tasks, _ in
                        for task in tasks {
                            task.moveToStatus(status: status,
                                              project: project,
                                              context: modelContext)
                        }
                        return true
                    }
                }
                .onMove(perform: { from, toInt in
                    var statusList = project.getStatuses().sorted(by: { $0.order < $1.order })
                    statusList.move(fromOffsets: from, toOffset: toInt)

                    var order = 0
                    for status in statusList {
                        order += 1
                        status.order = order
                    }
                })
            } else {
                // MARK:Show tasks without statuses
                ForEach(CommonTaskListSections.allCases) { section in
                    DisclosureGroup(section.localizedString(), isExpanded: Binding<Bool>(
                        get: { groupsExpanded.contains(section.rawValue) },
                        set: { isExpanding in
                            if isExpanding {
                                groupsExpanded.insert(section.rawValue)
                            } else {
                                groupsExpanded.remove(section.rawValue)
                            }
                        }
                    )) {
                        ForEach(section == .completed ? searchResults.filter({ $0.completed && $0.parentTask == nil }) : searchResults.filter({ $0.completed == false })
                            .sorted(by: TasksQuery.defaultSorting),
                                id: \.self) { task in
                            if let subtasks = task.subtasks, subtasks.count > 0 {
                                OutlineGroup([task],
                                             id: \.self,
                                             children: \.subtasks) { maintask in
                                    TaskRowView(task: maintask, showingProject: false)
                                        .modifier(ProjectTaskModifier(task: maintask,
                                                                      selectedTasksSet: $selectedTasks.tasks,
                                                                      project: project,
                                                                      tasks: Binding(
                                                                        get: { project.tasks ?? [] },
                                                                        set: { project.tasks = $0 })))
                                        .modifier(TaskSwipeModifier(task: maintask, list: .projects, tasks: Binding(
                                            get: { project.tasks ?? [] },
                                            set: { project.tasks = $0 })))
                                        .tag(maintask)
                                }
                            } else {
                                TaskRowView(task: task, showingProject: false)
                                    .modifier(ProjectTaskModifier(task: task,
                                                                  selectedTasksSet: $selectedTasks.tasks,
                                                                  project: project,
                                                                  tasks: Binding(
                                                                    get: { project.tasks ?? [] },
                                                                    set: { project.tasks = $0 })))
                                    .modifier(TaskSwipeModifier(task: task, list: .projects, tasks: Binding(
                                        get: { project.tasks ?? [] },
                                        set: { project.tasks = $0 })))
                                    .tag(task)
                            }
                        }
                    }
                    .dropDestination(for: Todo.self) { tasks, _ in
                        for task in tasks {
                            task.disconnectFromParentTask()
                            task.parentTask = nil
                            
                            if section == CommonTaskListSections.completed {
                                if !task.completed {
                                    task.complete(modelContext: modelContext)
                                }
                            } else {
                                task.reactivate()
                            }
                        }
                        return true
                    }
                    
                }
            }
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: "Search tasks")
    }
    
    private func deleteTask(task: Todo) {
        withAnimation {
            TasksQuery.deleteTask(context: modelContext,
                                  task: task)
        }
    }
    
    private func deleteItems() {
        withAnimation {
            for task in selectedTasks.tasks {
                TasksQuery.deleteTask(context: modelContext,
                                      task: task)
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var selectedTasks = SelectedTasks()
    @Previewable @StateObject var showInspector = InspectorToggler()
    @Previewable @State var refresher = Refresher()
    @Previewable @StateObject var timer = FocusTimer(workInSeconds: 1500,
                                                     breakInSeconds: 300,
                                                     longBreakInSeconds: 1200,
                                                     workSessionsCount: 4)
                              
    @Previewable @StateObject var focusTask = FocusTask()
    @Previewable @State var container = try? ModelContainer(for: Schema([
                                                            ProjectGroup.self,
                                                            Status.self,
                                                            Todo.self,
                                                            Project.self
                                                        ]),
                                                       configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    let previewer = Previewer(container!)

    ProjectTasksListView(project: previewer.project)
        .environmentObject(showInspector)
        .environmentObject(selectedTasks)
        .environmentObject(refresher)
        .environmentObject(timer)
        .environmentObject(focusTask)
        .modelContainer(container!)
}
