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
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("timerWorkSession") private var timerWorkSession: Double = 1500.0
    @AppStorage("timerBreakSession") private var timerBreakSession: Double = 300.0
    @AppStorage("timerLongBreakSession") private var timerLongBreakSession: Double = 1200.0
    @AppStorage("timerWorkSessionsCount") private var timerWorkSessionsCount: Double = 4.0
    
    @StateObject var timer = FocusTimer(workInSeconds: 1500,
                           breakInSeconds: 300,
                           longBreakInSeconds: 1200,
                           workSessionsCount: 4)
    
    @State private var newTaskIsShowing = false
    @State private var tab: MainViewTabs = .tasks
    
    @State private var focusMode: FocusTimerMode = .work
    @State var focusTask: Todo?
    
    @State private var refresh = false
    @State private var refresher = Refresher()
    
    var body: some View {
        Group {
            switch tab {
            case .tasks:
                ContentView()
                    .environmentObject(refresher)
            case .focus:
                FocusTimerView(focusMode: $focusMode,
                               selectedTask: $focusTask)
                    .id(refresh)
                    .environmentObject(timer)
                    .refreshable {
                        refresh.toggle()
                    }
            case.settings:
                SettingsView()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    tab = .tasks
                } label: {
                    Image(systemName: "checkmark.square")
                        .foregroundStyle(tab == .tasks ? Color.blue : Color.gray)
                }
                .accessibility(identifier: "TasksSection")

                Spacer()

                Button {
                    tab = .focus
                } label: {
                    FocusTabItemView(tab: $tab)
                        .environmentObject(timer)
                }
                .accessibility(identifier: "FocusSection")

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
                .keyboardShortcut("i", modifiers: [.command]) 
                .popover(isPresented: $newTaskIsShowing, attachmentAnchor: .point(.bottomTrailing), content: {
                    NewTaskView(isVisible: self.$newTaskIsShowing, list: .inbox, project: nil, mainTask: nil, tasks: .constant([]))
                        .frame(minWidth: 200, maxHeight: 180)
                        .presentationCompactAdaptation(.popover)
                        .environmentObject(refresher)
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
        .onChange(of: timer.sessionsCounter, { oldValue, newValue in
            if let task = focusTask, newValue > 0 {
                task.tomatoesCount += 1
            }
        })
        .onOpenURL { url in
            if url.absoluteString == "pompaddo://addtoinbox" {
                newTaskIsShowing.toggle()
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active && (oldPhase == .background || oldPhase == .inactive) {
                refresher.refresh.toggle()
            }
        }
    }
}

#Preview {
    MainView()
}
