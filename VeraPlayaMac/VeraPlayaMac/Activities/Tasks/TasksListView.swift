//
//  TasksListView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 15.02.2024.
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
    @Binding var currentTask: Todo?
    
    @State var list: SideBarItem
    @State private var newTaskIsShowing = false
    @State private var groupsExpanded = true
    
    var body: some View {
        List(selection: $selectedTasks) {
            ForEach(CommonTaskListSections.allCases) { section in
                DisclosureGroup(section.rawValue, isExpanded: $groupsExpanded) {
                    OutlineGroup(section == .completed ? tasks.filter({ $0.completed }) : tasks.filter({ $0.completed == false }),
                                 id: \.self,
                                 children: \.subtasks) { task in
                        TaskRowView(task: task, completed: task.completed)
                            .draggable(task)
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
                                    let newTask = task.copy()
                                    newTask.completed = false
                                    newTask.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                                    newTask.reconnect()
                                    modelContext.insert(newTask)

                                    currentTask = newTask
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                    Text("Dublicate task")
                                }
                                
                                Button {
                                    deleteItems()
                                } label: {
                                    Image(systemName: "trash")
                                    Text("Delete task")
                                }.disabled(selectedTasks.count == 0)
                            }
                    }
                }
                .dropDestination(for: Todo.self) { tasks, _ in
                    for task in tasks {
                        task.completed = section == CommonTaskListSections.completed
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
        }
    }
    
    private func deleteTask(task: Todo?) {
        if let task = task {
            task.disconnect()
            modelContext.delete(task)
        }
    }
    
    private func deleteItems() {
        withAnimation {
            for task in selectedTasks {
                task.disconnect()
                modelContext.delete(task)
            }
        }
    }
    
    private func addToCurrentList() {
        withAnimation {
            selectedTasks = []
            let task = Todo(name: "")
            switch list {
            case .inbox:
                task.project = nil
            case .today:
                task.dueDate = Calendar.current.startOfDay(for: Date())
            case .tomorrow:
                task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
            case .projects:
                break
            case .review:
                break
            }

            modelContext.insert(task)
            currentTask = task
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        let tasks: [Todo] = [previewer.task]
        @State var selectedTasks = Set<Todo>()
        @State var currentTask: Todo?
        
        return TasksListView(tasks: tasks, 
                             selectedTasks: $selectedTasks,
                             currentTask: $currentTask,
                             list: .inbox)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
