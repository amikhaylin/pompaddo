//
//  ContentView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 13.05.2024.
//

import SwiftUI
import SwiftData

import SwiftDataTransferrable

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @StateObject private var showInspector = InspectorToggler()
    @StateObject private var selectedTasks = SelectedTasks()
    @State var selectedSideBarItem: SideBarItem? = .today
    
    @State private var selectedProject: Project?
    
    @Query var tasks: [Todo]
    @Query var projects: [Project]
    
    var body: some View {
        NavigationSplitView {
            SectionsListView(tasks: tasks,
                             projects: projects,
                             selectedSideBarItem: $selectedSideBarItem,
                             selectedProject: $selectedProject)
                .id(refresher.refresh)
            .navigationSplitViewColumnWidth(min: 300, ideal: 300)
        } detail: {
            switch selectedSideBarItem {
            case .inbox:
                try? TasksListView(tasks: tasks.filter(TasksQuery.predicateInbox()).sorted(by: TasksQuery.defaultSorting),
                              list: selectedSideBarItem!,
                              title: selectedSideBarItem!.name)
                .id(refresher.refresh)
                .refreshable {
                    refresher.refresh.toggle()
                }
                .environmentObject(showInspector)
                .environmentObject(selectedTasks)
            case .today:
                try? TasksListView(tasks: tasks.filter(TasksQuery.predicateToday())
                    .filter({ TasksQuery.checkToday(date: $0.completionDate) })
                    .sorted(by: TasksQuery.defaultSorting),
                              list: selectedSideBarItem!,
                              title: selectedSideBarItem!.name)
                .id(refresher.refresh)
                .refreshable {
                    refresher.refresh.toggle()
                }
                .environmentObject(showInspector)
                .environmentObject(selectedTasks)
            case .tomorrow:
                try? TasksListView(tasks: tasks.filter(TasksQuery.predicateTomorrow())
                    .filter({ $0.completionDate == nil })
                    .sorted(by: TasksQuery.defaultSorting),
                              list: selectedSideBarItem!,
                              title: selectedSideBarItem!.name)
                .id(refresher.refresh)
                .refreshable {
                    refresher.refresh.toggle()
                }
                .environmentObject(showInspector)
                .environmentObject(selectedTasks)
            case .review:
                ReviewProjectsView(projects: projects.filter({ TasksQuery.filterProjectToReview($0) }))
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
        .onChange(of: selectedSideBarItem) { _, newValue in
            if showInspector.show {
                showInspector.show = false
            }
            
            if selectedTasks.tasks.count > 0 {
                selectedTasks.tasks.removeAll()
            }
            
            if newValue != .projects {
                selectedProject = nil
            }
        }
        .onChange(of: selectedProject) { _, newValue in
            if newValue != nil && selectedSideBarItem != .projects {
                selectedSideBarItem = .projects
            }
        }
        .onChange(of: refresher.refresh, { _, _ in
            if checkSyncIssues() {
                fixSyncIssues()
            }
        })
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
        .inspector(isPresented: $showInspector.show) {
            Group {
                if let selectedTask = selectedTasks.tasks.first {
                    EditTaskView(task: selectedTask)
                } else {
                    Text("Select a task")
                }
            }
            .inspectorColumnWidth(min: 300, ideal: 300, max: 600)
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
