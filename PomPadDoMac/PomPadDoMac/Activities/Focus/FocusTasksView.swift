//
//  FocusTasksView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 08.08.2024.
//

import SwiftUI
import SwiftData

struct FocusTasksView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var timer: FocusTimer
    @Binding var selectedTask: Todo?
    @Binding var viewMode: Int
    
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    
    var body: some View {
        List(tasksTodayActive.sorted(by: TasksQuery.defaultSorting),
             id: \.self) { task in
            if let subtasks = task.subtasks, subtasks.count > 0 {
                OutlineGroup([task],
                             id: \.self,
                             children: \.subtasks) { maintask in
                    HStack {
                        TaskRowView(task: maintask)
                            .tag(maintask)
                        
                        Button {
                            selectedTask = maintask
                            viewMode = 1
                            if timer.state == .idle {
                                timer.reset()
                                timer.start()
                            }
                        } label: {
                            Image(systemName: "play.fill")
                        }
                    }
                }
            } else {
                HStack {
                    TaskRowView(task: task)
                        .tag(task)
                    
                    Button {
                        selectedTask = task
                        viewMode = 1
                        if timer.state == .idle {
                            timer.reset()
                            timer.start()
                        }
                    } label: {
                        Image(systemName: "play.fill")
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var viewMode = 0
    @Previewable @State var selectedTask: Todo?
    @Previewable @State var timer = FocusTimer(workInSeconds: 1500,
                           breakInSeconds: 300,
                           longBreakInSeconds: 1200,
                           workSessionsCount: 4)
    
    do {
        let previewer = try Previewer()
        
        return FocusTasksView(selectedTask: $selectedTask, viewMode: $viewMode)
            .modelContainer(previewer.container)
            .environmentObject(timer)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
