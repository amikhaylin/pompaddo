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
    case alltasks
    
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
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var refresher: Refresher
    
    @State var selectedSideBarItem: SideBarItem? = .today
    @State private var addToInbox = false
    
    var body: some View {
        NavigationSplitView {
            SectionsListView(selectedSideBarItem: $selectedSideBarItem)
        } detail: {
            Group {
                switch selectedSideBarItem {
                case .inbox:
                    TasksListView(predicate: TasksQuery.predicateInbox(),
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                    .id(refresher.refresh)
                case .today:
                    TasksListView(predicate: TasksQuery.predicateToday(),
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                    .id(refresher.refresh)
                case .tomorrow:
                    TasksListView(predicate: TasksQuery.predicateTomorrow(),
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                    .id(refresher.refresh)
                case .alltasks:
                    TasksListView(predicate: TasksQuery.predicateAll(),
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
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active && (oldPhase == .background || oldPhase == .inactive) {
                refresher.refresh.toggle()
            }
        }
    }
}

#Preview {
    @Previewable @State var refresher = Refresher()
    @Previewable @State var container = try? ModelContainer(for: Schema([
                                                            ProjectGroup.self,
                                                            Status.self,
                                                            Todo.self,
                                                            Project.self
                                                        ]),
                                                       configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let previewer = Previewer(container!)
    
    ContentView()
        .environmentObject(refresher)
        .modelContainer(container!)
}
