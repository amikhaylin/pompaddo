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
    @Binding var selectedProject: Project?
    @AppStorage("SectionHeight") var sectionHeight = 170.0
    @State private var currentSectionHeight: CGFloat = 170.0
    
    @Query var tasks: [Todo]
    
    var body: some View {
        NavigationSplitView {
            VStack {
                SectionsListView(selectedSideBarItem: $selectedSideBarItem)
                    .frame(height: currentSectionHeight)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                    .frame(height: 5)
                    .cursor(.resizeUpDown)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newHeight = currentSectionHeight + gesture.translation.height
                                currentSectionHeight = min(max(newHeight, 30.0), 170.0)
                            }
                            .onEnded({ _ in
                                sectionHeight = currentSectionHeight
                            })
                    )
                
                ProjectsListView(selectedProject: $selectedProject,
                                 selectedSideBarItem: $selectedSideBarItem)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        newTaskIsShowing.toggle()
                    } label: {
                        Label("Add task to Inbox", systemImage: "tray.and.arrow.down.fill")
                            .foregroundStyle(Color.orange)
                    }
                    .help("Add to Inbox ⌘I")
                    .accessibilityIdentifier("AddTaskToInboxButton")
                }
            }
            .sheet(isPresented: $newTaskIsShowing) {
                NewTaskView(isVisible: self.$newTaskIsShowing, list: .inbox, project: nil, mainTask: nil)
            }
            .navigationSplitViewColumnWidth(min: 230, ideal: 230, max: 400)
        } detail: {
            HStack {
                switch selectedSideBarItem {
                case .inbox:
                    TasksListView(predicate: TasksQuery.predicateInbox(),
                                  list: $selectedSideBarItem,
                                  title: selectedSideBarItem!.name)
                    .environmentObject(showInspector)
                    .environmentObject(selectedTasks)
                case .today:
                    TasksListView(predicate: TasksQuery.predicateToday(),
                                  list: $selectedSideBarItem,
                                  title: selectedSideBarItem!.name)
                    .environmentObject(showInspector)
                    .environmentObject(selectedTasks)
                case .tomorrow:
                    TasksListView(predicate: TasksQuery.predicateTomorrow(),
                                  list: $selectedSideBarItem,
                                  title: selectedSideBarItem!.name)
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
                case .review:
                    ReviewProjectsView()
                        .environmentObject(showInspector)
                        .environmentObject(selectedTasks)
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
        .onAppear {
            currentSectionHeight = CGFloat(sectionHeight)
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
    @Previewable @State var selectedProject: Project?
    @Previewable @State var container = try? ModelContainer(for: Schema([
                                                            ProjectGroup.self,
                                                            Status.self,
                                                            Todo.self,
                                                            Project.self
                                                        ]),
                                                       configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    let _ = Previewer(container!)
    
    ContentView(selectedSideBarItem: $selectedSideBarItem,
                newTaskIsShowing: $newTaskIsShowing,
                selectedProject: $selectedProject)
        .environmentObject(selectedTasks)
        .environmentObject(refresher)
        .environmentObject(timer)
        .environmentObject(focusTask)
        .modelContainer(container!)
}
