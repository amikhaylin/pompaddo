//
//  TasksListView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 15.05.2024.
//

import SwiftUI
import SwiftData

enum CommonTaskListSections: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    case todo = "To do"
    case completed = "Completed"
}

struct TasksListView: View {
    @Environment(\.modelContext) private var modelContext
    var tasks: [Todo]

    @Binding var selectedTasks: Set<Todo>
    
    @State var list: SideBarItem
    @State private var newTaskIsShowing = false
    @State private var groupsExpanded = true
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List(selection: $selectedTasks) {
                ForEach(CommonTaskListSections.allCases) { section in
                    DisclosureGroup(section.rawValue, isExpanded: $groupsExpanded) {
                        OutlineGroup(section == .completed ? tasks.filter({ $0.completed }) : tasks.filter({ $0.completed == false }),
                                     id: \.self,
                                     children: \.subtasks) { task in
                            TaskRowView(task: task)
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
                                        
                                        selectedTasks.insert(subtask)
                                        path.append(subtask)
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
                                        
                                        selectedTasks.insert(newTask)
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
                            task.disconnectFromParentTask()
                            task.parentTask = nil
                            setDueDate(task: task)
                            
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
            .toolbar {
                ToolbarItem {
                    Button {
                        addToCurrentList()
                    } label: {
                        Label("Add task to current list", systemImage: "plus")
                    }
                }
                
                ToolbarItem {
                    Button {
                        deleteItems()
                    } label: {
                        Label("Delete task", systemImage: "trash")
                    }.disabled(selectedTasks.count == 0)
                }
                
                ToolbarItem {
                    EditButton()
                }
            }
            .navigationDestination(for: Todo.self) { task in
                EditTaskView(task: task)
            }
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
    
    private func deleteTask(task: Todo) {
        withAnimation {
            TasksQuery.deleteTask(context: modelContext,
                                  task: task)
        }
    }
    
    private func setDueDate(task: Todo) {
        switch list {
        case .inbox:
            break
        case .today:
            task.dueDate = Calendar.current.startOfDay(for: Date())
        case .tomorrow:
            task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
        case .projects:
            break
        case .review:
            break
        }
    }

    private func addToCurrentList() {
        withAnimation {
            selectedTasks = []
            let task = Todo(name: "")
            setDueDate(task: task)
            
            modelContext.insert(task)

            selectedTasks.insert(task)
            
            path.append(task)
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        let tasks: [Todo] = [previewer.task]
        @State var selectedTasks = Set<Todo>()
        
        return TasksListView(tasks: tasks,
                             selectedTasks: $selectedTasks,
                             list: .inbox)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
