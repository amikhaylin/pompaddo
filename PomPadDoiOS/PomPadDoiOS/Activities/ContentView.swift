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
    
    @State private var refresh = false

    var body: some View {
        NavigationSplitView {
            VStack {
                SectionsListView(selectedSideBarItem: $selectedSideBarItem)
                    .frame(height: 220)
                    .id(refresh)
                    .refreshable {
                        refresh.toggle()
                    }
                
                ProjectsListView(selectedProject: $selectedProject,
                                 projects: projects)
                
            }
            .navigationSplitViewColumnWidth(min: 300, ideal: 300)
        } detail: {
            switch selectedSideBarItem {
            case .inbox:
                MainTasksListView(predicate: TasksQuery.predicateInbox(),
                                  filter: { $0.uid == $0.uid },
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                    .id(refresh)
                    .refreshable {
                        refresh.toggle()
                    }
            case .today:
                MainTasksListView(predicate: TasksQuery.predicateToday(),
                                  filter: { TasksQuery.checkToday(date: $0.completionDate) },
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                .id(refresh)
                .refreshable {
                    refresh.toggle()
                }
            case .tomorrow:
                MainTasksListView(predicate: TasksQuery.predicateTomorrow(), 
                                  filter: { $0.completionDate == nil },
                                  list: selectedSideBarItem!,
                                  title: selectedSideBarItem!.name)
                .id(refresh)
                .refreshable {
                    refresh.toggle()
                }
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
                .id(refresh)
                .refreshable {
                    refresh.toggle()
                }
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
