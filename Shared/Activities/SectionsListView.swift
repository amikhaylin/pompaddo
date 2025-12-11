//
//  SectionsListView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 12.06.2024.
//

import SwiftUI
import SwiftData
import WidgetKit

struct SectionsListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    
    @Binding var selectedSideBarItem: SideBarItem?
    
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    @Query(filter: TasksQuery.predicateInboxActive()) var tasksInboxActive: [Todo]
    @Query(filter: TasksQuery.predicateTomorrowActive()) var tasksTomorrowActive: [Todo]
    @Query(filter: TasksQuery.predicateAllActive()) var tasksAllActive: [Todo]
    @Query(filter: TasksQuery.predicateDeadlinesActive()) var tasksDeadlinesActive: [Todo]
    @Query(filter: TasksQuery.predicateTrash()) var tasksTrash: [Todo]
    @Query var projects: [Project]
           
    @State var badgeManager = BadgeManager()
    @AppStorage("projectsExpanded") var projectsExpanded = true
    @AppStorage("showReviewBadge") private var showReviewProjectsBadge: Bool = false
    @State var projectListSize: CGSize = .zero
    
    @AppStorage("showDeadlinesSection") var showDeadlinesSection: Bool = true
    @AppStorage("showAllSection") var showAllSection: Bool = true
    @AppStorage("showReviewSection") var showReviewSection: Bool = true
    @AppStorage("showTomorrowSection") var showTomorrowSection: Bool = true
    @AppStorage("showTrashSection") var showTrashSection: Bool = true
    
    var body: some View {
        List(SideBarItem.allCases, selection: $selectedSideBarItem) { item in
            switch item {
            case .inbox:
                NavigationLink(value: item) {
                    HStack {
                        Image(systemName: "tray")
                        Text("Inbox")
                    }
                    .foregroundStyle(Color(#colorLiteral(red: 0.4890732765, green: 0.530819118, blue: 0.7039532065, alpha: 1)))
                    .badge(tasksInboxActive.count)
                }
                .accessibilityIdentifier("InboxNavButton")
                .dropDestination(for: Todo.self) { tasks, _ in
                    for task in tasks {
                        TasksQuery.restoreTask(task: task)
                        if let project = task.project, let index = project.tasks?.firstIndex(of: task) {
                            task.project?.tasks?.remove(at: index)
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
                .listRowSeparator(.hidden)
                
            case .today:
                NavigationLink(value: item) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Today")
                    }
                    .foregroundStyle(Color(#colorLiteral(red: 0.9496305585, green: 0.5398437977, blue: 0.3298020959, alpha: 1)))
                    .badge(tasksTodayActive.count)
                }
                .accessibilityIdentifier("TodayNavButton")
                .dropDestination(for: Todo.self) { tasks, _ in
                    for task in tasks {
                        TasksQuery.restoreTask(task: task)
                        task.setDueDate(dueDate: Calendar.current.startOfDay(for: Date()))
                    }
                    return true
                }
                .listRowSeparator(.hidden)
            case .tomorrow:
                if showTomorrowSection {
                    NavigationLink(value: item) {
                        HStack {
                            Image(systemName: "sunrise")
                            Text("Tomorrow")
                        }
                        .foregroundStyle(Color(#colorLiteral(red: 0.9219498038, green: 0.2769843042, blue: 0.402439177, alpha: 1)))
                        .badge(tasksTomorrowActive.count)
                    }
                    .dropDestination(for: Todo.self) { tasks, _ in
                        for task in tasks {
                            TasksQuery.restoreTask(task: task)
                            task.setDueDate(dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())))
                        }
                        return true
                    }
                    .listRowSeparator(.hidden)
                } else {
                    EmptyView()
                }
            case .projects:
                EmptyView()
            case .review:
                if showReviewSection {
                    NavigationLink(value: item) {
                        HStack {
                            Image(systemName: "cup.and.saucer")
                            Text("Review")
                        }
                        .foregroundStyle(Color(#colorLiteral(red: 0.480404973, green: 0.507386148, blue: 0.9092046022, alpha: 1)))
                        .badge(projects.filter({ TasksQuery.filterProjectToReview($0) }).count)
                    }
                    .listRowSeparator(.hidden)
                } else {
                    EmptyView()
                }
            case .deadlines:
                if showDeadlinesSection {
                    NavigationLink(value: item) {
                        HStack {
                            Image(systemName: "calendar.badge.exclamationmark")
                            Text("Deadlines")
                        }
                        .foregroundStyle(Color(#colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)))
                        .badge(tasksDeadlinesActive.count)
                    }
                    .listRowSeparator(.hidden)
                } else {
                    EmptyView()
                }
            case .alltasks:
                if showAllSection {
                    NavigationLink(value: item) {
                        HStack {
                            Image(systemName: "rectangle.stack")
                            Text("All")
                        }
                        .foregroundStyle(Color(#colorLiteral(red: 0.5274487734, green: 0.5852636099, blue: 0.6280642748, alpha: 1)))
                        .badge(tasksAllActive.count)
                    }
                    .dropDestination(for: Todo.self) { tasks, _ in
                        for task in tasks {
                            TasksQuery.restoreTask(task: task)
                        }
                        return true
                    }
                    .listRowSeparator(.hidden)
                } else {
                    EmptyView()
                }
            case .trash:
                if showTrashSection {
                    NavigationLink(value: item) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Trash")
                        }
                        .foregroundStyle(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                    }
                    .dropDestination(for: Todo.self) { tasks, _ in
                        for task in tasks {
                            TasksQuery.deleteTask(task: task)
                        }
                        return true
                    }
                    .contextMenu {
                        Button {
                            TasksQuery.emptyTrash(context: modelContext, tasks: tasksTrash)
                        } label: {
                            Image(systemName: "trash.fill")
                            Text("Empty trash")
                        }
                    }
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(SidebarListStyle())
        .onChange(of: projects.filter({ TasksQuery.filterProjectToReview($0) }).count, { _, newValue in
            if showReviewProjectsBadge {
                let tasksCount = tasksTodayActive.count
                if (newValue + tasksCount) > 0 {
                    badgeManager.setBadge(number: (newValue + tasksCount))
                } else {
                    badgeManager.resetBadgeNumber()
                }
                WidgetCenter.shared.reloadAllTimelines()
            }
        })
        .onChange(of: tasksTodayActive.count) { _, newValue in
            var projectsCount = 0
            if showReviewProjectsBadge {
                projectsCount = projects.filter({ TasksQuery.filterProjectToReview($0) }).count
            }
            
            if (newValue + projectsCount) > 0 {
                badgeManager.setBadge(number: (newValue + projectsCount))
            } else {
                badgeManager.resetBadgeNumber()
            }
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onAppear {
            var projectsCount = 0
            if showReviewProjectsBadge {
                projectsCount = projects.filter({ TasksQuery.filterProjectToReview($0) }).count
            }
            if (tasksTodayActive.count + projectsCount) > 0 { badgeManager.setBadge(number: (tasksTodayActive.count + projectsCount))
            } else {
                badgeManager.resetBadgeNumber()
            }
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

#Preview {
    @Previewable @State var selectedSideBarItem: SideBarItem? = .today
    @Previewable @State var refresher = Refresher()
    
    let previewer = try? Previewer()
    
    SectionsListView(selectedSideBarItem: $selectedSideBarItem)
        .environmentObject(refresher)
        .modelContainer(previewer!.container)
}
