//
//  ContentView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 13.05.2024.
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
    
    var name: String {
        switch self {
        case .inbox:
            return NSLocalizedString("Inbox", comment: "")
        case .today:
            return NSLocalizedString("Today", comment: "")
        case .tomorrow:
            return NSLocalizedString("Tomorrow", comment: "")
        case .review:
            return NSLocalizedString("Review", comment: "")
        case .projects:
            return NSLocalizedString("Projects", comment: "")
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
//    @AppStorage("selectedSideBar")
    @State var selectedSideBarItem: SideBarItem? = .today
    
    @State private var selectedProject: Project?
    
    @Query var projects: [Project]
    
    @Query(filter: TasksQuery.predicateInbox()) var tasksInbox: [Todo]
    @Query(filter: TasksQuery.predicateToday()) var tasksToday: [Todo]
    @Query(filter: TasksQuery.predicateTomorrow()) var tasksTomorrow: [Todo]
    
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    @State var badgeManager = BadgeManager()

    var body: some View {
        NavigationSplitView {
            VStack {
                SectionsListView(selectedSideBarItem: $selectedSideBarItem)
                    .frame(height: 220)
                
                ProjectsListView(selectedProject: $selectedProject,
                                 projects: projects)
                
            }
            .navigationSplitViewColumnWidth(min: 300, ideal: 300)
        } detail: {
            switch selectedSideBarItem {
            case .inbox:
                TasksListView(tasks: tasksInbox.sorted(by: TasksQuery.defaultSorting),
                              list: selectedSideBarItem!,
                              title: selectedSideBarItem!.name)
            case .today:
                TasksListView(tasks: tasksToday
                    .filter({ TasksQuery.checkToday(date: $0.completionDate) })
                    .sorted(by: TasksQuery.defaultSorting),
                              list: selectedSideBarItem!,
                              title: selectedSideBarItem!.name)
            case .tomorrow:
                TasksListView(tasks: tasksTomorrow
                    .filter({ $0.completionDate == nil })
                    .sorted(by: TasksQuery.defaultSorting),
                              list: selectedSideBarItem!,
                              title: selectedSideBarItem!.name)
            case .review:
                ReviewProjectsView(projects: projects.filter({
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
                }))
            case .projects:
                if let project = selectedProject {
                    ProjectView(project: project)
                } else {
                    Text("Select a project")
                }
            default:
                EmptyView()
            }
        }
        .onChange(of: selectedSideBarItem) { _, newValue in
            if newValue != .projects {
                selectedProject = nil
            }
        }
        .onChange(of: selectedProject) { _, newValue in
            if newValue != nil {
                selectedSideBarItem = .projects
            }
        }
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
        
        return ContentView()
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
