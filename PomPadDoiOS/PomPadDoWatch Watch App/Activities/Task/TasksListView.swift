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
    
    var body: some View {
        NavigationStack {
            List(tasks) { task in
                HStack {
                    TaskCheckBoxView(task: task)
                    
                    NavigationLink {
                        TaskDetailsView(task: task, list: list)
                            .environmentObject(refresher)
                    } label: {
                        Text(task.name)
                    }
                }
                .modifier(TaskSwipeModifier(task: task))
                .environmentObject(refresher)
            }
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
