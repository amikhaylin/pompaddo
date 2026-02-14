//
//  PomPadDo_mobileApp.swift
//  PomPadDo.mobile
//
//  Created by Andrey Mikhaylin on 16.02.2025.
//

import SwiftUI
import SwiftData
import SwiftDataTransferrable

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

    var body: some Scene {
        SwiftDataTransferrableScene(modelContainer: sharedModelContainer, exportedUTType: "com.amikhaylin.persistentModelID") {
            WindowGroup {
                MainView()
            }
//            .modelContainer(sharedModelContainer)
            .commands {
                InspectorCommands()
            }
        }
    }
    
    init() {
        if ProcessInfo.processInfo.environment["UITEST_DISABLE_ANIMATIONS"] == "YES" {
            UIView.setAnimationsEnabled(false)
        }
    }
}
