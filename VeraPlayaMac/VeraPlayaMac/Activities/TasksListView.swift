//
//  InboxView.swift
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
    
    var body: some View {
        List(tasks, id: \.self, selection: selectedTask) { task in
            TaskStringView(task: task, selectedTask: selectedTask)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    deleteTask(task: selectedTask.wrappedValue)
                } label: {
                    Label("Delete task", systemImage: "trash")
                }.disabled(selectedTask.wrappedValue == nil)
            }
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
        
        return TasksListView(tasks: tasks, selectedTask: $selectedTask)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
