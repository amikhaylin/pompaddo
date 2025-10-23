//
//  PomPadDoMacApp.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 13.02.2024.
//
// swiftlint:disable type_body_length

import SwiftUI
import SwiftData

@main
struct PomPadDoMacApp: App {
    @State private var refresher = Refresher()
    @State var selectedSideBarItem: SideBarItem? = .today
    @State var selectedProject: Project?
    @State var newTaskIsShowing = false
    @StateObject var selectedTasks = SelectedTasks()
    
    @StateObject var timer = FocusTimer(workInSeconds: 1500,
                           breakInSeconds: 300,
                           longBreakInSeconds: 1200,
                           workSessionsCount: 4)
    
    @StateObject var focusTask = FocusTask()
    
    @State var sharedModelContainer: ModelContainer = {
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
        
        let modelConfiguration: ModelConfiguration!
        if ProcessInfo.processInfo.environment["IS_TESTING"] == "YES" {
            modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        } else {
            modelConfiguration = ModelConfiguration(schema: schema, url: fileURL)
            print("\(fileURL.absoluteString)")
        }
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
            ContentView(selectedSideBarItem: $selectedSideBarItem,
                        newTaskIsShowing: $newTaskIsShowing,
                        selectedProject: $selectedProject)
                .id(refresher.refresh)
                .swiftDataTransferrable(exportedUTType: "com.amikhaylin.persistentModelID",
                                        modelContext: sharedModelContainer.mainContext)
                .environmentObject(refresher)
                .environmentObject(selectedTasks)
                .environmentObject(timer)
                .environmentObject(focusTask)
        }
        .modelContainer(sharedModelContainer)
        .commands {
            InspectorCommands()
            
            CommandMenu("List") {
                Button {
                    selectedSideBarItem = .inbox
                } label: {
                    Image(systemName: "tray")
                    Text("Inbox")
                }
                .keyboardShortcut("1", modifiers: [.control, .option])
                
                Button {
                    selectedSideBarItem = .today
                } label: {
                    Image(systemName: "calendar")
                    Text("Today")
                }
                .keyboardShortcut("t", modifiers: [.option, .command])
                
                Button {
                    selectedSideBarItem = .tomorrow
                } label: {
                    Image(systemName: "sunrise")
                    Text("Tomorrow")
                }
                .keyboardShortcut("t", modifiers: [.control, .command])
                
                Button {
                    selectedSideBarItem = .review
                } label: {
                    Image(systemName: "cup.and.saucer")
                    Text("Review")
                }
                .keyboardShortcut("r", modifiers: [.option, .command])
                
                Button {
                    selectedSideBarItem = .alltasks
                } label: {
                    Image(systemName: "rectangle.stack")
                    Text("All")
                }
                .keyboardShortcut("a", modifiers: [.option, .command])
                
                Divider()
                
                Button {
                    refresher.refresh.toggle()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Refresh")
                }
                .keyboardShortcut("r", modifiers: [.command])
            }
            
            CommandMenu("Task") {
                Button {
                    newTaskIsShowing.toggle()
                } label: {
                    Image(systemName: "tray.and.arrow.down.fill")
                    Text("Add task to Inbox")
                }
                .keyboardShortcut("i", modifiers: [.command])
                
                Divider()
                
                Button {
                    for task in selectedTasks.tasks {
                        task.complete(modelContext: sharedModelContainer.mainContext)
                    }
                    refresher.refresh.toggle()
                } label: {
                    Image(systemName: "checkmark.square")
                    Text("Complete")
                }
                .keyboardShortcut("m", modifiers: [.shift, .command])
                .disabled(selectedTasks.tasks.count == 0)
                
                Divider()
                
                Button {
                    for task in selectedTasks.tasks {
                        task.setDueDate(dueDate: nil)
                    }
                    refresher.refresh.toggle()
                } label: {
                    Image(systemName: "clear")
                    Text("Clear due date")
                }
                .keyboardShortcut("0", modifiers: [.command])
                .disabled(selectedTasks.tasks.count == 0)
                
                Button {
                    for task in selectedTasks.tasks {
                        task.setDueDate(dueDate: Calendar.current.startOfDay(for: Date()))
                    }
                    refresher.refresh.toggle()
                } label: {
                    Image(systemName: "calendar")
                    Text("Today")
                }
                .keyboardShortcut("1", modifiers: [.command])
                .disabled(selectedTasks.tasks.count == 0)
                
                Button {
                    for task in selectedTasks.tasks {
                        task.setDueDate(dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())))
                    }
                    refresher.refresh.toggle()
                } label: {
                    Image(systemName: "sunrise")
                    Text("Tomorrow")
                }
                .keyboardShortcut("2", modifiers: [.command])
                .disabled(selectedTasks.tasks.count == 0)
                
                Button {
                    for task in selectedTasks.tasks {
                        task.nextWeek()
                    }
                    refresher.refresh.toggle()
                } label: {
                    Image(systemName: "calendar.badge.clock")
                    Text("Next week")
                }
                .keyboardShortcut("3", modifiers: [.command])
                .disabled(selectedTasks.tasks.count == 0)
                
                Divider()
                
