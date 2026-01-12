//
//  TaskCheckBoxView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 14.04.2024.
//

import SwiftUI
import SwiftData
import WidgetKit
import CloudStorage

struct TaskCheckBoxView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var focusTask: FocusTask
    @EnvironmentObject var timer: FocusTimer
    @Bindable var task: Todo
    
    @CloudStorage("bujoCheckboxes") var bujoCheckboxes: Bool = false
    
    var body: some View {
        Button(action: {
            if !task.completed {
                if let focus = focusTask.task, task == focus {
                    timer.reset()
                    if timer.mode == .pause || timer.mode == .longbreak {
                        timer.skip()
                    }
                    focusTask.task = nil
                }
                task.complete(modelContext: modelContext)
            } else {
                task.reactivate()
            }
            #if os(watchOS)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }, label: {
            if task.completed {
                if bujoCheckboxes {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.gray)
                } else {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundStyle(Color.gray)
                }
            } else {
                if bujoCheckboxes {
                    Image("dot")
                        .foregroundStyle(getColor())
                } else {
                    Image(systemName: "square")
                        .foregroundStyle(getColor())
                }
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
    let previewer = try? Previewer()
    
    TaskCheckBoxView(task: previewer!.task)
        .modelContainer(previewer!.container)
}
