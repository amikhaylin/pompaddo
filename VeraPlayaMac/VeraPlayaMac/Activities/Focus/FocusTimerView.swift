//
//  FocusTimerView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 30.04.2024.
//

import SwiftUI
import SwiftData

struct FocusTimerView: View {
    var timer = FocusTimer(workInSeconds: 1500, breakInSeconds: 300)
    
    @Binding var timerCount: String
    
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    
    @State private var viewMode = 0
    @State private var selectedTask: Todo?
    
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
                            timer.start()
                        } label: {
                            Image(systemName: "play.fill")
                        }
                    }
                }
            } else {
                VStack {
                    // MARK: Focus timer
                    if let task = selectedTask {
                        Text(task.name)
                            .padding()
                    }
                    
                    ZStack {
                        CircularProgressView(progress: CGFloat(timer.fractionPassed),
                                             color: .blue,
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
                    
                    if timer.state == .idle && timer.mode == .pause {
                        Button("Skip") {
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
                .onChange(of: timer.secondsLeft, { _, _ in
                    timerCount = timer.secondsLeftString
                })
//                .padding()
            }
        }
        .padding()
        .frame(width: 400, height: 400)
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var timerString: String = "$$$$"
        
        return FocusTimerView(timerCount: $timerString)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
