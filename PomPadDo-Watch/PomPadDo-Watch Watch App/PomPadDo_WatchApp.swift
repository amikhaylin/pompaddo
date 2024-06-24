//
//  PomPadDo_WatchApp.swift
//  PomPadDo-Watch Watch App
//
//  Created by Andrey Mikhaylin on 24.06.2024.
//

import SwiftUI
import SwiftData

@main
struct PomPadDo_Watch_App: App {
    var sharedModelContainer: ModelContainer = {
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
        }
        .modelContainer(sharedModelContainer)
    }
}
