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
    @State var tasks: [Todo]
    
    @State var list: SideBarItem
    @State var title: String
    @State var mainTask: Todo?
    @Query(filter: TasksQuery.predicateTodayActive()) var tasksTodayActive: [Todo]
    
    @State private var searchText = ""
    
    var searchResults: [Todo] {
        if searchText.isEmpty {
            return tasks
        } else {
            return tasks.filter { $0.name.localizedStandardContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(searchResults) { task in
                HStack {
                    TaskCheckBoxView(task: task)
                    
                    NavigationLink {
                        TaskDetailsView(task: task, list: list, tasks: $tasks)
                    } label: {
                        Text(task.name)
                    }
                }
                .modifier(TaskSwipeModifier(task: task, list: list, tasks: $tasks))
            }
            .searchable(text: $searchText, placement: .automatic , prompt: "Search tasks")
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
    do {
        let previewer = try Previewer()
        let tasks: [Todo] = [previewer.task]
        
        return TasksListView(tasks: tasks,
                             list: .inbox,
                             title: "Some list")
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
