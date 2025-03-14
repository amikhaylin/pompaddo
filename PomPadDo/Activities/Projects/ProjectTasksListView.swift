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
    
    var searchResults: [Todo] {
        if searchText.isEmpty {
            return project.getTasks()
        } else {
            return project.getTasks().filter { $0.name.localizedStandardContains(searchText) }
        }
    }
    
    var body: some View {
        List(selection: $selectedTasks.tasks) {
            ForEach(project.getStatuses().sorted(by: { $0.order < $1.order })) { status in
                @Bindable var status = status
                DisclosureGroup(status.name, isExpanded: $status.expanded) {
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
    do {
        let previewer = try Previewer()
        @State var project = previewer.project
        
        return ProjectTasksListView(project: previewer.project)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
