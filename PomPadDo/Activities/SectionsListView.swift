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
    var tasks: [Todo]
    var projects: [Project]
    
    @Binding var selectedSideBarItem: SideBarItem?
    
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    @State var badgeManager = BadgeManager()
    @AppStorage("projectsExpanded") var projectsExpanded = true
    @AppStorage("showReviewBadge") private var showReviewProjectsBadge: Bool = false
    @State var projectListSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            List(SideBarItem.allCases, selection: $selectedSideBarItem) { item in
                switch item {
                case .inbox:
                    NavigationLink(value: item) {
                        HStack {
                            Image(systemName: "tray")
                            Text("Inbox")
                        }
                        .foregroundStyle(Color(#colorLiteral(red: 0.4890732765, green: 0.530819118, blue: 0.7039532065, alpha: 1)))
                        .badge({
                            do {
                                return try tasks.filter(TasksQuery.predicateInboxActive()).count
                            } catch {
                                print(error.localizedDescription)
                                return 0
                            }
                        }())
                    }
                    .dropDestination(for: Todo.self) { tasks, _ in
                        for task in tasks {
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
                            try? modelContext.save()
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
                        .badge(tasksTodayActive.count)
                    }
                    .dropDestination(for: Todo.self) { tasks, _ in
                        for task in tasks {
                            task.setDueDate(modelContext: modelContext, dueDate: Calendar.current.startOfDay(for: Date()))
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
                        .badge({
                            do {
                                return try tasks.filter(TasksQuery.predicateTomorrow()).count
                            } catch {
                                print(error.localizedDescription)
                                return 0
                            }
                        }())
                    }
                    .dropDestination(for: Todo.self) { tasks, _ in
                        for task in tasks {
                            task.setDueDate(modelContext: modelContext, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())))
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
                        .badge(projects.filter({ TasksQuery.filterProjectToReview($0) }).count)
                    }
                case .alltasks:
                    NavigationLink(value: item) {
                        HStack {
                            Image(systemName: "rectangle.stack")
                            Text("All")
                        }
                        .foregroundStyle(Color(#colorLiteral(red: 0.5274487734, green: 0.5852636099, blue: 0.6280642748, alpha: 1)))
                        .badge({
                            do {
                                return try tasks.filter(TasksQuery.predicateAllActive()).count
                            } catch {
                                print(error.localizedDescription)
                                return 0
                            }
                        }())
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
}

#Preview {
    @Previewable @State var selectedSideBarItem: SideBarItem? = .today
    @Previewable @State var refresher = Refresher()
    
    let previewer = try? Previewer()
    let tasks = [Todo]()
    let projects = [Project]()
    
    SectionsListView(tasks: tasks,
                            projects: projects,
                            selectedSideBarItem: $selectedSideBarItem)
        .environmentObject(refresher)
        .modelContainer(previewer!.container)
}
