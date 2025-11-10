//
//  PomPadDo_mobileApp.swift
//  PomPadDo.mobile
//
//  Created by Andrey Mikhaylin on 16.02.2025.
//

import SwiftUI
import SwiftData

@main
struct PomPadDoiOSApp: App {
    @State var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Todo.self,
            Project.self,
            Status.self,
            ProjectGroup.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema,
                                                    isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject private var reviewManager = ReviewManager()

    var body: some Scene {
        WindowGroup {
            MainView()
                .swiftDataTransferrable(exportedUTType: "com.amikhaylin.persistentModelID",
                                        modelContext: sharedModelContainer.mainContext)
                .environmentObject(reviewManager)
                .onAppear {
                    reviewManager.appLaunched()
                }
        }
        .modelContainer(sharedModelContainer)
        .commands {
            InspectorCommands()
        }
    }
    
    init() {
        if ProcessInfo.processInfo.environment["UITEST_DISABLE_ANIMATIONS"] == "YES" {
            UIView.setAnimationsEnabled(false)
        }
    }
}
