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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(refresher)
        }
        .modelContainer(sharedModelContainer)
    }
}
