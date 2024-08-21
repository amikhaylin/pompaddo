//
//  TaskRowModifier.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 11.06.2024.
//
// swiftlint:disable function_body_length

import SwiftUI
import SwiftData

struct TaskRowModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @Bindable var task: Todo
    @Binding var selectedTasks: Set<Todo>
    var projects: [Project]
    var list: SideBarItem
    
    func body(content: Content) -> some View {
       content
        .draggable(task)
        .dropDestination(for: Todo.self) { tasks, _ in
            // Attach dropped task as subtask
            for dropTask in tasks where dropTask != task {
                dropTask.disconnectFromAll()
                dropTask.parentTask = task
                dropTask.reconnect()
            }
            return true
        }
        .contextMenu {
            Button {
                task.dueDate = nil
                refresher.refresh.toggle()
            } label: {
                Image(systemName: "clear")
                Text("Clear due date")
            }
            
            Button {
                task.dueDate = Calendar.current.startOfDay(for: Date())
                refresher.refresh.toggle()
            } label: {
                Image(systemName: "calendar")
                Text("Today")
            }
            
            Button {
                task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                refresher.refresh.toggle()
            } label: {
                Image(systemName: "sunrise")
                Text("Tomorrow")
            }
            
            Button {
                task.nextWeek()
                refresher.refresh.toggle()
            } label: {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                    Text("Next week")
                }
            }
            
            if task.repeation != .none {
                Button {
                    task.skip()
                    refresher.refresh.toggle()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                    Text("Skip")
                }
            }
            Divider()

            Menu {
                ForEach(0...3, id: \.self) { priority in
                    Button {
                        task.priority = priority
                        refresher.refresh.toggle()
                    } label: {
                        HStack {
                            switch priority {
                            case 3:
                                Text("High")
                            case 2:
                                Text("Medium")
                            case 1:
                                Text("Low")
                            default:
                                Text("None")
                            }
                        }
                    }
                    .tag(priority as Int)
                }
            } label: {
                Text("Priority")
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
            
            NavigationLink {
                TasksListView(tasks: task.subtasks != nil ? task.subtasks! : [Todo](),
                              list: list,
                              title: task.name,
                              mainTask: task)
                .id(refresher.refresh)
                .environmentObject(refresher)
            } label: {
                Image(systemName: "arrow.right")
                Text("Open subtasks")
            }
            
            if let parentTask = task.parentTask {
                NavigationLink {
                    TasksListView(tasks: parentTask.subtasks != nil ? parentTask.subtasks! : [Todo](),
                                  list: list,
                                  title: parentTask.name,
                                  mainTask: parentTask)
                    .id(refresher.refresh)
                    .environmentObject(refresher)
                } label: {
                    Image(systemName: "arrow.left")
                    Text("Open parent task")
                }
            }
            
            Divider()
            
            if let url = URL(string: task.link) {
                Link(destination: url,
                     label: {
                    Image(systemName: "link")
                    Text("Open link")
                })
            }
            
            Divider()
            
            Menu {
                ForEach(projects) { project in
                    Button {
                        task.project = project
                        task.status = project.getStatuses().sorted(by: { $0.order < $1.order }).first
                        project.tasks?.append(task)
                        refresher.refresh.toggle()
                    } label: {
                        Text(project.name)
                    }
                }
            } label: {
                Text("Move task to project")
            }
            
            if let project = task.project {
                Menu {
                    ForEach(project.getStatuses().sorted(by: { $0.order < $1.order })) { status in
                        Button {
                            task.moveToStatus(status: status,
                                              project: project,
                                              context: modelContext)
                            refresher.refresh.toggle()
                        } label: {
                            Text(status.name)
                        }
                    }
                } label: {
                    Text("Move to status")
                }
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
                    refresher.refresh.toggle()
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