                Button {
                    if let task = selectedTasks.tasks.first {
                        focusTask.task = task
                        if timer.state == .idle {
                            timer.reset()
                            timer.start()
                        } else if timer.state == .paused {
                            timer.resume()
                        }
                    }
                } label: {
                    Image(systemName: "play.fill")
                    Text("Start focus")
                }
                .keyboardShortcut("f", modifiers: [.command, .option])
                .disabled(selectedTasks.tasks.count == 0)
                
                Divider()
                
                Menu {
                    Button {
                        for task in selectedTasks.tasks {
                            CalendarManager.addToCalendar(title: task.name, eventStartDate: Date.now, eventEndDate: Date.now, isAllDay: true)
                        }
                    } label: {
                        Image(systemName: "calendar.badge.plus")
                        Text("for Today")
                    }
                    .keyboardShortcut("c", modifiers: [.command, .option, .shift])
                    .disabled(selectedTasks.tasks.count == 0)
                    
                    Button {
                        for task in selectedTasks.tasks {
                            if let dueDate = task.dueDate {
                                CalendarManager.addToCalendar(title: task.name, eventStartDate: dueDate, eventEndDate: dueDate, isAllDay: true)
                            } else {
                                CalendarManager.addToCalendar(title: task.name, eventStartDate: Date.now, eventEndDate: Date.now, isAllDay: true)
                            }
                        }
                    } label: {
                        Image(systemName: "calendar.badge.plus")
                        Text("for Due Date")
                    }
                    .keyboardShortcut("c", modifiers: [.command, .option])
                    .disabled(selectedTasks.tasks.count == 0)
                } label: {
                    Image(systemName: "calendar.badge.plus")
                    Text("Add to Calendar")
                }
                
                Divider()
                
                Menu {
                    ForEach(0...3, id: \.self) { priority in
                        Button {
                            for task in selectedTasks.tasks {
                                task.priority = priority
                            }
                            refresher.refresh.toggle()
                        } label: {
                            HStack {
                                switch priority {
                                case 3:
                                    Text("High")
                                case 2:
                                    Text("Medium")
                                case 1:
                                    Text("Low")
                                default:
                                    Text("None")
                                }
                            }
                        }
                        .tag(priority as Int)
                        .disabled(selectedTasks.tasks.count == 0)
                    }
                } label: {
                    Text("Priority")
                }
                
                Divider()
                
                Button {
                    for task in selectedTasks.tasks {
                        let newTask = task.copy(modelContext: sharedModelContainer.mainContext)
                        
                        sharedModelContainer.mainContext.insert(newTask)
                        newTask.reconnect()
                    }
                    
                    refresher.refresh.toggle()
                } label: {
                    Image(systemName: "doc.on.doc")
                    Text("Duplicate task")
                }
                .keyboardShortcut("c", modifiers: [.command, .option])
                .disabled(selectedTasks.tasks.count == 0)
                
                Button {
                    for task in selectedTasks.tasks {
                        if let focus = focusTask.task, task == focus {
                            focusTask.task = nil
                        }

                        TasksQuery.deleteTask(context: sharedModelContainer.mainContext,
                                              task: task)
                    }
                    refresher.refresh.toggle()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(Color.red)
                    Text("Delete task")
                }
                .disabled(selectedTasks.tasks.count == 0)
            }
            
            CommandMenu("Timer") {
                // start
                if timer.state == .idle {
                    Button {
                        timer.start()
                    } label: {
                        Image(systemName: "play.fill")
                        Text("Start")
                    }
                    .keyboardShortcut("s", modifiers: [.command])
                }
                // resume
                if timer.state == .paused {
                    Button {
                        timer.resume()
                    } label: {
                        Image(systemName: "play.fill")
                        Text("Resume")
                    }
                    .keyboardShortcut("p", modifiers: [.command])
                }
                // pause
                if timer.state == .running {
                    Button {
                        timer.pause()
                    } label: {
                        Image(systemName: "pause.fill")
                        Text("Pause")
                    }
                    .keyboardShortcut("p", modifiers: [.command])
                }
                // reset / stop
                if timer.state == .running || timer.state == .paused {
                    if timer.mode == .pause || timer.mode == .longbreak {
                        Button {
                            timer.reset()
                            timer.skip()
                            timer.start()
                        } label: {
                            Image(systemName: "forward.fill")
                            Text("Skip")
                        }
                        .keyboardShortcut("s", modifiers: [.command, .shift])
                    } else {
                        Button {
                            timer.reset()
                        } label: {
                            Image(systemName: "stop.fill")
                            Text("Stop")
                        }
                        .keyboardShortcut("s", modifiers: [.command])
                    }
                }
                
                if focusTask.task != nil {
                    Button {
                        focusTask.task = nil
                    } label: {
                        Image(systemName: "clear")
                        Text("Clear task")
                    }
                }
            }
        }
        
        FocusTimerScene()
            .modelContainer(sharedModelContainer)
            .environmentObject(refresher)
            .environmentObject(timer)
            .environmentObject(focusTask)
        
        Settings {
            SettingsView()
        }
    }
}
// swiftlint:enable type_body_length
