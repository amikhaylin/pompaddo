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
    @EnvironmentObject var focusTask: FocusTask
    @State private var selectedTask: Todo?
    @Binding var viewMode: Int
    
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    
    var body: some View {
        List(selection: $selectedTask) {
            ForEach(tasksTodayActive.sorted(by: TasksQuery.defaultSorting),
                    id: \.self) { task in
                if let subtasks = task.subtasks, subtasks.count > 0 {
                    OutlineGroup([task],
                                 id: \.self,
                                 children: \.subtasks) { maintask in
                        HStack {
                            TaskRowView(task: maintask)
                                .modifier(FocusTaskRowModifier(task: maintask, viewMode: $viewMode))
                                .tag(maintask)
                                .listRowSeparator(.hidden)
                            
                            if let focus = focusTask.task, focus == maintask {
                                Button {
                                    timer.reset()
                                    if timer.mode == .pause || timer.mode == .longbreak {
                                        timer.skip()
                                    }
                                    focusTask.task = nil
                                } label: {
                                    Image(systemName: "stop.fill")
                                    Text("Stop focus")
                                }
                            } else {
                                Button {
                                    focusTask.task = maintask
                                    viewMode = 1
                                    if timer.state == .idle {
                                        timer.reset()
                                        timer.start()
                                    } else if timer.state == .paused {
                                        timer.resume()
                                    }
                                } label: {
                                    Image(systemName: "play.fill")
                                }
                                .accessibility(identifier: "\(maintask.name)PlayButton")
                            }
                        }
                    }
                } else {
                    HStack {
                        TaskRowView(task: task)
                            .modifier(FocusTaskRowModifier(task: task, viewMode: $viewMode))
                            .tag(task)
                            .listRowSeparator(.hidden)
                        
                        if let focus = focusTask.task, focus == task {
                            Button {
                                timer.reset()
                                if timer.mode == .pause || timer.mode == .longbreak {
                                    timer.skip()
                                }
                                focusTask.task = nil
                            } label: {
                                Image(systemName: "stop.fill")
                            }
                        } else {
                            Button {
                                focusTask.task = task
                                viewMode = 1
                                if timer.state == .idle {
                                    timer.reset()
                                    timer.start()
                                } else if timer.state == .paused {
                                    timer.resume()
                                }
                            } label: {
                                Image(systemName: "play.fill")
                            }
                            .accessibility(identifier: "\(task.name)PlayButton")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var viewMode = 0
    @Previewable @State var selectedTask: Todo?
    @Previewable @StateObject var timer = FocusTimer(workInSeconds: 1500,
                           breakInSeconds: 300,
                           longBreakInSeconds: 1200,
                           workSessionsCount: 4)
    
    let previewer = try? Previewer()
    
    return FocusTasksView(viewMode: $viewMode)
        .environmentObject(timer)
        .modelContainer(previewer!.container)
}
