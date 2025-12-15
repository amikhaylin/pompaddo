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
    @EnvironmentObject var showInspector: InspectorToggler
    @EnvironmentObject var selectedTasks: SelectedTasks
    @EnvironmentObject var focusTask: FocusTask
    @EnvironmentObject var timer: FocusTimer
    @Bindable var task: Todo
    @Binding var list: SideBarItem?
    
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button {
                    if !task.completed {
                        if let focus = focusTask.task, task == focus {
                            timer.reset()
                            if timer.mode == .pause || timer.mode == .longbreak {
                                timer.skip()
                            }
                            focusTask.task = nil
                        }
                        task.complete(modelContext: modelContext)
                    } else {
                        task.reactivate()
                    }
                } label: {
                    Label(task.completed ? "Incomplete" : "Complete", systemImage: task.completed ? "square" : "checkmark.square.fill")
                }
                
                Button(role: .destructive) {
                    withAnimation {
                        if let focus = focusTask.task, task == focus {
                            focusTask.task = nil
                        }

                        TasksQuery.deleteTask(task: task)
                    }
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
        #if !os(watchOS)
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                if let subtasks = task.subtasks {
                    NavigationLink {
                        SubtasksListView(list: $list,
                                      title: task.name,
                                      mainTask: task)
                        .refreshable {
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
                        SubtasksListView(list: $list,
                                      title: task.name,
                                      mainTask: task)
                    } label: {
                        Label("Open subtasks", systemImage: "arrow.right")
                    }
                }
            }
        #else
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                if let subtasks = task.subtasks {
                    NavigationLink {
                        SubtasksListView(list: $list,
                                      title: task.name,
                                      mainTask: task)
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
