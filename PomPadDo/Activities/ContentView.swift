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
    @EnvironmentObject var selectedTasks: SelectedTasks
  
    @StateObject private var showInspector = InspectorToggler()
    
    @Binding var selectedSideBarItem: SideBarItem?
    @Binding var newTaskIsShowing: Bool
    
    @State private var selectedProject: Project?
    
    @Query var tasks: [Todo]
    @Query var projects: [Project]
    
    var body: some View {
        NavigationSplitView {
            SectionsListView(tasks: tasks,
                             projects: projects,
                             selectedSideBarItem: $selectedSideBarItem,
                             selectedProject: $selectedProject)
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        try? modelContext.save()
                        
                        refresher.refresh.toggle()
                    } label: {
                        Label("Refresh", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .help("Refresh ⌘R")
                    
                    Button {
                        newTaskIsShowing.toggle()
                    } label: {
                        Label("Add task to Inbox", systemImage: "tray.and.arrow.down.fill")
                            .foregroundStyle(Color.orange)
                    }
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
                        VStack {
                            Image(systemName: "document.badge.clock")
                                .resizable()
                                .foregroundStyle(Color.gray)
                                .frame(width: 100, height: 100)
                            
                            Text("Select a project")
                        }
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
            if showInspector.show {
                showInspector.show = false
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
                let task = Todo(name: title)
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
                try? modelContext.save()
                refresher.refresh.toggle()
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
    @Previewable @StateObject var selectedTasks = SelectedTasks()
    @Previewable @State var refresher = Refresher()
    @Previewable @StateObject var timer = FocusTimer(workInSeconds: 1500,
                                                     breakInSeconds: 300,
                                                     longBreakInSeconds: 1200,
                                                     workSessionsCount: 4)
                              
    @Previewable @StateObject var focusTask = FocusTask()
    @Previewable @State var selectedSideBarItem: SideBarItem? = .today
    @Previewable @State var newTaskIsShowing = false
    @Previewable @State var container = try? ModelContainer(for: Schema([
                                                            ProjectGroup.self,
                                                            Status.self,
                                                            Todo.self,
                                                            Project.self
                                                        ]),
                                                       configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    let previewer = Previewer(container!)
    
    ContentView(selectedSideBarItem: $selectedSideBarItem,
                newTaskIsShowing: $newTaskIsShowing)
        .environmentObject(selectedTasks)
        .environmentObject(refresher)
        .environmentObject(timer)
        .environmentObject(focusTask)
        .modelContainer(container!)
}
