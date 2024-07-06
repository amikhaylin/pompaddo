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
    @Query var tasks: [Todo]
    
    @State var selectedSideBarItem: SideBarItem? = .today
    @State private var refresher = Refresher()
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    
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
                    .environmentObject(refresher)
                case .today:
                    try? TasksListView(tasks: tasks.filter(TasksQuery.predicateToday())
                                                   .filter({ TasksQuery.checkToday(date: $0.completionDate) })
                                                   .sorted(by: TasksQuery.defaultSorting)
                                                   .sorted(by: TasksQuery.sortCompleted),
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                    .id(refresher.refresh)
                    .environmentObject(refresher)
                case .tomorrow:
                    try? TasksListView(tasks: tasks.filter(TasksQuery.predicateTomorrow()).sorted(by: TasksQuery.defaultSorting),
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                    .id(refresher.refresh)
                    .environmentObject(refresher)
                case nil:
                    EmptyView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        NewTaskView()
                            .environmentObject(refresher)
                    } label: {
                        Image(systemName: "tray.and.arrow.down.fill")
                            .foregroundStyle(Color.orange)
                    }
                }
            }
        }
        .onChange(of: tasksTodayActive.count) { _, _ in
            WidgetCenter.shared.reloadAllTimelines()
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
