//
//  ContentView.swift
//  PomPadDoWatch Watch App
//
//  Created by Andrey Mikhaylin on 25.06.2024.
//

import SwiftUI
import SwiftData
import WidgetKit

enum SideBarItem: String, Identifiable, CaseIterable {
    var id: String { rawValue }

    case focus
    case inbox
    case today
    case tomorrow
    case alltasks
    case settings
    
    var name: String {
        switch self {
        case .inbox:
            return NSLocalizedString("Inbox", comment: "")
        case .today:
            return NSLocalizedString("Today", comment: "")
        case .tomorrow:
            return NSLocalizedString("Tomorrow", comment: "")
        case .alltasks:
            return NSLocalizedString("All", comment: "")
        case .focus:
            return NSLocalizedString("Focus", comment: "")
        case .settings:
            return NSLocalizedString("Settings", comment: "")
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var refresher: Refresher
    @EnvironmentObject var timer: FocusTimer
    @EnvironmentObject var focusTask: FocusTask
    
    @AppStorage("timerWorkSession") private var timerWorkSession: Double = 1500.0
    @AppStorage("timerBreakSession") private var timerBreakSession: Double = 300.0
    @AppStorage("timerLongBreakSession") private var timerLongBreakSession: Double = 1200.0
    @AppStorage("timerWorkSessionsCount") private var timerWorkSessionsCount: Double = 4.0
    
    @Binding var selectedSideBarItem: SideBarItem?
    @State private var addToInbox = false
    
    var body: some View {
        NavigationSplitView {
            SectionsListView(selectedSideBarItem: $selectedSideBarItem)
        } detail: {
            Group {
                switch selectedSideBarItem {
                case .inbox:
                    TasksListView(predicate: TasksQuery.predicateInbox(),
                                  list: $selectedSideBarItem,
                                  title: selectedSideBarItem!.name)
                case .today:
                    TasksListView(predicate: TasksQuery.predicateToday(),
                                  list: $selectedSideBarItem,
                                  title: selectedSideBarItem!.name)
                case .tomorrow:
                    TasksListView(predicate: TasksQuery.predicateTomorrow(),
                                  list: $selectedSideBarItem,
                                  title: selectedSideBarItem!.name)
                case .alltasks:
                    TasksListView(predicate: TasksQuery.predicateAll(),
                                       list: $selectedSideBarItem,
                                       title: selectedSideBarItem!.name)
                case .focus:
                    FocusTimerView(list: $selectedSideBarItem)
                        .environmentObject(timer)
                        .environmentObject(focusTask)
                case .settings:
                    SettingsView()
                case nil:
                    EmptyView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addToInbox.toggle()
                    } label: {
                        Image(systemName: "tray.and.arrow.down.fill")
                            .foregroundStyle(Color.orange)
                    }
                }
            }
        }
        .onChange(of: refresher.refresh) { _, _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
        .sheet(isPresented: $addToInbox) {
            NewTaskView()
        }
        .onOpenURL { url in
            if url.scheme == "pompaddo" && url.host == "addtoinbox" {
                addToInbox.toggle()
            } else if url.scheme == "pompaddo" && url.host == "new" {
                print(url.absoluteString)
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                if let title = components?.queryItems?.first(where: { $0.name == "title" })?.value {
                    let task = Todo(name: title)
                    if let link = components?.queryItems?.first(where: { $0.name == "link" })?.value, let linkurl = URL(string: link) {
                        task.link = linkurl.absoluteString
                    }
                    modelContext.insert(task)
                }
            } else {
                return
            }
        }
        .onAppear {
            timer.setDurations(workInSeconds: timerWorkSession,
                               breakInSeconds: timerBreakSession,
                               longBreakInSeconds: timerLongBreakSession,
                               workSessionsCount: Int(timerWorkSessionsCount))
        }
        .onChange(of: timerWorkSession, { _, _ in
            timer.setDurations(workInSeconds: timerWorkSession,
                               breakInSeconds: timerBreakSession,
                               longBreakInSeconds: timerLongBreakSession,
                               workSessionsCount: Int(timerWorkSessionsCount))
        })
        .onChange(of: timerBreakSession, { _, _ in
            timer.setDurations(workInSeconds: timerWorkSession,
                               breakInSeconds: timerBreakSession,
                               longBreakInSeconds: timerLongBreakSession,
                               workSessionsCount: Int(timerWorkSessionsCount))
        })
        .onChange(of: timerLongBreakSession, { _, _ in
            timer.setDurations(workInSeconds: timerWorkSession,
                               breakInSeconds: timerBreakSession,
                               longBreakInSeconds: timerLongBreakSession,
                               workSessionsCount: Int(timerWorkSessionsCount))
        })
        .onChange(of: timerWorkSessionsCount, { _, _ in
            timer.setDurations(workInSeconds: timerWorkSession,
                               breakInSeconds: timerBreakSession,
                               longBreakInSeconds: timerLongBreakSession,
                               workSessionsCount: Int(timerWorkSessionsCount))
        })
        .onChange(of: timer.sessionsCounter, { _, newValue in
            if let task = focusTask.task, newValue > 0 {
                task.tomatoesCount += 1
            }
        })
    }
}

#Preview {
    @Previewable @State var refresher = Refresher()
    @Previewable @State var selectedSidebarItem: SideBarItem? = .today
    @Previewable @State var container = try? ModelContainer(for: Schema([
                                                            ProjectGroup.self,
                                                            Status.self,
                                                            Todo.self,
                                                            Project.self
                                                        ]),
                                                       configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let previewer = Previewer(container!)
    
    ContentView(selectedSideBarItem: $selectedSidebarItem)
        .environmentObject(refresher)
        .modelContainer(container!)
}
