//
//  ContentView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 13.02.2024.
//

import SwiftUI
import SwiftData

import SwiftDataTransferrable

enum SideBarItem: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    case inbox
    case today
    case tomorrow
    case review
    case projects
    
    var name: String {
        switch self {
        case .inbox:
            return NSLocalizedString("Inbox", comment: "")
        case .today:
            return NSLocalizedString("Today", comment: "")
        case .tomorrow:
            return NSLocalizedString("Tomorrow", comment: "")
        case .review:
            return NSLocalizedString("Review", comment: "")
        case .projects:
            return NSLocalizedString("Projects", comment: "")
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @Environment(\.scenePhase) var scenePhase
  
    @ObservedObject private var showInspector = InspectorToggler()
    @ObservedObject private var selectedTasks = SelectedTasks()
    
    @State private var newTaskIsShowing = false
    @State var selectedSideBarItem: SideBarItem? = .today
    
    @State private var selectedProject: Project?
    
    @Query var tasks: [Todo]
    @Query var projects: [Project]
    
    var body: some View {
        NavigationSplitView {
            VStack {
                SectionsListView(tasks: tasks,
                                 projects: projects,
                                 selectedSideBarItem: $selectedSideBarItem)
                    .frame(height: 125)
                
                ProjectsListView(selectedProject: $selectedProject,
                                 projects: projects,
                                 selectedSideBarItem: $selectedSideBarItem)
                    .id(refresher.refresh)
            }
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        refresher.refresh.toggle()
                    } label: {
                        Label("Refresh", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .keyboardShortcut("r", modifiers: [.command])
                    .help("Refresh ⌘R")
                    
                    Button {
                        newTaskIsShowing.toggle()
                    } label: {
                        Label("Add task to Inbox", systemImage: "tray.and.arrow.down.fill")
                            .foregroundStyle(Color.orange)
                    }
                    .keyboardShortcut("i", modifiers: [.command])
                    .help("Add to Inbox ⌘I")
                }
            }
            .sheet(isPresented: $newTaskIsShowing) {
                NewTaskView(isVisible: self.$newTaskIsShowing, list: .inbox, project: nil, mainTask: nil, tasks: .constant([]))
            }
            .navigationSplitViewColumnWidth(min: 230, ideal: 230, max: 400)
        } detail: {
            HStack {
                switch selectedSideBarItem {
                case .inbox:
                    try? TasksListView(tasks: tasks.filter(TasksQuery.predicateInbox()).sorted(by: TasksQuery.defaultSorting),
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                    .id(refresher.refresh)
                    .environmentObject(showInspector)
                    .environmentObject(selectedTasks)
                case .today:
                    try? TasksListView(tasks: tasks.filter(TasksQuery.predicateToday())
                        .filter({ TasksQuery.checkToday(date: $0.completionDate) })
                        .sorted(by: TasksQuery.defaultSorting),
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                    .id(refresher.refresh)
                    .environmentObject(showInspector)
                    .environmentObject(selectedTasks)
                case .tomorrow:
                    try? TasksListView(tasks: tasks.filter(TasksQuery.predicateTomorrow())
                        .filter({ $0.completionDate == nil })
                        .sorted(by: TasksQuery.defaultSorting),
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                    .id(refresher.refresh)
                    .environmentObject(showInspector)
                    .environmentObject(selectedTasks)
                case .projects:
                    if let project = selectedProject {
                        ProjectView(project: project)
                            .id(refresher.refresh)
                            .environmentObject(showInspector)
                            .environmentObject(selectedTasks)
                    } else {
                        Text("Select a project")
                    }
                case .review:
                    ReviewProjectsView(projects: projects.filter({ TasksQuery.filterProjectToReview($0) }))
                        .environmentObject(showInspector)
                        .environmentObject(selectedTasks)
                default:
                    EmptyView()
                }
            }
        }
        .onChange(of: selectedSideBarItem, { _, newValue in
            if showInspector.on {
                showInspector.on = false
            }
            
            if selectedTasks.tasks.count > 0 {
                selectedTasks.tasks.removeAll()
            }

            if newValue != .projects {
                selectedProject = nil
            }
        })
        .onChange(of: selectedProject) { _, newValue in
            if newValue != nil && selectedSideBarItem != .projects {
                selectedSideBarItem = .projects
            }
        }
        .onOpenURL { url in
            print(url.absoluteString)
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let title = components?.queryItems?.first(where: { $0.name == "title" })?.value {
                var task = Todo(name: title)
                if let link = components?.queryItems?.first(where: { $0.name == "link" })?.value, let linkurl = URL(string: link) {
                    task.link = linkurl.absoluteString
                }
                modelContext.insert(task)
            }
            selectedSideBarItem = .inbox
        }
        .task {
            for task in tasks {
                if let reminder = task.alertDate, reminder > Date() {
                    let hasAlert = await NotificationManager.checkTaskHasRequest(task: task)
                    if !hasAlert {
                        NotificationManager.setTaskNotification(task: task)
                    }
                }
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
