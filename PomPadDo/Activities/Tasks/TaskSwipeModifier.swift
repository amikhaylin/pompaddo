//
//  TaskSwipeModifier.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 11.06.2024.
//
// swiftlint:disable function_body_length

import SwiftUI
import SwiftData

struct TaskSwipeModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    #if os(iOS)
    @EnvironmentObject var showInspector: InspectorToggler
    @EnvironmentObject var selectedTasks: SelectedTasks
    #endif
    @Bindable var task: Todo
    var list: SideBarItem
    @Binding var tasks: [Todo]
    
    func body(content: Content) -> some View {
        content
            .swipeActions {
                Button(role: .destructive) {
                    withAnimation {
                        TasksQuery.deleteTask(context: modelContext,
                                              task: task)
                        if let index = tasks.firstIndex(of: task) {
                            tasks.remove(at: index)
                        }
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
                        .refreshable {
                            try? modelContext.save()
                            refresher.refresh.toggle()
                        }
                        .environmentObject(showInspector)
                        .environmentObject(selectedTasks)
                    } label: {
                        Label("Open subtasks", systemImage: "arrow.right")
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
                        Label("Open subtasks", systemImage: "arrow.right")
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
                        Label("Open subtasks", systemImage: "arrow.right")
                    }
                } else {
                    EmptyView()
                }
            }
        #endif
    }
}
// swiftlint:enable function_body_length
