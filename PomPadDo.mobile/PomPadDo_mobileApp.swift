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
            MainView()
                .swiftDataTransferrable(exportedUTType: "com.amikhaylin.persistentModelID",
                                        modelContext: sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
        .commands {
            InspectorCommands()
        }
    }
}
