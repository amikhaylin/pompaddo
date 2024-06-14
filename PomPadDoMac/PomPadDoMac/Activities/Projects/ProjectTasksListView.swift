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
    @Binding var selectedTasks: Set<Todo>
    
    @Bindable var project: Project
    
    var body: some View {
        List(selection: $selectedTasks) {
            ForEach(project.getStatuses().sorted(by: { $0.order < $1.order })) { status in
                @Bindable var status = status
                DisclosureGroup(status.name, isExpanded: $status.expanded) {
                    ForEach(project.getTasks()
                                .filter({ $0.status == status && $0.parentTask == nil })
                                .sorted(by: TasksQuery.defaultSorting),
                            id: \.self) { task in
                        if let subtasks = task.subtasks, subtasks.count > 0 {
                            OutlineGroup([task],
                                         id: \.self,
                                         children: \.subtasks) { maintask in
                                TaskRowView(task: maintask, showingProject: false)
                                    .modifier(ProjectTaskModifier(task: maintask,
                                                                  selectedTasks: $selectedTasks,
                                                                  project: project))
                                    .modifier(TaskSwipeModifier(task: maintask))
                                    .tag(maintask)
                            }
                        } else {
                            TaskRowView(task: task, showingProject: false)
                                .modifier(ProjectTaskModifier(task: task,
                                                              selectedTasks: $selectedTasks,
                                                              project: project))
                                .modifier(TaskSwipeModifier(task: task))
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
    }
    
    private func deleteTask(task: Todo) {
        withAnimation {
            TasksQuery.deleteTask(context: modelContext,
                                  task: task)
        }
    }
    
    private func deleteItems() {
        withAnimation {
            for task in selectedTasks {
                TasksQuery.deleteTask(context: modelContext,
                                      task: task)
            }
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var selectedTasks = Set<Todo>()
        @State var project = previewer.project
        
        return ProjectTasksListView(selectedTasks: $selectedTasks,
                                    project: previewer.project)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
