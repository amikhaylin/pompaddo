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
    
    @State private var newTaskIsShowing = false
    @State var selectedSideBarItem: SideBarItem? = .today
    
    @State private var selectedProject: Project?
    
    @Query var projects: [Project]
    
    @State private var refresh = false
    
    var body: some View {
        NavigationSplitView {
            VStack {
                SectionsListView(selectedSideBarItem: $selectedSideBarItem)
                    .frame(height: 125)
                    .id(refresh)
                    .refreshable {
                        refresh.toggle()
                    }
                
                ProjectsListView(selectedProject: $selectedProject,
                                 projects: projects)
            }
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        refresh.toggle()
                    } label: {
                        Label("Refresh", systemImage: "arrow.triangle.2.circlepath")
                    }
                    
                    Button {
                        newTaskIsShowing.toggle()
                    } label: {
                        Label("Add task to Inbox", systemImage: "tray.and.arrow.down.fill")
                            .foregroundStyle(Color.orange)
                    }
                }
            }
            .sheet(isPresented: $newTaskIsShowing) {
                NewTaskView(isVisible: self.$newTaskIsShowing, list: .inbox)
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 200, max: 400)
        } detail: {
            HStack {
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
                case .projects:
                    if let project = selectedProject {
                        ProjectView(project: project)
                    } else {
                        Text("Select a project")
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
                default:
                    EmptyView()
                }
            }
        }
        .onChange(of: selectedSideBarItem, { _, newValue in
            if newValue != .projects {
                selectedProject = nil
            }
        })
        .onChange(of: selectedProject) { _, newValue in
            if newValue != nil {
                selectedSideBarItem = .projects
            }
        }
        .onOpenURL { url in
            print(url.absoluteString)
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let title = components?.queryItems?.first(where: { $0.name == "title" })?.value,
               let link = components?.queryItems?.first(where: { $0.name == "link" })?.value,
               let linkurl = URL(string: link) {
                
                let task = Todo(name: title, link: linkurl.absoluteString)
                modelContext.insert(task)
            }
            selectedSideBarItem = .inbox
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
