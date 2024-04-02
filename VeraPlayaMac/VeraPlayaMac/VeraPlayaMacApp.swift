//
//  VeraPlayaMacApp.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 13.02.2024.
//

import SwiftUI
import SwiftData

@main
struct VeraPlayaMacApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Todo.self,
            Project.self
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
                .swiftDataTransferrable(exportedUTType: "com.amikhaylin.persistentModelID",
                                        modelContext: sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
    }
}
