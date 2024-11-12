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
    
    case inbox
    case today
    case tomorrow
    
    var name: String {
        switch self {
        case .inbox:
            return NSLocalizedString("Inbox", comment: "")
        case .today:
            return NSLocalizedString("Today", comment: "")
        case .tomorrow:
            return NSLocalizedString("Tomorrow", comment: "")
        }
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var refresher: Refresher
    
    @Query var tasks: [Todo]
    
    @State var selectedSideBarItem: SideBarItem? = .today
    @State private var addToInbox = false
    
    var body: some View {
        NavigationSplitView {
            SectionsListView(tasks: tasks,
                             selectedSideBarItem: $selectedSideBarItem)
        } detail: {
            Group {
                switch selectedSideBarItem {
                case .inbox:
                    try? TasksListView(tasks: tasks.filter(TasksQuery.predicateInbox())
                                                   .sorted(by: TasksQuery.defaultSorting)
                                                   .sorted(by: TasksQuery.sortCompleted),
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                    .id(refresher.refresh)
                case .today:
                    try? TasksListView(tasks: tasks.filter(TasksQuery.predicateToday())
                        .filter({ TasksQuery.checkToday(date: $0.completionDate) && ($0.completed == false || ($0.completed && $0.parentTask == nil)) })
                        .sorted(by: TasksQuery.sortingWithCompleted),
//                                                   .sorted(by: TasksQuery.defaultSorting)
//                                                   .sorted(by: TasksQuery.sortCompleted),
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                    .id(refresher.refresh)
                case .tomorrow:
                    try? TasksListView(tasks: tasks.filter(TasksQuery.predicateTomorrow()).sorted(by: TasksQuery.defaultSorting),
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                    .id(refresher.refresh)
                case nil:
                    EmptyView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        refresher.refresh.toggle()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
                
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
                .environmentObject(refresher)
        }
        .onOpenURL { url in
            if url.absoluteString == "pompaddo://addtoinbox" {
                addToInbox.toggle()
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active && oldPhase == .background {
                refresher.refresh.toggle()
            }
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        
        return ContentView()
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
