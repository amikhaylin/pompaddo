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
    // TODO: Change values in settings
    var timer = FocusTimer(workInSeconds: 1500,
                           breakInSeconds: 300,
                           longBreakInSeconds: 1200,
                           workSessionsCount: 4)
    
    @State private var newTaskIsShowing = false
    @State private var tab: MainViewTabs = .tasks
    
    @State private var timerCount: String = "25:00"
    @State private var focusMode: FocusTimerMode = .work
    @State private var focusTask: Todo?
    @State private var currentDate = Date()
    
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    
    @State var badgeManager = BadgeManager()
    
    var body: some View {
        Group {
            switch tab {
            case .tasks:
                ContentView()
            case .focus:
                FocusTimerView(focusMode: $focusMode,
                               timer: timer,
                               selectedTask: $focusTask)
            case.settings:
                Text("Settings")
            }
        }
        .refreshable {
            currentDate = .now
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
                    HStack {
                        if focusMode == .work {
                            Image(systemName: "target")
                                .foregroundStyle(tab == .focus ? Color.blue : Color.gray)
                        } else {
                            Image(systemName: "cup.and.saucer.fill")
                                .foregroundStyle(tab == .focus ? Color.blue : Color.gray)
                        }
                        if timer.state == .running {
                            TimelineView(.periodic(from: .now, by: 0.5)) { _ in
                                Text(timer.secondsLeftString)
                                    .foregroundStyle(focusMode == .work ? Color.red : Color.green)
                            }
                        } else {
                            Text(timer.secondsLeftString)
                                .foregroundStyle(focusMode == .work ? Color.red : Color.green)
                        }
                            
                    }
                }

//                    Spacer()
//                    
//                    Button {
//                        tab = .settings
//                    } label: {
//                        Image(systemName: "gear")
//                            .foregroundStyle(tab == .settings ? Color.blue : Color.gray)
//                    }

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
        .onChange(of: tasksTodayActive.count) { _, newValue in
            newValue > 0 ? badgeManager.setBadge(number: newValue) : badgeManager.resetBadgeNumber()
        }
        .onAppear {
            tasksTodayActive.count > 0 ? badgeManager.setBadge(number: tasksTodayActive.count) : badgeManager.resetBadgeNumber()
        }
    }
}

#Preview {
    MainView()
}
