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
    
    @State var timer = FocusTimer(workInSeconds: 1500,
                           breakInSeconds: 300,
                           longBreakInSeconds: 1200,
                           workSessionsCount: 4)
    
    @State private var newTaskIsShowing = false
    @State private var tab: MainViewTabs = .tasks
    
    @State private var focusMode: FocusTimerMode = .work
    @State var focusTask = FocusTask()
    
    @State private var refresher = Refresher()
    
    @State var selectedSideBarItem: SideBarItem? = .today
    @State var selectedProject: Project?
    
    @State var activeTasksCount: Int = 0
    #if canImport(ActivityKit)
    @State private var liveActivityManager = FocusLiveActivityManager()
    #endif
    
    var body: some View {
        MainTabsView(tab: $tab,
                     selectedSideBarItem: $selectedSideBarItem,
                     selectedProject: $selectedProject,
                     activeTasksCount: $activeTasksCount,
                     focusMode: $focusMode,
                     timer: timer,
                     focusTask: focusTask,
                     refresher: refresher)
        .sheet(isPresented: $newTaskIsShowing, content: {
            NewTaskView(isVisible: self.$newTaskIsShowing, list: .inbox, project: nil, mainTask: nil)
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
                .environment(refresher)
        })
        .onChange(of: tab) { oldValue, newValue in
            handleTabSelectionChange(oldValue: oldValue, newValue: newValue)
        }
        .onAppear {
            refreshTimerDurationsAndLiveActivity()
            checkForReview()
            synchronizeLiveActivity()
        }
        .onChange(of: timerWorkSession, { _, _ in
            refreshTimerDurationsAndLiveActivity()
        })
        .onChange(of: timerBreakSession, { _, _ in
            refreshTimerDurationsAndLiveActivity()
        })
        .onChange(of: timerLongBreakSession, { _, _ in
            refreshTimerDurationsAndLiveActivity()
        })
        .onChange(of: timerWorkSessionsCount, { _, _ in
            refreshTimerDurationsAndLiveActivity()
        })
        .onChange(of: timer.state, { _, _ in
            synchronizeLiveActivity()
        })
        .onChange(of: timer.mode, { _, _ in
            handleTimerModeChange()
        })
        .onChange(of: timer.sessionsCounter, { _, newValue in
            incrementFocusTaskTomatoesIfNeeded(newValue: newValue)
        })
        .onOpenURL { url in
            handleOpenURL(url)
        }
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhaseChange(newPhase: newPhase)
        }
    }
    
    @MainActor
    private func handleTabSelectionChange(oldValue: MainViewTabs, newValue: MainViewTabs) {
        guard newValue == .inbox else { return }
        
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(10))
            withAnimation {
                tab = oldValue
                newTaskIsShowing.toggle()
            }
        }
    }
    
    @MainActor
    private func refreshTimerDurationsAndLiveActivity() {
        timer.setDurations(workInSeconds: timerWorkSession,
                           breakInSeconds: timerBreakSession,
                           longBreakInSeconds: timerLongBreakSession,
                           workSessionsCount: Int(timerWorkSessionsCount))
        synchronizeLiveActivity()
    }
    
    @MainActor
    private func handleTimerModeChange() {
        focusMode = timer.mode
        synchronizeLiveActivity()
    }
    
    @MainActor
    private func incrementFocusTaskTomatoesIfNeeded(newValue: Int) {
        guard newValue > 0, let task = focusTask.task else { return }
        task.tomatoesCount += 1
    }
    
    @MainActor
    private func handleOpenURL(_ url: URL) {
        if url.scheme == "pompaddo" && url.host == "addtoinbox" {
            newTaskIsShowing.toggle()
            return
        }
        
        guard url.scheme == "pompaddo", url.host == "new" else { return }
        
        print(url.absoluteString)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let title = components?.queryItems?.first(where: { $0.name == "title" })?.value else { return }
        
        let task = Todo(name: title)
        if let link = components?.queryItems?.first(where: { $0.name == "link" })?.value,
           let linkurl = URL(string: link) {
            task.link = linkurl.absoluteString
        }
        
        modelContext.insert(task)
    }
    
    @MainActor
    private func handleScenePhaseChange(newPhase: ScenePhase) {
        if newPhase == .background, timer.state == .running {
            timer.setNotification()
        }
        synchronizeLiveActivity()
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
    
    private func synchronizeLiveActivity() {
        #if canImport(ActivityKit)
        liveActivityManager.synchronize(with: timer)
        #endif
    }
}

#Preview {
    let previewer = try? Previewer()
    
    MainView()
        .modelContainer(previewer!.container)
}
