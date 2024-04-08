//
//  ContentView.swift
//  VeraPlayaMac
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
    case projects
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var newTaskIsShowing = false
    @State private var newProjectIsShowing = false
    @AppStorage("selectedSideBar") var selectedSideBarItem: SideBarItem = .inbox
    
    @State private var selectedTasks = Set<Todo>()
    @State private var currentTask: Todo?
    @State private var selectedProject: Project?
    @AppStorage("projectsExpanded") var projectsExpanded = true
    
    @Query(filter: TasksQuery.predicateInbox(), sort: TasksQuery.defaultTaskSortDescriptor()) var tasksInbox: [Todo]
    @Query(filter: TasksQuery.predicateToday(), sort: [SortDescriptor(\Todo.dueDate)]) var tasksToday: [Todo]
    @Query(filter: TasksQuery.predicateTomorrow(), sort: [SortDescriptor(\Todo.dueDate)]) var tasksTomorrow: [Todo]
    @Query(filter: TasksQuery.predicateTodayActive(), sort: [SortDescriptor(\Todo.dueDate)]) var tasksTodayActive: [Todo]
    
    @Query var projects: [Project]
    
    @State var badgeManager = BadgeManager()

    var body: some View {
        NavigationSplitView {
            GeometryReader { geometry in
                VStack {
                    List(SideBarItem.allCases, selection: $selectedSideBarItem) { item in
                        switch item {
                        case .inbox:
                            NavigationLink(value: item) {
                                HStack {
                                    Image(systemName: "tray.fill")
                                    Text("Inbox")
                                }
                                .badge(tasksInbox.count)
                            }
                            .dropDestination(for: Todo.self) { tasks, _ in
                                for task in tasks {
                                    if let project = task.project, let index = project.tasks.firstIndex(of: task) {
                                        task.project?.tasks.remove(at: index)
                                        task.project = nil
                                        task.status = nil
                                    }
                                    if let parentTask = task.parentTask,
                                       let index = parentTask.subtasks?.firstIndex(of: task) {
                                        task.parentTask = nil
                                        parentTask.subtasks?.remove(at: index)
                                    }
                                }
                                return true
                            }
                            
                        case .today:
                            NavigationLink(value: item) {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text("Today")
                                }
                                .badge(tasksToday.count)
                            }
                            .dropDestination(for: Todo.self) { tasks, _ in
                                for task in tasks {
                                    task.dueDate = Calendar.current.startOfDay(for: Date())
                                }
                                return true
                            }
                        case .tomorrow:
                            NavigationLink(value: item) {
                                HStack {
                                    Image(systemName: "sunrise")
                                    Text("Tomorrow")
                                }
                                .badge(tasksTomorrow.count)
                            }
                            .dropDestination(for: Todo.self) { tasks, _ in
                                for task in tasks {
                                    task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                                }
                                return true
                            }
                        case .projects:
                            EmptyView()
                        }
                    }
                    .frame(height: 90)

                    List {
                        DisclosureGroup(isExpanded: $projectsExpanded) {
                            List(projects, id: \.self, selection: $selectedProject) { project in
                                NavigationLink(value: SideBarItem.projects) {
                                    Text(project.name)
                                        .badge(project.tasks.count)
                                }
                                .dropDestination(for: Todo.self) { tasks, _ in
                                    for task in tasks {
                                        task.project = project
                                        task.status = project.statuses.sorted(by: { $0.order < $1.order }).first
                                        project.tasks.append(task)
                                    }
                                    return true
                                }
                                .contextMenu {
                                    Button {
                                        selectedTasks = []
                                        modelContext.delete(project)
                                    } label: {
                                        Image(systemName: "trash")
                                        Text("Delete project")
                                    }
                                }
                            }
                            .frame(height: geometry.size.height > 150 ? geometry.size.height - 150 : 200)
                            .listStyle(SidebarListStyle())
                        } label: {
                            HStack {
                                Image(systemName: "list.bullet")
                                Text("Projects")
                                Spacer()
                                Button {
                                    newProjectIsShowing.toggle()
                                } label: {
                                    Image(systemName: "plus.circle")
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .listStyle(SidebarListStyle())
                }
                .navigationSplitViewColumnWidth(min: 200, ideal: 200)
                .toolbar {
                    ToolbarItem {
                        Button {
                            newTaskIsShowing.toggle()
                        } label: {
                            Label("Add task to Inbox", systemImage: "tray.and.arrow.down.fill")
                        }
                        
                    }
                }
                .sheet(isPresented: $newTaskIsShowing) {
                    NewTaskView(isVisible: self.$newTaskIsShowing, list: .inbox)
                }
                .sheet(isPresented: $newProjectIsShowing) {
                    NewProjectView(isVisible: self.$newProjectIsShowing)
                }
            }
        } content: {
            switch selectedSideBarItem {
            case .inbox:
                TasksListView(tasks: tasksInbox,
                              selectedTasks: $selectedTasks,
                              currentTask: $currentTask,
                              list: selectedSideBarItem)
            case .today:
                TasksListView(tasks: tasksToday,
                              selectedTasks: $selectedTasks,
                              currentTask: $currentTask,
                              list: selectedSideBarItem)
            case .tomorrow:
                TasksListView(tasks: tasksTomorrow,
                              selectedTasks: $selectedTasks,
                              currentTask: $currentTask,
                              list: selectedSideBarItem)
            case .projects:
                if let project = selectedProject {
                    ProjectTasksListView(selectedTasks: $selectedTasks,
                                         currentTask: $currentTask,
                                         project: project)
                } else {
                    Text("Select a project")
                }
            }
        } detail: {
            VStack {
                if currentTask != nil || selectedTasks.count > 0 {
                    if let currentTask = currentTask {
                        EditTaskView(task: currentTask)
                    } else if let selectedTask = selectedTasks.first {
                        EditTaskView(task: selectedTask)
                    }
                    Spacer()
                } else {
                    Image(systemName: "list.bullet.clipboard")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(Color.gray)
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 200, max: 300)
        }
        .onChange(of: tasksTodayActive.count) { _, newValue in
            newValue > 0 ? badgeManager.setBadge(number: newValue) : badgeManager.resetBadgeNumber()
        }
        .onChange(of: selectedSideBarItem, { _, newValue in
            selectedTasks = []
            currentTask = nil
            if newValue != .projects {
                selectedProject = nil
            }
        })
        .onChange(of: selectedProject) { _, newValue in
            if newValue != nil {
                selectedSideBarItem = .projects
            }
        }
        .onAppear {
            tasksToday.count > 0 ? badgeManager.setBadge(number: tasksToday.count) : badgeManager.resetBadgeNumber()
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
