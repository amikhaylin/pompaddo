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
    
    @AppStorage("timerWorkSession") private var timerWorkSession: Double = 1500.0
    @AppStorage("timerBreakSession") private var timerBreakSession: Double = 300.0
    @AppStorage("timerLongBreakSession") private var timerLongBreakSession: Double = 1200.0
    @AppStorage("timerWorkSessionsCount") private var timerWorkSessionsCount: Double = 4.0
    
    var timer = FocusTimer(workInSeconds: 1500,
                           breakInSeconds: 300,
                           longBreakInSeconds: 1200,
                           workSessionsCount: 4)
    
    @Binding var timerCount: String
    @Binding var focusMode: FocusTimerMode
    
//    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    @State private var tasksTodayActive: [Todo]
    
    @State private var viewMode = 0
    @State private var selectedTask: Todo?
    @State private var textToInbox = ""
    
    var body: some View {
        VStack {
            TextField("Add task to Inbox", text: $textToInbox)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    let task = Todo(name: textToInbox)
                    modelContext.insert(task)
                    refresher.refresh.toggle()
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
                    tasksTodayActive = TasksQuery.fetchData(context: modelContext,
                                                            predicate: TasksQuery.predicateTodayActive())
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            }
                
            if viewMode == 0 {
                // MARK: Task list
                TimelineView(.periodic(from: .now, by: 5.0)) { _ in
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
        
        self.tasksTodayActive = TasksQuery.fetchData(context: context, 
                                                     predicate: TasksQuery.predicateTodayActive())
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var timerString: String = "$$$$"
        @State var focusMode: FocusTimerMode = .work
        
        return FocusTimerView(context: previewer.container.mainContext,
                              timerCount: $timerString,
                              focusMode: $focusMode)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
