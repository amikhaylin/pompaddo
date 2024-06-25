//
//  TasksListView.swift
//  PomPadDoWatch Watch App
//
//  Created by Andrey Mikhaylin on 25.06.2024.
//

import SwiftUI
import SwiftData

struct TasksListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @State var tasks: [Todo]
    
    @State var list: SideBarItem
    @State var title: String
    @State var mainTask: Todo?
    
    var body: some View {
        NavigationStack {
            List(tasks) { task in
                HStack {
                    TaskCheckBoxView(task: task)
                    
                    Text(task.name)
                }
                .modifier(TaskSwipeModifier(task: task))
                .environmentObject(refresher)
            }
        }
        .navigationTitle(title)
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
