//
//  SubtasksListView.swift
//  PomPadDo
//
//  Created by Andrey Mikhaylin on 07.08.2025.
//

import SwiftUI
import SwiftData
import WidgetKit

struct SubtasksListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    
    @State var list: SideBarItem
    @State var title: String
    @State var mainTask: Todo
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    
    @State private var searchText = ""
    
    var searchResults: [Todo] {
        let tasks: [Todo] = mainTask.subtasks != nil ? mainTask.subtasks! : [Todo]()
        if searchText.isEmpty {
            return tasks.sorted(by: TasksQuery.sortingWithCompleted)
        } else {
            return tasks.filter { $0.name.localizedStandardContains(searchText) }.sorted(by: TasksQuery.sortingWithCompleted)
        }
    }
    
    var body: some View {
        NavigationStack {
            List(searchResults) { task in
                HStack {
                    TaskCheckBoxView(task: task)
                    
                    NavigationLink {
                        TaskDetailsView(task: task, list: list)
                    } label: {
                        Text(task.name)
                    }
                }
                .modifier(TaskSwipeModifier(task: task, list: list))
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
    
    SubtasksListView(list: .inbox,
                     title: "Some list",
                     mainTask: previewer.task)
        .environmentObject(refresher)
        .modelContainer(container!)
}
