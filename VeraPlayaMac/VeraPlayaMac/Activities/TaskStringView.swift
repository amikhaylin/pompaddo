//
//  TaskStringView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 15.02.2024.
//

import SwiftUI
import SwiftData

struct TaskStringView: View {
    @Bindable var task: Todo
    @State private var expandSubtask = false
    var selectedTask: Binding<Todo?>
    
    var body: some View {
        HStack {
            Toggle(isOn: $task.completed, label: {
                Text(task.name)
            })
            .toggleStyle(.checkbox)
            
            Spacer()

            if let project = task.project {
                Text("\(project.name)")
            }
            
            if let dueDate = task.dueDate {
                Text(dueDate, format: .dateTime.day().month().year())
                    .foregroundStyle(Color.blue)
            }
            
            if let subtasks = task.subtasks, subtasks.count > 0 {
                Button {
                    expandSubtask.toggle()
                } label: {
                    Image(systemName: expandSubtask ? "arrowtriangle.down" : "arrowtriangle.right")
                }.buttonStyle(.plain)
            }

        }
        if let subtasks = task.subtasks, subtasks.count > 0 && expandSubtask {
            SubtasksListView(tasks: subtasks, selectedTask: selectedTask)
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        
        @State var selectedTask: Todo?
        
        return TaskStringView(task: previewer.task, selectedTask: $selectedTask)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
