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
    @Binding var selectedSideBarItem: SideBarItem?
    @Binding var selectedProject: Project?
    
    @Query var tasks: [Todo]
    
    var body: some View {
        NavigationSplitView {
            VStack {
                SectionsListView(selectedSideBarItem: $selectedSideBarItem)
                .frame(height: 270)
                
                ProjectsListView(selectedProject: $selectedProject,
                                 selectedSideBarItem: $selectedSideBarItem)
                .contentMargins(.vertical, 10)
            }
            .navigationSplitViewColumnWidth(min: 300, ideal: 300)
        } detail: {
            switch selectedSideBarItem {
            case .inbox:
                TasksListView(predicate: TasksQuery.predicateInbox(),
                              list: $selectedSideBarItem,
                              title: selectedSideBarItem!.name)
                .refreshable {
                    refresher.refresh.toggle()
                }
                .environmentObject(showInspector)
                .environmentObject(selectedTasks)
            case .today:
                TasksListView(predicate: TasksQuery.predicateToday(),
                              list: $selectedSideBarItem,
                              title: selectedSideBarItem!.name)
                .refreshable {
                    refresher.refresh.toggle()
                }
                .environmentObject(showInspector)
                .environmentObject(selectedTasks)
            case .tomorrow:
                TasksListView(predicate: TasksQuery.predicateTomorrow(),
                              list: $selectedSideBarItem,
                              title: selectedSideBarItem!.name)
                .refreshable {
                    refresher.refresh.toggle()
                }
                .environmentObject(showInspector)
                .environmentObject(selectedTasks)
            case .review:
                ReviewProjectsView()
                    .environmentObject(showInspector)
                    .environmentObject(selectedTasks)
            case .projects:
                if let project = selectedProject {
                    ProjectView(project: project)
                        .environmentObject(showInspector)
                        .environmentObject(selectedTasks)
                } else {
                    VStack {
                        Image(systemName: "document.badge.clock")
                            .resizable()
                            .foregroundStyle(Color.gray)
                            .frame(width: 100, height: 100)
                        
                        Text("Select a project")
                    }
                }
            case .alltasks:
                TasksListView(predicate: TasksQuery.predicateAll(),
                              list: $selectedSideBarItem,
                              title: selectedSideBarItem!.name)
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
}

#Preview {
    @Previewable @State var refresher = Refresher()
    @Previewable @StateObject var timer = FocusTimer(workInSeconds: 1500,
                                                     breakInSeconds: 300,
                                                     longBreakInSeconds: 1200,
                                                     workSessionsCount: 4)
    
    @Previewable @StateObject var focusTask = FocusTask()
    @Previewable @State var selectedSidebarItem: SideBarItem? = .today
    @Previewable @State var selectedProject: Project?
    @Previewable @State var container = try? ModelContainer(for: Schema([
        ProjectGroup.self,
        Status.self,
        Todo.self,
        Project.self
    ]),
                                                            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let previewer = Previewer(container!)
    
    ContentView(selectedSideBarItem: $selectedSidebarItem,
                selectedProject: $selectedProject)
        .environmentObject(refresher)
        .environmentObject(timer)
        .environmentObject(focusTask)
        .modelContainer(container!)
}
