//
//  ProjectTaskModifier.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 11.06.2024.
//
// swiftlint:disable function_body_length

import SwiftUI
import SwiftData

struct ProjectTaskModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @Bindable var task: Todo
    @Binding var selectedTasks: Set<Todo>
    @Bindable var project: Project
    @Query var projects: [Project]
    
    func body(content: Content) -> some View {
        content
            .draggable(task)
            .dropDestination(for: Todo.self) { tasks, _ in
                // Attach dropped task as subtask
                for dropTask in tasks where dropTask != task {
                    dropTask.disconnectFromAll()
                    dropTask.project = nil
                    dropTask.status = nil
                    dropTask.parentTask = task
                    dropTask.reconnect()
                }
                return true
            }
            .contextMenu {
                Button {
                    task.dueDate = nil
                } label: {
                    Image(systemName: "clear")
                    Text("Clear due date")
                }
                
                Button {
                    task.dueDate = Calendar.current.startOfDay(for: Date())
                } label: {
                    Image(systemName: "calendar")
                    Text("Today")
                }
                
                Button {
                    task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                } label: {
                    Image(systemName: "sunrise")
                    Text("Tomorrow")
                }
                
                if task.repeation != .none {
                    Button {
                        task.skip()
                    } label: {
                        Image(systemName: "arrow.uturn.forward")
                        Text("Skip")
                    }
                }
                Divider()
                
                Button {
                    selectedTasks.removeAll()
                    let subtask = Todo(name: "", parentTask: task)
                    task.subtasks?.append(subtask)
                    modelContext.insert(subtask)

                    selectedTasks.insert(subtask)
                } label: {
                    Image(systemName: "plus")
                    Text("Add subtask")
                }
                
                if let subtasks = task.subtasks, subtasks.count > 0 {
                    NavigationLink {
                        TasksListView(tasks: subtasks,
                                      list: .projects,
                                      title: task.name,
                                      mainTask: task)
                    } label: {
                        Image(systemName: "arrow.right")
                        Text("Open subtasks")
                    }
                }
                
                if let url = URL(string: task.link) {
                    Link(destination: url,
                         label: {
                        Image(systemName: "link")
                        Text("Open link")
                    })
                }
                
                Divider()
                
                Button {
                    task.disconnectFromAll()
                    task.project = nil
                    task.status = nil
                } label: {
                    Image(systemName: "tray.fill")
                    Text("Move to Inbox")
                }
                
                Menu {
                    ForEach(projects) { project in
                        Button {
                            task.project = project
                            task.status = project.getStatuses().sorted(by: { $0.order < $1.order }).first
                            project.tasks?.append(task)
                        } label: {
                            Text(project.name)
                        }
                    }
                } label: {
                    Text("Move task to project")
                }
                
                Menu {
                    ForEach(project.getStatuses().sorted(by: { $0.order < $1.order })) { status in
                        Button {
                            task.moveToStatus(status: status,
                                              project: project,
                                              context: modelContext)
                        } label: {
                            Text(status.name)
                        }
                    }
                } label: {
                    Text("Move to status")
                }
                
                Divider()
                
                Button {
                    selectedTasks.removeAll()
                    let newTask = task.copy(modelContext: modelContext)
                    modelContext.insert(newTask)
                    newTask.reconnect()
                    
                    selectedTasks.insert(newTask)
                } label: {
                    Image(systemName: "doc.on.doc")
                    Text("Dublicate task")
                }
                
                Button {
                    withAnimation {
                        TasksQuery.deleteTask(context: modelContext,
                                              task: task)
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(Color.red)
                    Text("Delete task")
                }
            }
    }
}
// swiftlint:enable function_body_length
