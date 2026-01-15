//
//  FocusTasksView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 08.08.2024.
//

import SwiftUI
import SwiftData
import CloudStorage

struct FocusTasksView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var timer: FocusTimer
    @EnvironmentObject var focusTask: FocusTask
    @State private var selectedTask: Todo?
    @Binding var viewMode: Int
    @CloudStorage("timerSaveUnifinished") private var timerSaveUnfinished: Bool = false
    
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    
    var body: some View {
        if tasksTodayActive.count > 0 {
            List(selection: $selectedTask) {
                ForEach(tasksTodayActive.sorted(by: TasksQuery.defaultSorting),
                        id: \.self) { task in
                    if task.visibleSubtasks?.isEmpty == false {
                        OutlineGroup([task],
                                     id: \.self,
                                     children: \.visibleSubtasks) { maintask in
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
                                        if timerSaveUnfinished {
                                            focus.tomatoesCount += 1
                                        }
                                        focusTask.task = nil
                                    } label: {
                                        Image(systemName: "stop.fill")
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
                                     .listRowSeparator(.hidden)
                    } else {
                        HStack {
                            TaskRowView(task: task)
                                .modifier(FocusTaskRowModifier(task: task, viewMode: $viewMode))
                                .tag(task)
                            
                            if let focus = focusTask.task, focus == task {
                                Button {
                                    timer.reset()
                                    if timer.mode == .pause || timer.mode == .longbreak {
                                        timer.skip()
                                    }
                                    if timerSaveUnfinished {
                                        focus.tomatoesCount += 1
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
                        .listRowSeparator(.hidden)
                    }
                }
            }
        } else {
            VStack {
                Spacer()
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .foregroundStyle(Color.gray)
                    .frame(width: 100, height: 100)
                
                Text("No tasks for today")
                Spacer()
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
