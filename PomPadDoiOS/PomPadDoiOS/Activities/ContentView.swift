//
//  ContentView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 13.05.2024.
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
    @ObservedObject private var showInspector = InspectorToggler()
    @ObservedObject private var selectedTasks = SelectedTasks()
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
                    .frame(height: 220)
                    .id(refresher.refresh)
                
                ProjectsListView(selectedProject: $selectedProject,
                                 projects: projects,
                                 selectedSideBarItem: $selectedSideBarItem)
                    .id(refresher.refresh)
            }
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
            default:
                EmptyView()
            }
        }
        .onChange(of: selectedSideBarItem) { _, newValue in
            if showInspector.on {
                showInspector.on = false
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
