//
//  PomPadDo_watchApp.swift
//  PomPadDo.watch Watch App
//
//  Created by Andrey Mikhaylin on 17.02.2025.
//

import SwiftUI
import SwiftData

@main
struct PomPadDoWatchApp: App {
    @State private var refresher = Refresher()
    @State var selectedSideBarItem: SideBarItem? = .today
    
    @State var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Todo.self,
            Project.self,
            Status.self,
            ProjectGroup.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject var timer = FocusTimer(workInSeconds: 1500,
                           breakInSeconds: 300,
                           longBreakInSeconds: 1200,
                           workSessionsCount: 4)
    
    @StateObject var focusTask = FocusTask()
    
    var body: some Scene {
        WindowGroup {
            ContentView(selectedSideBarItem: $selectedSideBarItem)
                .id(refresher.refresh)
                .environmentObject(refresher)
                .environmentObject(timer)
                .environmentObject(focusTask)
        }
        .modelContainer(sharedModelContainer)
    }
}
