//
//  MainView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 13.05.2024.
//

import SwiftUI
import SwiftData
import StoreKit

import SwiftDataTransferrable

enum MainViewTabs {
    case tasks
    case focus
    case settings
}

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.modelContext) private var modelContext
    @AppStorage("timerWorkSession") private var timerWorkSession: Double = 1500.0
    @AppStorage("timerBreakSession") private var timerBreakSession: Double = 300.0
    @AppStorage("timerLongBreakSession") private var timerLongBreakSession: Double = 1200.0
    @AppStorage("timerWorkSessionsCount") private var timerWorkSessionsCount: Double = 4.0
    
    @AppStorage("appVersion") private var savedVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    @AppStorage("firstLaunchDate") private var firstLaunchDate: Date = Date()
    
    @StateObject var timer = FocusTimer(workInSeconds: 1500,
                           breakInSeconds: 300,
                           longBreakInSeconds: 1200,
                           workSessionsCount: 4)
    
    @State private var newTaskIsShowing = false
    @State private var tab: MainViewTabs = .tasks
    
    @State private var focusMode: FocusTimerMode = .work
    @StateObject var focusTask = FocusTask()
    
    @State private var refresh = false
    @State private var refresher = Refresher()
    
    @State var selectedSideBarItem: SideBarItem? = .today
    @State var selectedProject: Project?
    
    var body: some View {
//        GeometryReader { geometry in
            VStack {
                Group {
                    switch tab {
                    case .tasks:
                        ContentView(selectedSideBarItem: $selectedSideBarItem,
                                    selectedProject: $selectedProject)
                            .id(refresher.refresh)
                            .environmentObject(refresher)
                            .environmentObject(timer)
                            .environmentObject(focusTask)
                    case .focus:
                        FocusTimerView(focusMode: $focusMode)
                            .id(refresh)
                            .environmentObject(timer)
                            .environmentObject(focusTask)
                            .refreshable {
                                refresh.toggle()
                            }
                    case.settings:
                        SettingsView()
                    }
                }
                
                HStack {
                    Spacer()
                    
                    Button {
                        tab = .tasks
                    } label: {
                        Image(systemName: "checkmark.square")
                    }
                    .modifier(ConditionalButtonStyle(condition: tab == .tasks))
                    .buttonBorderShape(.capsule)
                    .accessibility(identifier: "TasksSection")
                    
                    Spacer()
                    
                    Button {
                        tab = .focus
                    } label: {
                        FocusTabItemView()
                            .environmentObject(timer)
                    }
                    .modifier(ConditionalButtonStyle(condition: tab == .focus))
                    .buttonBorderShape(.capsule)
                    .accessibility(identifier: "FocusSection")
                    
                    Spacer()
                    
                    Button {
                        tab = .settings
                    } label: {
                        Image(systemName: "gear")
                    }
                    .modifier(ConditionalButtonStyle(condition: tab == .settings))
                    .buttonBorderShape(.capsule)
                    .accessibility(identifier: "SettingsSection")
                    
                    Spacer()
                    
                    Button {
                        newTaskIsShowing.toggle()
                    } label: {
                        Image(systemName: "tray.and.arrow.down.fill")
                            .foregroundStyle(Color.orange)
                    }
                    .accessibility(identifier: "AddTaskToInboxButton")
                    .keyboardShortcut("i", modifiers: [.command])
                    .sheet(isPresented: $newTaskIsShowing, content: {
                        NewTaskView(isVisible: self.$newTaskIsShowing, list: .inbox, project: nil, mainTask: nil)
                            .presentationDetents([.height(220)])
                            .presentationDragIndicator(.visible)
                            .environmentObject(refresher)
                    })
                    .modifier(GlassButtonStyle())
                    .buttonBorderShape(.capsule)
                    
                    Spacer()
                }
            }
            .onAppear {
                timer.setDurations(workInSeconds: timerWorkSession,
                                   breakInSeconds: timerBreakSession,
                                   longBreakInSeconds: timerLongBreakSession,
                                   workSessionsCount: Int(timerWorkSessionsCount))
                
                checkForReview()
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
            .onChange(of: timer.sessionsCounter, { _, newValue in
                if let task = focusTask.task, newValue > 0 {
                    task.tomatoesCount += 1
                }
            })
            .onOpenURL { url in
                if url.scheme == "pompaddo" && url.host == "addtoinbox" {
                    newTaskIsShowing.toggle()
                } else if url.scheme == "pompaddo" && url.host == "new" {
                    print(url.absoluteString)
                    let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                    if let title = components?.queryItems?.first(where: { $0.name == "title" })?.value {
                        let task = Todo(name: title)
                        if let link = components?.queryItems?.first(where: { $0.name == "link" })?.value, let linkurl = URL(string: link) {
                            task.link = linkurl.absoluteString
                        }
                        modelContext.insert(task)
                    }
                } else {
                    return
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background && timer.state == .running {
                    timer.setNotification()
                }
            }
//        }
    }
    
    private func checkForReview() {
        let daysBeforeRequest = 7
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        
        print("currentVersion: \(currentVersion)")
        print("savedVersion: \(savedVersion)")

        if savedVersion != currentVersion {
            // Новая версия — сохраняем дату первого запуска
            savedVersion = currentVersion
            firstLaunchDate = Date()
        }

        let daysSinceFirstLaunch = Calendar.current.dateComponents([.day], from: firstLaunchDate, to: Date()).day ?? 0
        
        print("daysSinceFirstLaunch: \(daysSinceFirstLaunch)")
        print("firstLaunchDate: \(firstLaunchDate)")
        
        if daysSinceFirstLaunch >= daysBeforeRequest {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                print("Request review")
                AppStore.requestReview(in: scene)
                // Чтобы не запрашивать повторно:
                firstLaunchDate = Date.distantFuture
            }
        }
    }
}

#Preview {
    let previewer = try? Previewer()
    
    MainView()
        .modelContainer(previewer!.container)
}
