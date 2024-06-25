//
//  ContentView.swift
//  PomPadDo-Watch Watch App
//
//  Created by Andrey Mikhaylin on 24.06.2024.
//

import SwiftUI
import SwiftData

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
    
    var body: some View {
        NavigationSplitView {
            SectionsListView(tasks: tasks,
                             selectedSideBarItem: $selectedSideBarItem)
        } detail: {
            Group {
                switch selectedSideBarItem {
                case .inbox:
                    try? TasksListView(tasks: tasks.filter(TasksQuery.predicateInboxActive()).sorted(by: TasksQuery.defaultSorting),
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                case .today:
                    try? TasksListView(tasks: tasks.filter(TasksQuery.predicateTodayActive()).sorted(by: TasksQuery.defaultSorting),
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                case .tomorrow:
                    try? TasksListView(tasks: tasks.filter(TasksQuery.predicateTomorrow()).sorted(by: TasksQuery.defaultSorting),
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                case nil:
                    EmptyView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        NewTaskView()
                    } label: {
                        Image(systemName: "tray.and.arrow.down.fill")
                            .foregroundStyle(Color.orange)
                    }
                }
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
