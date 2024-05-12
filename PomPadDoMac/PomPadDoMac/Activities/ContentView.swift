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
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var newTaskIsShowing = false
    @State private var newProjectIsShowing = false
    @State private var newProjectGroupShow = false
    @AppStorage("selectedSideBar") var selectedSideBarItem: SideBarItem = .inbox
    
    @State private var selectedTasks = Set<Todo>()
    @State private var selectedProject: Project?
    
    @Query(filter: TasksQuery.predicateInbox()) var tasksInbox: [Todo]
    @Query(filter: TasksQuery.predicateToday()) var tasksToday: [Todo]
    @Query(filter: TasksQuery.predicateTomorrow()) var tasksTomorrow: [Todo]
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    
    @Query var projects: [Project]
    
    @State var badgeManager = BadgeManager()

    var body: some View {
        NavigationSplitView {
            VStack {
                List(SideBarItem.allCases, selection: $selectedSideBarItem) { item in
                    switch item {
                    case .inbox:
                        NavigationLink(value: item) {
                            HStack {
                                Image(systemName: "tray")
                                Text("Inbox")
                            }
                            .foregroundStyle(Color(#colorLiteral(red: 0.4890732765, green: 0.530819118, blue: 0.7039532065, alpha: 1)))
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
                            .foregroundStyle(Color(#colorLiteral(red: 0.9496305585, green: 0.5398437977, blue: 0.3298020959, alpha: 1)))
                            .badge(tasksToday.filter({ $0.completed == false}).count)
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
                            .foregroundStyle(Color(#colorLiteral(red: 0.9219498038, green: 0.2769843042, blue: 0.402439177, alpha: 1)))
                            .badge(tasksTomorrow.filter({ $0.completed == false }).count)
                        }
                        .dropDestination(for: Todo.self) { tasks, _ in
                            for task in tasks {
                                task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                            }
                            return true
                        }
                    case .projects:
                        EmptyView()
                    case .review:
                        NavigationLink(value: item) {
                            HStack {
                                Image(systemName: "cup.and.saucer")
                                Text("Review")
                            }
                            .foregroundStyle(Color(#colorLiteral(red: 0.480404973, green: 0.507386148, blue: 0.9092046022, alpha: 1)))
                            .badge(projects.filter({
                                let today = Date()
                                if let dateToReview = Calendar.current.date(byAdding: .day,
                                                                            value: $0.reviewDaysCount,
                                                                            to: $0.reviewDate) {
                                    return dateToReview <= today
                                } else {
                                    return false
                                }
                            }).count)
                        }
                    }
                }
                .frame(height: 125)
                
                Divider()
                
                ProjectsListView(selectedProject: $selectedProject,
                                 selectedTasks: $selectedTasks,
                                 newProjectIsShowing: $newProjectIsShowing,
                                 newProjectGroupShow: $newProjectGroupShow,
                                 projects: projects)
            }
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
            .sheet(isPresented: $newProjectGroupShow) {
                NewProjectGroupView(isVisible: self.$newProjectGroupShow)
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 200)
        } detail: {
            HStack {
                switch selectedSideBarItem {
                case .inbox:
                    TasksListView(tasks: tasksInbox.sorted(by: TasksQuery.defaultSorting),
                                  selectedTasks: $selectedTasks,
                                  list: selectedSideBarItem)
                case .today:
                    TasksListView(tasks: tasksToday
                        .filter({ TasksQuery.checkToday(date: $0.completionDate) })
                        .sorted(by: TasksQuery.defaultSorting),
                                  selectedTasks: $selectedTasks,
                                  list: selectedSideBarItem)
                case .tomorrow:
                    TasksListView(tasks: tasksTomorrow
                        .filter({ $0.completionDate == nil })
                        .sorted(by: TasksQuery.defaultSorting),
                                  selectedTasks: $selectedTasks,
                                  list: selectedSideBarItem)
                case .projects:
                    if let project = selectedProject {
                        ProjectView(selectedTasks: $selectedTasks,
                                    project: project)
                    } else {
                        Text("Select a project")
                    }
                case .review:
                    ReviewProjectsView(projects: projects.filter({
                        let today = Date()
                        if let dateToReview = Calendar.current.date(byAdding: .day,
                                                                    value: $0.reviewDaysCount,
                                                                    to: $0.reviewDate) {
                            return dateToReview <= today
                        } else {
                            return false
                        }
                    }),
                                       selectedTasks: $selectedTasks)
                }
                
                if selectedTasks.count > 0 {
                    if let selectedTask = selectedTasks.first {
                        EditTaskView(task: selectedTask)
                            .frame(minWidth: 270, idealWidth: 270, maxWidth: 350)
                            .padding()
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        selectedTasks = []
                    } label: {
                        Image(systemName: "sidebar.right")
                    }.disabled(!(selectedTasks.count > 0))
                }
            }
        }
        .onChange(of: tasksTodayActive.count) { _, newValue in
            newValue > 0 ? badgeManager.setBadge(number: newValue) : badgeManager.resetBadgeNumber()
        }
        .onChange(of: selectedSideBarItem, { _, newValue in
            selectedTasks = []
            if newValue != .projects {
                selectedProject = nil
            }
        })
        .onChange(of: selectedProject) { _, newValue in
            selectedTasks = []
            if newValue != nil {
                selectedSideBarItem = .projects
            }
        }
        .onAppear {
            tasksToday.count > 0 ? badgeManager.setBadge(number: tasksTodayActive.count) : badgeManager.resetBadgeNumber()
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
