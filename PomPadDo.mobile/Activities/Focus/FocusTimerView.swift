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
    @EnvironmentObject var timer: FocusTimer
    
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    
    @AppStorage("focus-timer-tab") private var viewMode = 0
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
                FocusTasksView(selectedTask: $selectedTask, viewMode: $viewMode)
                    .environmentObject(timer)
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
                        
                        // start
                        if timer.state == .idle {
                            Button {
                                timer.start()
                            } label: {
                                Label("Start", systemImage: "play.fill")
                            }
                            .padding()
                            .accessibility(identifier: "StartTimerButton")
                        }
                        // resume
                        if timer.state == .paused {
                            Button {
                                timer.resume()
                            } label: {
                                Label("Resume", systemImage: "play.fill")
                            }
                            .padding()
                            .accessibility(identifier: "ResumeTimerButton")
                        }
                        // pause
                        if timer.state == .running {
                            Button {
                                timer.pause()
                            } label: {
                                Label("Pause", systemImage: "pause.fill")
                            }
                            .padding()
                            .accessibility(identifier: "PauseTimerButton")
                        }
                        // reset / stop
                        if timer.state == .running || timer.state == .paused {
                            if timer.mode == .pause || timer.mode == .longbreak {
                                Button {
                                    timer.reset()
                                    timer.skip()
                                    timer.start()
                                } label: {
                                    Label("Skip", systemImage: "forward.fill")
                                }
                                .padding()
                                .accessibility(identifier: "SkipTimerButton")
                            } else {
                                Button {
                                    timer.reset()
                                    if timer.mode == .pause || timer.mode == .longbreak {
                                        timer.skip()
                                    }
                                } label: {
                                    Label("Stop", systemImage: "stop.fill")
                                }
                                .padding()
                                .accessibility(identifier: "StopTimerButton")
                            }
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
            if let task = selectedTask, newValue > 0 {
                task.tomatoesCount += 1
            }
        })
    }
}

#Preview {
    @State var focusMode: FocusTimerMode = .work
    @StateObject var timer = FocusTimer(workInSeconds: 1500,
                                                     breakInSeconds: 300,
                                                     longBreakInSeconds: 1200,
                                                     workSessionsCount: 4)
    do {
        let previewer = try Previewer()
        
        return FocusTimerView(focusMode: $focusMode)
        .environmentObject(timer)
        .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
