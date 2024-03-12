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
    var selectedTask: Binding<Todo?>
    @State var list: SideBarItem
    @State private var newTaskIsShowing = false
    
    var body: some View {
        List(tasks, id: \.self, selection: selectedTask) { task in
            TaskStringView(task: task, selectedTask: selectedTask)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    newTaskIsShowing.toggle()
                } label: {
                    Label("Add task to current list", systemImage: "plus")
                }
            }

            ToolbarItem {
                Button {
                    deleteTask(task: selectedTask.wrappedValue)
                } label: {
                    Label("Delete task", systemImage: "trash")
                }.disabled(selectedTask.wrappedValue == nil)
            }
        }
        .sheet(isPresented: $newTaskIsShowing) {
            // TODO: here we show new task sheet
            NewTaskView(isVisible: self.$newTaskIsShowing, list: list)
        }
    }
    
    private func deleteTask(task: Todo?) {
        if let task = task {
            modelContext.delete(task)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(tasks[index])
            }
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        let tasks: [Todo] = [previewer.task]
        @State var selectedTask: Todo?
        
        return TasksListView(tasks: tasks, selectedTask: $selectedTask, list: .inbox)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
