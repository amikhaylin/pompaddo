//
//  BoardView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 12.04.2024.
//

import SwiftUI
import SwiftData

struct BoardView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var project: Project
    
    @Binding var selectedTasks: Set<Todo>
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                
                ForEach(project.getStatuses().sorted(by: { $0.order < $1.order })) { status in
                    VStack {
                        Text(status.name)
                        List(selection: $selectedTasks) {
                            OutlineGroup(project.getTasks()
                                .filter({ $0.status == status && $0.parentTask == nil })
                                .sorted(by: TasksQuery.defaultSorting),
                                         id: \.self,
                                         children: \.subtasks) { task in
                                TaskRowView(task: task, showingProject: false, nameLineLimit: 5)
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
                                            deleteTask(task: task)
                                        } label: {
                                            Image(systemName: "trash")
                                                .foregroundStyle(Color.red)
                                            Text("Delete task")
                                        }
                                    }
                            }
                            .listRowSeparator(.visible)
                        }
                        .cornerRadius(5)
                    }
                    .dropDestination(for: Todo.self) { tasks, _ in
                        for task in tasks {
                            task.disconnectFromParentTask()
                            task.parentTask = nil
                            task.project = project
                            project.tasks?.append(task)
                            
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
                    .frame(minWidth: 200, idealWidth: 300)
                    //                    .padding()
                    
                }
            }
        }
        .padding()
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
        
        return BoardView(project: project,
                            selectedTasks: $selectedTasks)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
    
}
