//
//  ContentView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 13.05.2024.
//

import SwiftUI
import SwiftData

import SwiftDataTransferrable
import CloudStorage

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @StateObject private var showInspector = InspectorToggler()
    @StateObject private var selectedTasks = SelectedTasks()
    @Binding var selectedSideBarItem: SideBarItem?
    @Binding var selectedProject: Project?
    @AppStorage("SectionHeight") var sectionHeight = 350.0
    @State private var currentSectionHeight: CGFloat = 350.0
    
    @Query var tasks: [Todo]
    
    @AppStorage("showDeadlinesSection") var showDeadlinesSection: Bool = true
    @AppStorage("showAllSection") var showAllSection: Bool = true
    @AppStorage("showReviewSection") var showReviewSection: Bool = true
    @AppStorage("showTomorrowSection") var showTomorrowSection: Bool = true
    @AppStorage("showTrashSection") var showTrashSection: Bool = true
    @CloudStorage("emptyTrash") var emptyTrash: Bool = UserDefaults.standard.value(forKey: "emptyTrash") as? Bool ?? true
    @CloudStorage("eraseTasksForDays") var eraseTasksForDays: Int = UserDefaults.standard.value(forKey: "eraseTasksForDays") as? Int ?? 7
    
    var body: some View {
        NavigationSplitView {
            VStack {
                SectionsListView(selectedSideBarItem: $selectedSideBarItem)
                    .frame(height: currentSectionHeight)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                    .frame(height: 5)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newHeight = currentSectionHeight + gesture.translation.height
                                currentSectionHeight = min(max(newHeight, 50.0), getMaxSectionsHeight())
                            }
                            .onEnded({ _ in
                                sectionHeight = currentSectionHeight
                            })
                    )
                
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
            case .deadlines:
                TasksListView(predicate: TasksQuery.predicateDeadlines(),
                              list: $selectedSideBarItem,
                              title: selectedSideBarItem!.name)
                .environmentObject(showInspector)
                .environmentObject(selectedTasks)
            case .trash:
                TrashListView(list: $selectedSideBarItem,
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
            let deleteTo = Calendar.current.date(byAdding: .day, value: -eraseTasksForDays, to: Date())!
            
            for task in tasks {
                if emptyTrash {
                    if let deletionDate = task.deletionDate, deletionDate < deleteTo {
                        TasksQuery.eraseTask(context: modelContext, task: task)
                    }
                }
                
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
    
    private func getMaxSectionsHeight() -> CGFloat {
        var maxHeight: CGFloat = 150.0
        let incrementHeight: CGFloat = 50.0
        
        if showDeadlinesSection {
            maxHeight += incrementHeight
        }
        
        if showAllSection {
            maxHeight += incrementHeight
        }
        
        if showReviewSection {
            maxHeight += incrementHeight
        }
        
        if showTomorrowSection {
            maxHeight += incrementHeight
        }
        
        if showTrashSection {
            maxHeight += incrementHeight
        }
        
        return maxHeight
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
    let _ = Previewer(container!)
    
    ContentView(selectedSideBarItem: $selectedSidebarItem,
                selectedProject: $selectedProject)
        .environmentObject(refresher)
        .environmentObject(timer)
        .environmentObject(focusTask)
        .modelContainer(container!)
}
