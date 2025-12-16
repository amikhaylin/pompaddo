//
//  TasksListView.swift
//  PomPadDoWatch Watch App
//
//  Created by Andrey Mikhaylin on 25.06.2024.
//

import SwiftUI
import SwiftData
import WidgetKit

struct TasksListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @Query var tasks: [Todo]
    
    @Binding var list: SideBarItem?
    @State var title: String
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    
    @State private var searchText = ""
    
    var searchResults: [Todo] {
        let innerTasks: [Todo]
        switch list {
        case .inbox:
            innerTasks = tasks.sorted(by: TasksQuery.sortingWithCompleted)
        case .today:
            innerTasks = tasks.filter({ TasksQuery.checkToday(date: $0.completionDate) && ($0.completed == false || ($0.completed && $0.parentTask == nil)) })
                .sorted(by: TasksQuery.sortingWithCompleted)
        case .tomorrow:
            innerTasks = tasks.sorted(by: TasksQuery.sortingWithCompleted)
        case .alltasks:
            innerTasks = tasks.sorted(by: TasksQuery.sortingWithCompleted)
        case .trash:
            innerTasks = tasks.sorted(by: TasksQuery.sortDeleted)
        default:
            innerTasks = tasks
        }
        
        if searchText.isEmpty {
            return innerTasks
        } else {
            return innerTasks.filter { $0.name.localizedStandardContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(searchResults) { task in
                HStack {
                    TaskCheckBoxView(task: task)
                    
                    NavigationLink {
                        TaskDetailsView(task: task, list: $list)
                    } label: {
                        Text(task.name)
                    }
                }
                .modifier(TaskSwipeModifier(task: task, list: $list))
            }
            .searchable(text: $searchText, placement: .automatic, prompt: "Search tasks")
        }
        .navigationTitle(title)
        .onChange(of: tasksTodayActive.count) { _, _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onAppear {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    init(predicate: Predicate<Todo>, list: Binding<SideBarItem?>, title: String) {
        self._list = list
        self.title = title
        
        self._tasks = Query(filter: predicate)
    }
}

#Preview {
    @Previewable @State var refresher = Refresher()
    @Previewable @State var container = try? ModelContainer(for: Schema([
                                                            ProjectGroup.self,
                                                            Status.self,
                                                            Todo.self,
                                                            Project.self
                                                        ]),
                                                       configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let previewer = Previewer(container!)
    
    TasksListView(predicate: TasksQuery.predicateInbox(),
                  list: .constant(.inbox),
                  title: "Some list")
        .environmentObject(refresher)
        .modelContainer(container!)
}
