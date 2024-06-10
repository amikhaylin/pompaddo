//
//  FocusTimerView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 30.04.2024.
//

import SwiftUI
import SwiftData

struct FocusTimerView: View {
    @Binding var focusMode: FocusTimerMode
    
    let timer: FocusTimer
    
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    
    @AppStorage("focus-timer-tab") private var viewMode = 0
    @Binding var selectedTask: Todo?
    
    var body: some View {
        VStack {
            Picker("", selection: $viewMode) {
                ForEach(0...1, id: \.self) { mode in
                    HStack {
                        switch mode {
                        case 0:
                            Text("Today tasks")
                        case 1:
                            Text("Focus Timer")
                        default:
                            EmptyView()
                        }
                    }
                    .tag(mode as Int)
                }
            }.pickerStyle(.segmented)
            
            if viewMode == 0 {
                // MARK: Task list
                List(tasksTodayActive.sorted(by: TasksQuery.defaultSorting),
                     children: \.subtasks, selection: $selectedTask) { task in
                    HStack {
                        TaskRowView(task: task)
                        
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
            } else {
                ZStack {
                    VStack {
                        // MARK: Focus timer
                        if let task = selectedTask {
                            HStack {
                                Text(task.name)
                                    .padding()
                                
                                if task.tomatoesCount > 0 {
                                    Image(systemName: "target")
                                        .foregroundStyle(Color.gray)
                                    Text("\(task.tomatoesCount)")
                                        .foregroundStyle(Color.gray)
                                        .font(.caption)
                                }
                                
                                Button {
                                    selectedTask = nil
                                } label: {
                                    Image(systemName: "clear")
                                }
                            }
                        }
                        
                        Spacer()
                        
                        if timer.state == .idle && (timer.mode == .pause || timer.mode == .longbreak) {
                            Button("Skip") {
                                timer.reset()
                                timer.skip()
                            }
                            .padding()
                        }
                        // start
                        if timer.state == .idle {
                            Button("Start") {
                                timer.start()
                            }
                            .padding()
                        }
                        // resume
                        if timer.state == .paused {
                            Button("Resume") {
                                timer.resume()
                            }
                            .padding()
                        }
                        // pause
                        if timer.state == .running {
                            Button("Pause") {
                                timer.pause()
                            }
                            .padding()
                        }
                        // reset
                        if timer.state == .running || timer.state == .paused {
                            Button("Stop") {
                                timer.reset()
                            }
                            .padding()
                        }
                    }
                    
                    VStack {
                        Spacer()
                        ZStack {
                            CircularProgressView(progress: CGFloat(timer.fractionPassed),
                                                 color: timer.mode == .work ? .red : .green,
                                                 lineWidth: 5)
                            .frame(width: 200, height: 200)
                            
                            VStack {
                                Text("\(timer.secondsLeftString)")
                                    .font(.system(size: 50, weight: .semibold, design: .rounded))
                                
                                Text("\(timer.mode.title)")
                                    .font(.system(size: 24, weight: .light, design: .rounded))
                                    .foregroundStyle(timer.mode == .work ? Color.red : Color.green)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .onChange(of: timer.sessionsCounter, { oldValue, newValue in
            if let task = selectedTask, newValue > oldValue {
                task.tomatoesCount += 1
            }
        })
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var focusMode: FocusTimerMode = .work
        @State var focusTask: Todo?
        
        let timer = FocusTimer(workInSeconds: 1500,
                               breakInSeconds: 300,
                               longBreakInSeconds: 1200,
                               workSessionsCount: 4)
        
        return FocusTimerView(focusMode: $focusMode,
                              timer: timer,
                              selectedTask: $focusTask)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
