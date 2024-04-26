//
//  ProjectTasksListView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 27.03.2024.
//

import SwiftUI
import SwiftData

struct ProjectTasksListView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedTasks: Set<Todo>
    @Binding var currentTask: Todo?
    
    @Bindable var project: Project
    @State private var groupsExpanded = true
    
    var body: some View {
        List(selection: $selectedTasks) {
            ForEach(project.statuses.sorted(by: { $0.order < $1.order })) { status in
                DisclosureGroup(status.name, isExpanded: $groupsExpanded) {
                    OutlineGroup(project.tasks
                                    .filter({ $0.status == status && $0.parentTask == nil })
                                    .sorted(by: TasksQuery.defaultSorting),
                                 id: \.self,
                                 children: \.subtasks) { task in
                        TaskRowView(task: task, showingProject: false)
                            .draggable(task)
                            .dropDestination(for: Todo.self) { tasks, _ in
                                for dropTask in tasks where dropTask != task {
                                    dropTask.disconnect()
                                    dropTask.project = nil
                                    dropTask.status = nil
                                    dropTask.parentTask = task
                                    dropTask.reconnect()
                                }
                                return true
                            }
                            .contextMenu {
                                Button {
                                    selectedTasks = []
                                    let subtask = Todo(name: "", parentTask: task)
                                    task.subtasks?.append(subtask)
                                    modelContext.insert(subtask)

                                    currentTask = subtask
                                } label: {
                                    Image(systemName: "plus")
                                    Text("Add subtask")
                                }
                                
                                Button {
                                    selectedTasks = []
                                    let newTask = task.copy(modelContext: modelContext)
                                    modelContext.insert(newTask)
                                    newTask.reconnect()
                                    
                                    currentTask = newTask
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                    Text("Dublicate task")
                                }
                                
                                Button {
                                    deleteTask(task: task)
                                } label: {
                                    Image(systemName: "trash")
                                    Text("Delete task")
                                }
                            }
                    }
                }
                .dropDestination(for: Todo.self) { tasks, _ in
                    for task in tasks {
                        if status.doCompletion {
                            if !task.completed {
                                task.complete(modelContext: modelContext)
                            }
                        } else {
                            task.reactivate()
                        }
                        task.status = status
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
        @State var currentTask: Todo?
        @State var project = previewer.project
        
        return ProjectTasksListView(selectedTasks: $selectedTasks,
                                    currentTask: $currentTask,
                                    project: previewer.project)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
