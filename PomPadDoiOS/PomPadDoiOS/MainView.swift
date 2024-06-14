//
//  MainView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 13.05.2024.
//

import SwiftUI
import SwiftData

import SwiftDataTransferrable

enum MainViewTabs {
    case tasks
    case focus
    case settings
}

struct MainView: View {
    @AppStorage("timerWorkSession") private var timerWorkSession: Double = 1500.0
    @AppStorage("timerBreakSession") private var timerBreakSession: Double = 300.0
    @AppStorage("timerLongBreakSession") private var timerLongBreakSession: Double = 1200.0
    @AppStorage("timerWorkSessionsCount") private var timerWorkSessionsCount: Double = 4.0
    
    var timer = FocusTimer(workInSeconds: 1500,
                           breakInSeconds: 300,
                           longBreakInSeconds: 1200,
                           workSessionsCount: 4)
    
    @State private var newTaskIsShowing = false
    @State private var tab: MainViewTabs = .tasks
    
    @State private var timerCount: String = ""
    @State private var focusMode: FocusTimerMode = .work
    @State private var focusTask: Todo?
    
    @State private var refresh = false
    
    var body: some View {
        Group {
            switch tab {
            case .tasks:
                ContentView()
                    .id(refresh)
            case .focus:
                FocusTimerView(focusMode: $focusMode,
                               timer: timer,
                               selectedTask: $focusTask)
                    .id(refresh)
            case.settings:
                SettingsView()
            }
        }
        .refreshable {
            refresh.toggle()
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    tab = .tasks
                } label: {
                    Image(systemName: "checkmark.square")
                        .foregroundStyle(tab == .tasks ? Color.blue : Color.gray)
                }

                Spacer()

                Button {
                    tab = .focus
                } label: {
                    TimelineView(.periodic(from: .now, by: 0.5)) { _ in
                        HStack {
                            if focusMode == .work {
                                Image(systemName: "target")
                                    .foregroundStyle(tab == .focus ? Color.blue : Color.gray)
                            } else {
                                Image(systemName: "cup.and.saucer.fill")
                                    .foregroundStyle(tab == .focus ? Color.blue : Color.gray)
                            }
                            if timer.state == .running {
                                Text(timer.secondsLeftString)
                                    .foregroundStyle(focusMode == .work ? Color.red : Color.green)
                            } else {
                                Text(timer.secondsLeftString)
                                    .foregroundStyle(focusMode == .work ? Color.red : Color.green)
                            }
                        }
                    }
                }

                Spacer()
                
                Button {
                    tab = .settings
                } label: {
                    Image(systemName: "gear")
                        .foregroundStyle(tab == .settings ? Color.blue : Color.gray)
                }

                Spacer()
                
                Button {
                    newTaskIsShowing.toggle()
                } label: {
                    Image(systemName: "tray.and.arrow.down.fill")
                        .foregroundStyle(Color.orange)
                }
                .popover(isPresented: $newTaskIsShowing, attachmentAnchor: .point(.bottomTrailing), content: {
                    NewTaskView(isVisible: self.$newTaskIsShowing, list: .inbox)
                        .frame(minWidth: 200, maxHeight: 180)
                        .presentationCompactAdaptation(.popover)
                })
            }
        }
        .onAppear {
            timer.setDurations(workInSeconds: timerWorkSession,
                               breakInSeconds: timerBreakSession,
                               longBreakInSeconds: timerLongBreakSession,
                               workSessionsCount: Int(timerWorkSessionsCount))
        }
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
        .onChange(of: timer.mode, { _, _ in
            focusMode = timer.mode
        })
    }
}

#Preview {
    MainView()
}
