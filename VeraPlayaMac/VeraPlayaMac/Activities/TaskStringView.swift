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
            } else {
                Text("No project")
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
            TasksListView(tasks: subtasks, selectedTask: selectedTask)
        }
    }
}

//#Preview {
//    do {
//        let previewer = try Previewer()
//        
//        return TaskStringView(task: previewer.task)
//    } catch {
//        return Text("Failed to create preview: \(error.localizedDescription)")
//    }
//}
