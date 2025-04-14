//
//  FocusTimerView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 30.04.2024.
//

import SwiftUI
import SwiftData

struct FocusTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @EnvironmentObject var timer: FocusTimer
    @EnvironmentObject var focusTask: FocusTask
    
    @AppStorage("timerWorkSession") private var timerWorkSession: Double = 1500.0
    @AppStorage("timerBreakSession") private var timerBreakSession: Double = 300.0
    @AppStorage("timerLongBreakSession") private var timerLongBreakSession: Double = 1200.0
    @AppStorage("timerWorkSessionsCount") private var timerWorkSessionsCount: Double = 4.0
    
    @Binding var timerCount: String
    @Binding var focusMode: FocusTimerMode
    
    @State private var viewMode = 0
    @State private var textToInbox = ""
    
    var body: some View {
        VStack {
            TextField("Add task to Inbox", text: $textToInbox)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    let task = Todo(name: textToInbox)
                    modelContext.insert(task)
                    textToInbox = ""
                }
            
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
                    refresher.refresh.toggle()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            }
                
            if viewMode == 0 {
                // MARK: Task list
                FocusTasksView(selectedTask: $focusTask.task, viewMode: $viewMode)
                    .id(refresher.refresh)
                    .environmentObject(timer)
            } else {
                ZStack {
                    VStack {
                        // MARK: Focus timer
                        if let task = focusTask.task {
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
                                    focusTask.task = nil
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
                        }
                        // resume
                        if timer.state == .paused {
                            Button {
                                timer.resume()
                            } label: {
                                Label("Resume", systemImage: "play.fill")
                            }
                        }
                        // pause
                        if timer.state == .running {
                            Button {
                                timer.pause()
                            } label: {
                                Label("Pause", systemImage: "pause.fill")
                            }
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
                            } else {
                                Button {
                                    timer.reset()
                                } label: {
                                    Label("Stop", systemImage: "stop.fill")
                                }
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
        .onAppear {
            timer.setDurations(workInSeconds: timerWorkSession,
                               breakInSeconds: timerBreakSession,
                               longBreakInSeconds: timerLongBreakSession,
                               workSessionsCount: Int(timerWorkSessionsCount))
        }
        .onChange(of: timer.sessionsCounter, { _, newValue in
            if let task = focusTask.task, newValue > 0 {
                task.tomatoesCount += 1
            }
        })
        .onChange(of: timerWorkSession, { _, _ in
            timer.setDurations(workInSeconds: timerWorkSession,
                               breakInSeconds: timerBreakSession,
                               longBreakInSeconds: timerLongBreakSession,
                               workSessionsCount: Int(timerWorkSessionsCount))
        })
        .onChange(of: timerBreakSession, { _, _ in
            timer.setDurations(workInSeconds: timerWorkSession,
                               breakInSeconds: timerBreakSession,
                               longBreakInSeconds: timerLongBreakSession,
                               workSessionsCount: Int(timerWorkSessionsCount))
        })
        .onChange(of: timerLongBreakSession, { _, _ in
            timer.setDurations(workInSeconds: timerWorkSession,
                               breakInSeconds: timerBreakSession,
                               longBreakInSeconds: timerLongBreakSession,
                               workSessionsCount: Int(timerWorkSessionsCount))
        })
        .onChange(of: timerWorkSessionsCount, { _, _ in
            timer.setDurations(workInSeconds: timerWorkSession,
                               breakInSeconds: timerBreakSession,
                               longBreakInSeconds: timerLongBreakSession,
                               workSessionsCount: Int(timerWorkSessionsCount))
        })
        .padding()
        .frame(width: 400, height: 420)
    }
    
    @MainActor init(context: ModelContext,
                    timerCount: Binding<String>,
                    focusMode: Binding<FocusTimerMode>) {
        self._timerCount = timerCount
        self._focusMode = focusMode
    }
}

#Preview {
    @Previewable @State var focusMode: FocusTimerMode = .work
    @Previewable @State var timerString: String = "$$$$"
    @Previewable @StateObject var timer = FocusTimer(workInSeconds: 1500,
                                                     breakInSeconds: 300,
                                                     longBreakInSeconds: 1200,
                                                     workSessionsCount: 4)
                              
    @Previewable @StateObject var focusTask = FocusTask()
    let previewer = try? Previewer()
    
    FocusTimerView(context: previewer!.container.mainContext,
                          timerCount: $timerString,
                          focusMode: $focusMode)
        .environmentObject(timer)
        .environmentObject(focusTask)
        .modelContainer(previewer!.container)
}
