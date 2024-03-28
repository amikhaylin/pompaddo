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
    
    @State private var path = NavigationPath()
    @State private var newTaskIsShowing = false
    @State private var newProjectIsShowing = false
    @AppStorage("selectedSideBar") var selectedSideBarItem: SideBarItem = .inbox
    
    @State private var selectedTasks = Set<Todo>()
    @State private var currentTask: Todo?
    @State private var selectedProject: Project?
    
    @Query(filter: TasksQuery.predicate_inbox(), sort: [SortDescriptor(\Todo.dueDate)]) var tasksInbox: [Todo]
    @Query(filter: TasksQuery.predicate_today(), sort: [SortDescriptor(\Todo.dueDate)]) var tasksToday: [Todo]
    @Query(filter: TasksQuery.predicate_tomorrow(), sort: [SortDescriptor(\Todo.dueDate)]) var tasksTomorrow: [Todo]
    
    @Query var projects: [Project]
    
    @State var badgeManager = BadgeManager()

    var body: some View {
        NavigationSplitView {
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
                            task.project = nil
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
                    Section {
                        List(projects, id: \.self, selection: $selectedProject) { project in
                            NavigationLink(value: item) {
                                Text(project.name)
                                    .badge(project.tasks.count)
                            }
                            .dropDestination(for: Todo.self) { tasks, _ in
                                for task in tasks {
                                    task.project = project
                                    project.tasks.append(task)
                                }
                                return true
                            }
                        }
                        .listStyle(SidebarListStyle())
                        .frame(height: 100)
                    } header: {
                        HStack {
                            Text("Projects")
                            Spacer()
                            Button {
                                newProjectIsShowing.toggle()
                            } label: {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
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
                    Text("Empty project")
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
        .onChange(of: tasksToday.count) { _, newValue in
            newValue > 0 ? badgeManager.setBadge(number: newValue) : badgeManager.resetBadgeNumber()
        }
        .onChange(of: selectedSideBarItem, { _, _ in
            selectedTasks = []
            currentTask = nil
        })
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
