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
import CloudStorage
import WidgetKit

enum MainViewTabs {
    case tasks
    case focus
    case settings
    case inbox
}

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.modelContext) private var modelContext
    @CloudStorage("timerWorkSession") private var timerWorkSession: Double = UserDefaults.standard.value(forKey: "timerWorkSession") as? Double ?? 1500.0
    @CloudStorage("timerBreakSession") private var timerBreakSession: Double = UserDefaults.standard.value(forKey: "timerBreakSession") as? Double ?? 300.0
    @CloudStorage("timerLongBreakSession") private var timerLongBreakSession: Double = UserDefaults.standard.value(forKey: "timerLongBreakSession") as? Double ?? 1200.0
    @CloudStorage("timerWorkSessionsCount") private var timerWorkSessionsCount: Double = UserDefaults.standard.value(forKey: "timerWorkSessionsCount") as? Double ?? 4.0
    
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
    
    @Query var projects: [Project]
    @State var badgeManager = BadgeManager()
    @AppStorage("showReviewBadge") private var showReviewProjectsBadge: Bool = false
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    
    private var activeTasksCount: Int {
        var projectsCount = 0
        if showReviewProjectsBadge {
            projectsCount = projects.filter({ TasksQuery.filterProjectToReview($0) }).count
        }
        if (tasksTodayActive.count + projectsCount) > 0 {
            return tasksTodayActive.count + projectsCount
        } else {
            return 0
        }
    }
    
    var body: some View {
        TabView(selection: $tab) {
            Tab(value: .tasks) {
                ContentView(selectedSideBarItem: $selectedSideBarItem,
                            selectedProject: $selectedProject)
                    .id(refresher.refresh)
                    .environmentObject(refresher)
                    .environmentObject(timer)
                    .environmentObject(focusTask)
            } label: {
                Label("Tasks", systemImage: "checkmark.square")
                    .accessibility(identifier: "TasksSection")
            }
            .badge(activeTasksCount)
            
            Tab(value: .focus) {
                FocusTimerView(focusMode: $focusMode)
                    .id(refresh)
                    .environmentObject(timer)
                    .environmentObject(focusTask)
                    .refreshable {
                        refresh.toggle()
                    }
            } label: {
                FocusTabItemView()
                    .environmentObject(timer)
                    .accessibility(identifier: "FocusSection")
            }
            .badge(timer.secondsLeftString)
            
            Tab(value: .settings) {
                SettingsView()
            } label: {
                Label("Settings", systemImage: "gear")
                    .accessibility(identifier: "SettingsSection")
            }

            Tab(value: .inbox, role: .search) {
                EmptyView()
            } label: {
                Image(systemName: "tray.and.arrow.down.fill")
                    .foregroundStyle(Color.orange)
                    .accessibility(identifier: "AddTaskToInboxButton")
                    .keyboardShortcut("i", modifiers: [.command])
            }
        }
        .tabViewStyle(.tabBarOnly)
        .sheet(isPresented: $newTaskIsShowing, content: {
            NewTaskView(isVisible: self.$newTaskIsShowing, list: .inbox, project: nil, mainTask: nil)
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
                .environmentObject(refresher)
        })
        .onChange(of: tab) { oldValue, newValue in
            guard newValue == .inbox else { return }
            
            withAnimation {
                self.tab = oldValue
                self.newTaskIsShowing.toggle()
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
        .onChange(of: projects.filter({ TasksQuery.filterProjectToReview($0) }).count, { _, _ in
            setBadge()
        })
        .onChange(of: tasksTodayActive.count) { _, _ in
            setBadge()
        }
        .onAppear {
            setBadge()
        }
    }
    
    private func setBadge() {
        if activeTasksCount > 0 {
            badgeManager.setBadge(number: activeTasksCount)
        } else {
            badgeManager.resetBadgeNumber()
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func checkForReview() {
        let daysBeforeRequest = 3
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        
        let savedVersion: String = UserDefaults.standard.string(forKey: "appVersion") ?? ""
        var firstLaunchDate: Double = UserDefaults.standard.double(forKey: "firstLaunchDateInterval")
        var requestCount: Int = UserDefaults.standard.integer(forKey: "reviewRequestCount")
        
        print("currentVersion: \(currentVersion)")
        print("savedVersion: \(savedVersion)")
        print("requestCount: \(requestCount)")

        if savedVersion != currentVersion {
            UserDefaults.standard.set(currentVersion, forKey: "appVersion")
            firstLaunchDate = Date.now.timeIntervalSince1970
            UserDefaults.standard.set(firstLaunchDate, forKey: "firstLaunchDateInterval")
            requestCount = 0
            UserDefaults.standard.set(requestCount, forKey: "reviewRequestCount")
        }

        let daysSinceFirstLaunch = Calendar.current.dateComponents([.day], from: Date(timeIntervalSince1970: firstLaunchDate), to: Date()).day ?? 0
        
        print("daysSinceFirstLaunch: \(daysSinceFirstLaunch)")
        print("firstLaunchDate: \(Date(timeIntervalSince1970: firstLaunchDate))")
        
        if daysSinceFirstLaunch >= daysBeforeRequest {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                print("Request review")
                AppStore.requestReview(in: scene)
                requestCount += 1
                UserDefaults.standard.set(requestCount, forKey: "reviewRequestCount")
                if requestCount >= 2 {
                    UserDefaults.standard.set(Date.distantFuture.timeIntervalSince1970, forKey: "firstLaunchDateInterval")
                } else {
                    firstLaunchDate = Date.now.timeIntervalSince1970
                    UserDefaults.standard.set(firstLaunchDate, forKey: "firstLaunchDateInterval")
                }
            }
        }
    }
}

#Preview {
    let previewer = try? Previewer()
    
    MainView()
        .modelContainer(previewer!.container)
}
