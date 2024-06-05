//
//  PomPadDoMacApp.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 13.02.2024.
//

import SwiftUI
import SwiftData

@main
struct PomPadDoMacApp: App {
    @State private var timerCount: String = "25:00"
    @State private var focusMode: FocusTimerMode = .work
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ProjectGroup.self,
            Status.self,
            Todo.self,
            Project.self
        ])
        
        #if DEBUG
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directoryURL = appSupportURL.appendingPathComponent("PomPadDoData")
                
        // Set the path to the name of the store you want to set up
        let fileURL = directoryURL.appendingPathComponent("DebugData.store")
        
        do {
            // This next line will create a new directory called Example in Application Support if one doesn't already exist, and will do nothing if one already exists, so we have a valid place to put our store
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError("Could not find/create Example folder in Application Support")
        }
        print("\(fileURL.absoluteString)")
        let modelConfiguration = ModelConfiguration(schema: schema, url: fileURL)
        #else
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        #endif

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            // TODO: Store refresh period in settings
            TimelineView(.periodic(from: .now, by: 5.0)) { _ in
                ContentView()
                    .swiftDataTransferrable(exportedUTType: "com.amikhaylin.persistentModelID",
                                            modelContext: sharedModelContainer.mainContext)
            }
        }
        .modelContainer(sharedModelContainer)
        
        MenuBarExtra {
            FocusTimerView(context: sharedModelContainer.mainContext,
                           timerCount: $timerCount,
                           focusMode: $focusMode)
            .modelContainer(sharedModelContainer)
        } label: {
            HStack {
                if focusMode == .work {
                    let configuration = NSImage.SymbolConfiguration(pointSize: 16, weight: .light)
                        .applying(.init(hierarchicalColor: .red))
                    
                    let image = NSImage(systemSymbolName: "target", accessibilityDescription: nil)
                    let updateImage = image?.withSymbolConfiguration(configuration)
                    
                    Image(nsImage: updateImage!)
                } else {
                    let configuration = NSImage.SymbolConfiguration(pointSize: 16, weight: .light)
                                    .applying(.init(hierarchicalColor: .green))
                                    
                    let image = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: nil)
                    let updateImage = image?.withSymbolConfiguration(configuration)

                    Image(nsImage: updateImage!) // This works.
                }

                Text(timerCount)
            }
        }
        .menuBarExtraStyle(.window)
    }
}
