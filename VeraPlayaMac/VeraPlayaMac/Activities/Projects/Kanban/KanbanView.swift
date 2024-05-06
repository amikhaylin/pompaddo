//
//  KanbanView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 12.04.2024.
//

import SwiftUI
import SwiftData

struct KanbanView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var project: Project
    
    @Binding var selectedTasks: Set<Todo>
    @Binding var currentTask: Todo?
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                
                ForEach(project.statuses.sorted(by: { $0.order < $1.order })) { status in
                    VStack {
                        Text(status.name)
                        List(selection: $selectedTasks) {
                            OutlineGroup(project.tasks
                                .filter({ $0.status == status && $0.parentTask == nil })
                                .sorted(by: TasksQuery.defaultSorting),
                                         id: \.self,
                                         children: \.subtasks) { task in
                                KanbanTaskRowView(task: task, completed: task.completed)
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
                                            selectedTasks = []
                                            let subtask = Todo(name: "", parentTask: task)
                                            task.subtasks?.append(subtask)
                                            modelContext.insert(subtask)
                                            
                                            currentTask = subtask
                                        } label: {
                                            Image(systemName: "plus")
                                            Text("Add subtask")
                                        }
                                        Divider()
                                        
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
                        //                        .cornerRadius(10)
                        //                        .shadow(radius: 10)
                    }
                    .dropDestination(for: Todo.self) { tasks, _ in
                        for task in tasks {
                            // FIXME: disconnect child task
//                            task.disconnect()
//                            task.parentTask = nil
//                            task.reconnect()
                            
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
        
        return KanbanView(project: project,
                            selectedTasks: $selectedTasks,
                            currentTask: $currentTask)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
    
}
