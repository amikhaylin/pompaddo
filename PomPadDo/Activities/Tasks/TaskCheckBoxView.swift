//
//  TaskCheckBoxView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 14.04.2024.
//

import SwiftUI
import SwiftData
import WidgetKit

struct TaskCheckBoxView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var task: Todo
    
    var body: some View {
        Button(action: {
            if !task.completed {
                task.complete(modelContext: modelContext)
            } else {
                task.reactivate()
            }
            #if os(watchOS)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }, label: {
            if task.completed {
                Image(systemName: "checkmark.square.fill")
                    .foregroundStyle(Color.gray)
            } else {
                Image(systemName: "square")
                    .foregroundStyle(getColor())
            }
        })
        .buttonStyle(PlainButtonStyle())
        .sensoryFeedback(.success, trigger: task.completed)
    }
    
    func getColor() -> Color {
        switch task.priority {
        case 1:
            return .blue
        case 2:
            return .yellow
        case 3:
            return .red
        default:
            return .gray
        }
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
