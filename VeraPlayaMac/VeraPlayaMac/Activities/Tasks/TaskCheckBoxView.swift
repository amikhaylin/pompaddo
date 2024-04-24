//
//  TaskCheckBoxView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 14.04.2024.
//

import SwiftUI
import SwiftData

struct TaskCheckBoxView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var task: Todo
    
    var body: some View {
        Button(action: {
            if !task.completed {
                if let newTask = task.complete() {
                    modelContext.insert(newTask)
                }
            } else {
                task.reactivate()
            }
        }, label: {
            if task.completed {
                Image(systemName: "checkmark.square.fill")
            } else {
                Image(systemName: "square")
            }
        })
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        
        return TaskCheckBoxView(task: previewer.task)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
