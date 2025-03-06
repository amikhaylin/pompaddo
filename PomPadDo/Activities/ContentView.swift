//
//  ContentView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 13.02.2024.
//

import SwiftUI
import SwiftData

import SwiftDataTransferrable

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @Environment(\.scenePhase) var scenePhase
  
    @StateObject private var showInspector = InspectorToggler()
    @StateObject private var selectedTasks = SelectedTasks()
    
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
                    .frame(height: 170)
                    .contentMargins(.vertical, 0)
                
                ProjectsListView(selectedProject: $selectedProject,
                                 projects: projects,
                                 selectedSideBarItem: $selectedSideBarItem)
                    .id(refresher.refresh)
                    .contentMargins(.vertical, 0)
                    .padding(.leading, 12)
            }
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        refresher.refresh.toggle()
                        if checkSyncIssues() {
                            fixSyncIssues()
                        }
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
                case .alltasks:
                    try? TasksListView(tasks: tasks.filter(TasksQuery.predicateAll()).sorted(by: TasksQuery.defaultSorting),
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                    .id(refresher.refresh)
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
            if newPhase == .active && (oldPhase == .inactive || oldPhase == .background) { 
                refresher.refresh.toggle()
                if checkSyncIssues() {
                    fixSyncIssues()
                }
            }
        }
    }
    
    private func fixSyncIssues() {
        for project in projects {
            for task in project.tasks ?? [] where task.status == nil {
                if task.completed {
                    if let status = project.getStatuses().first(where: { $0.doCompletion }) {
                        task.status = status
                    } else {
                        task.status = project.getDefaultStatus()
                    }
                } else {
                    task.status = project.getDefaultStatus()
                }
            }
        }
    }
    
    private func checkSyncIssues() -> Bool {
        for project in projects {
            for task in project.tasks ?? [] where task.status == nil {
                return true
            }
        }
        
        return false
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
