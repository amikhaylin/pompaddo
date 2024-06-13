//
//  SectionsListView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 12.06.2024.
//

import SwiftUI
import SwiftData

struct SectionsListView: View {
    @Query(filter: TasksQuery.predicateInbox()) var tasksInbox: [Todo]
    @Query(filter: TasksQuery.predicateToday()) var tasksToday: [Todo]
    @Query(filter: TasksQuery.predicateTomorrow()) var tasksTomorrow: [Todo]
    @Query var projects: [Project]
    
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    
    @Binding var selectedSideBarItem: SideBarItem?
    
    @State var badgeManager = BadgeManager()
    
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
                    .badge(tasksInbox.filter({ $0.completed == false}).count)
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
                        if $0.showInReview == false {
                            return false
                        }
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
        .listStyle(SidebarListStyle())
        .onChange(of: tasksTodayActive.count) { _, newValue in
            newValue > 0 ? badgeManager.setBadge(number: newValue) : badgeManager.resetBadgeNumber()
        }
        .onAppear {
            tasksTodayActive.count > 0 ? badgeManager.setBadge(number: tasksTodayActive.count) : badgeManager.resetBadgeNumber()
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var selectedSideBarItem: SideBarItem? = .today
        
        return SectionsListView(selectedSideBarItem: $selectedSideBarItem)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
