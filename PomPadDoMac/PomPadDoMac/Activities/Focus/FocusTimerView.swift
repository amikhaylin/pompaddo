//
//  FocusTimerView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 30.04.2024.
//

import SwiftUI
import SwiftData

struct FocusTimerView: View {
    // TODO: Change values in settings
    var timer = FocusTimer(workInSeconds: 1500,
                           breakInSeconds: 300,
                           longBreakInSeconds: 1200,
                           workSessionsCount: 4)
    
    @Binding var timerCount: String
    @Binding var focusMode: FocusTimerMode
    
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    
    @State private var viewMode = 0
    @State private var selectedTask: Todo?
    
    @State private var currentDate = Date()
    
    var body: some View {
        VStack {
            HStack {
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
                
                Button {
                    currentDate = .now
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            }
            
            if viewMode == 0 {
                // MARK: Task list
                List(tasksTodayActive.sorted(by: TasksQuery.defaultSorting),
                     children: \.subtasks, selection: $selectedTask) { task in
                    HStack {
                        TaskRowView(task: task)
                        
                        Button {
                            selectedTask = task
                            viewMode = 1
                            timer.reset()
                            timer.start()
                        } label: {
                            Image(systemName: "play.fill")
                        }
                    }
                }
            } else {
                VStack {
                    Spacer()
                    // MARK: Focus timer
                    if let task = selectedTask {
                        HStack {
                            Text(task.name)
                                .padding()
                            Button {
                                selectedTask = nil
                            } label: {
                                Image(systemName: "clear")
                            }
                        }
                    }
                    
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
                    
                    if timer.state == .idle && (timer.mode == .pause || timer.mode == .longbreak) {
                        Button("Skip") {
                            timer.reset()
                            timer.skip()
                        }
                    }
                    // start
                    if timer.state == .idle {
                        Button("Start") {
                            timer.start()
                        }
                    }
                    // resume
                    if timer.state == .paused {
                        Button("Resume") {
                            timer.resume()
                        }
                    }
                    // pause
                    if timer.state == .running {
                        Button("Pause") {
                            timer.pause()
                        }
                    }
                    // reset
                    if timer.state == .running || timer.state == .paused {
                        Button("Stop") {
                            timer.reset()
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .onChange(of: timer.secondsLeft, { _, _ in
            timerCount = timer.secondsLeftString
        })
        .onChange(of: timer.mode, { _, _ in
            focusMode = timer.mode
        })
        .onChange(of: timer.sessionsCounter, { oldValue, newValue in
            if let task = selectedTask, newValue > oldValue {
                task.tomatoesCount += 1
            }
        })
        .padding()
        .frame(width: 400, height: 400)
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var timerString: String = "$$$$"
        @State var focusMode: FocusTimerMode = .work
        
        return FocusTimerView(timerCount: $timerString,
                              focusMode: $focusMode)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
