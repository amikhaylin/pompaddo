//
//  TaskSwipeModifier.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 11.06.2024.
//

import SwiftUI
import SwiftData

struct TaskSwipeModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @Bindable var task: Todo
    var list: SideBarItem
    
    func body(content: Content) -> some View {
        content
            .swipeActions {
                Button(role: .destructive) {
                    withAnimation {
                        TasksQuery.deleteTask(context: modelContext,
                                              task: task)
                        refresher.refresh.toggle()
                    }
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
        #if os(iOS)
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                if let subtasks = task.subtasks {
                    NavigationLink {
                        TasksListView(tasks: subtasks,
                                      list: list,
                                      title: task.name,
                                      mainTask: task)
                        .id(refresher.refresh)
                    } label: {
                        Image(systemName: "arrow.right")
                        Text("Open subtasks")
                    }
                } else {
                    let subtasks = [Todo]()
                    
                    NavigationLink {
                        TasksListView(tasks: subtasks,
                                      list: list,
                                      title: task.name,
                                      mainTask: task)
                        .id(refresher.refresh)
                    } label: {
                        Image(systemName: "arrow.right")
                        Text("Open subtasks")
                    }
                }
            }
        #endif
        #if os(watchOS)
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                if let subtasks = task.subtasks {
                    NavigationLink {
                        TasksListView(tasks: subtasks,
                                      list: list,
                                      title: task.name,
                                      mainTask: task)
                        .id(refresher.refresh)
                    } label: {
                        Image(systemName: "arrow.right")
                        Text("Open subtasks")
                    }
                } else {
                    EmptyView()
                }
            }
        #endif
    }
}
