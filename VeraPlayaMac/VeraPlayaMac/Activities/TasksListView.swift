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
    @Binding var currentTask: Todo?
    
    @State var list: SideBarItem
    @State private var newTaskIsShowing = false
    
    var body: some View {
        List(tasks, id: \.self, children: \.subtasks, selection: $selectedTasks) { task in
            TaskStringView(task: task)
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
                // TODO: change it!
                task.project = nil
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
