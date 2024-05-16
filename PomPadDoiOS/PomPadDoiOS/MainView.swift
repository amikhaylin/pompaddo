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
    
    var body: some View {
        Group {
            switch tab {
            case .tasks:
                ContentView()
            case .focus:
                FocusTimerView(focusMode: $focusMode,
                               timer: timer)
            case.settings:
                Text("Settings")
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
                        Text(timer.secondsLeftString)
                            .foregroundStyle(focusMode == .work ? Color.red : Color.green)
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

            }
        }
        .sheet(isPresented: $newTaskIsShowing, content: {
            NewTaskView(isVisible: self.$newTaskIsShowing, list: .inbox)
                .presentationDetents([.height(200)])
        })
    }
}

#Preview {
    MainView()
}
