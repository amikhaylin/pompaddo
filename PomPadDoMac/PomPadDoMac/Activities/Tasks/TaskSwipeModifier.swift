//
//  TaskSwipeModifier.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 11.06.2024.
//

import SwiftUI
import SwiftData

struct TaskSwipeModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @Bindable var task: Todo
    
    func body(content: Content) -> some View {
        content
            .swipeActions {
                Button(role: .destructive) {
                    withAnimation {
                        TasksQuery.deleteTask(context: modelContext,
                                              task: task)
                    }
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
            .swipeActions(edge: .leading) {
                Button {
                    if !task.completed {
                        task.complete(modelContext: modelContext)
                    } else {
                        task.reactivate()
                    }
                } label: {
                    if !task.completed {
                        Label("Complete", systemImage: "checkmark.square.fill")
                    } else {
                        Label("Reactivate", systemImage: "square")
                    }
                }
                .tint(.green)
            }
    }
}
