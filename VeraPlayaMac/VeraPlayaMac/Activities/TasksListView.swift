//
//  TasksListView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 15.02.2024.
//

import SwiftUI
import SwiftData

struct TasksListView: View {
    @Environment(\.modelContext) private var modelContext
    var tasks: [Todo]

    @Binding var selectedTasks: Set<Todo>
    @State var list: SideBarItem
    @State private var newTaskIsShowing = false
    
    var body: some View {
        List(tasks, id: \.self, children: \.subtasks, selection: $selectedTasks) { task in
            TaskStringView(task: task)
                .draggable(task)
                .contextMenu {
                    Button {
                        let subtask = Todo(name: "", parentTask: task)
                        task.subtasks?.append(subtask)
                        modelContext.insert(subtask)
                    } label: {
                        Image(systemName: "plus")
                        Text("Add subtask")
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
            if let parentTask = task.parentTask, let index = parentTask.subtasks?.firstIndex(of: task) {
                parentTask.subtasks?.remove(at: index)
            }
            modelContext.delete(task)
        }
    }
    
    private func deleteItems() {
        withAnimation {
            for task in selectedTasks {
                modelContext.delete(task)
            }
        }
    }
    
    private func addToCurrentList() {
        withAnimation {
            let task = Todo(name: "")
            if list == .today {
                task.dueDate = Calendar.current.startOfDay(for: Date())
            }

            modelContext.insert(task)
            selectedTasks = []
            selectedTasks.insert(task)
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        let tasks: [Todo] = [previewer.task]
        @State var selectedTasks = Set<Todo>()
        
        return TasksListView(tasks: tasks, selectedTasks: $selectedTasks, list: .inbox)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
