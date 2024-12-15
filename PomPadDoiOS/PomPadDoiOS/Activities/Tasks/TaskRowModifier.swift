//
//  TaskRowModifier.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 11.06.2024.
//
// swiftlint:disable function_body_length
// swiftlint:disable cyclomatic_complexity

import SwiftUI
import SwiftData

struct TaskRowModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @EnvironmentObject var showInspector: InspectorToggler
    @EnvironmentObject var selectedTasks: SelectedTasks
    @Bindable var task: Todo
    @Binding var selectedTasksSet: Set<Todo>
    var projects: [Project]
    var list: SideBarItem
    @Binding var tasks: [Todo]
    @State private var showAddSubtask = false
    
    func body(content: Content) -> some View {
       content
        .draggable(task)
        .dropDestination(for: Todo.self) { tasks, _ in
            // Attach dropped task as subtask
            for dropTask in tasks where dropTask != task {
                dropTask.disconnectFromAll()
                dropTask.parentTask = task
                dropTask.reconnect()
            }
            return true
        }
        .contextMenu {
            Button {
                if selectedTasksSet.count > 0 && selectedTasksSet.contains(task) {
                    for task in selectedTasksSet {
                        task.dueDate = nil
                    }
                } else {
                    task.dueDate = nil
                }
                
                if list == .today || list == .tomorrow {
                    if let index = tasks.firstIndex(of: task) {
                        tasks.remove(at: index)
                    }
                }
                // FIXME: refresher.refresh.toggle()
            } label: {
                Image(systemName: "clear")
                Text("Clear due date")
            }
            
            Button {
                if selectedTasksSet.count > 0 && selectedTasksSet.contains(task) {
                    for task in selectedTasksSet {
                        task.dueDate = Calendar.current.startOfDay(for: Date())
                    }
                } else {
                    task.dueDate = Calendar.current.startOfDay(for: Date())
                }
                if list == .tomorrow {
                    if let index = tasks.firstIndex(of: task) {
                        tasks.remove(at: index)
                    }
                }
                // FIXME: refresher.refresh.toggle()
            } label: {
                Image(systemName: "calendar")
                Text("Today")
            }
            
            Button {
                if selectedTasksSet.count > 0 && selectedTasksSet.contains(task) {
                    for task in selectedTasksSet {
                        task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                    }
                } else {
                    task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                }
                if list == .today {
                    if let index = tasks.firstIndex(of: task) {
                        tasks.remove(at: index)
                    }
                }
                // FIXME: refresher.refresh.toggle()
            } label: {
                Image(systemName: "sunrise")
                Text("Tomorrow")
            }
            
            Button {
                if selectedTasksSet.count > 0 && selectedTasksSet.contains(task) {
                    for task in selectedTasksSet {
                        task.nextWeek()
                    }
                } else {
                    task.nextWeek()
                }
                if list == .today || list == .tomorrow {
                    if let index = tasks.firstIndex(of: task) {
                        tasks.remove(at: index)
                    }
                }
                // FIXME: refresher.refresh.toggle()
            } label: {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                    Text("Next week")
                }
            }
            
            if task.repeation != .none {
                Button {
                    task.skip()
                    // FIXME: refresher.refresh.toggle()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                    Text("Skip")
                }
            }
            Divider()

            Menu {
                ForEach(0...3, id: \.self) { priority in
                    Button {
                        if selectedTasksSet.count > 0 && selectedTasksSet.contains(task) {
                            for task in selectedTasksSet {
                                task.priority = priority
                            }
                        } else {
                            task.priority = priority
                        }
                        // FIXME: refresher.refresh.toggle()
                    } label: {
                        HStack {
                            switch priority {
                            case 3:
                                Text("High")
                            case 2:
                                Text("Medium")
                            case 1:
                                Text("Low")
                            default:
                                Text("None")
                            }
                        }
                    }
                    .tag(priority as Int)
                }
            } label: {
                Text("Priority")
            }
            
            Divider()
            
            Button {
                showAddSubtask.toggle()
            } label: {
                Image(systemName: "plus")
                Text("Add subtask")
            }
            
            NavigationLink {
                TasksListView(tasks: task.subtasks != nil ? task.subtasks! : [Todo](),
                              list: list,
                              title: task.name,
                              mainTask: task)
                .id(refresher.refresh)
                .refreshable {
                    refresher.refresh.toggle()
                }
                .environmentObject(showInspector)
                .environmentObject(selectedTasks)
            } label: {
                Image(systemName: "arrow.right")
                Text("Open subtasks")
            }
            
            if let parentTask = task.parentTask {
                NavigationLink {
                    TasksListView(tasks: parentTask.subtasks != nil ? parentTask.subtasks! : [Todo](),
                                  list: list,
                                  title: parentTask.name,
                                  mainTask: parentTask)
                    .id(refresher.refresh)
                    .environmentObject(showInspector)
                    .environmentObject(selectedTasks)
                } label: {
                    Image(systemName: "arrow.left")
                    Text("Open parent task")
                }
            }
            
            Divider()
            
            if let url = URL(string: task.link) {
                Link(destination: url,
                     label: {
                    Image(systemName: "link")
                    Text("Open link")
                })
            }
            
            Divider()
            
            Menu {
                ForEach(projects) { project in
                    Button {
                        if selectedTasksSet.count > 0 && selectedTasksSet.contains(task) {
                            for task in selectedTasksSet {
                                task.project = project
                                task.status = project.getDefaultStatus()
                                project.tasks?.append(task)
                            }
                        } else {
                            task.project = project
                            task.status = project.getDefaultStatus()
                            project.tasks?.append(task)
                        }
                        if list == .inbox {
                            if let index = tasks.firstIndex(of: task) {
                                tasks.remove(at: index)
                            }
                        }
                        // FIXME: refresher.refresh.toggle()
                    } label: {
                        Text(project.name)
                    }
                }
            } label: {
                Text("Move task to project")
            }
            
            if let project = task.project {
                Menu {
                    ForEach(project.getStatuses().sorted(by: { $0.order < $1.order })) { status in
                        Button {
                            task.moveToStatus(status: status,
                                              project: project,
                                              context: modelContext)
                            
                            if status.clearDueDate && (list == .today || list == .tomorrow) {
                                if let index = tasks.firstIndex(of: task) {
                                    tasks.remove(at: index)
                                }
                            }
                            // FIXME: refresher.refresh.toggle()
                        } label: {
                            Text(status.name)
                        }
                    }
                } label: {
                    Text("Move to status")
                }
            }
            
            Divider()
            
            Button {
//                selectedTasksSet.removeAll()
                let newTask = task.copy(modelContext: modelContext)
                
                modelContext.insert(newTask)
                newTask.reconnect()
                
                tasks.append(newTask)
//                selectedTasksSet.insert(newTask)
            } label: {
                Image(systemName: "doc.on.doc")
                Text("Dublicate task")
            }
            
            Button {
                if selectedTasksSet.count > 0 {
                    for task in selectedTasksSet {
                        TasksQuery.deleteTask(context: modelContext,
                                              task: task)
                        if let index = tasks.firstIndex(of: task) {
                            tasks.remove(at: index)
                        }
                    }
                    showInspector.on = false
                    selectedTasksSet.removeAll()
                } else {
                    TasksQuery.deleteTask(context: modelContext,
                                          task: task)
                    if let index = tasks.firstIndex(of: task) {
                        tasks.remove(at: index)
                    }
                }
                // FIXME: refresher.refresh.toggle()
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(Color.red)
                Text("Delete task")
            }
        }
        #if os(macOS)
        .sheet(isPresented: $showAddSubtask) {
            NewTaskView(isVisible: self.$showAddSubtask, list: .inbox, project: nil, mainTask: task,
                        tasks: Binding(
                            get: { task.subtasks ?? [] },
                            set: { task.subtasks = $0 }
                        ))
        }
        #else
        .popover(isPresented: $showAddSubtask, attachmentAnchor: .point(.topLeading), content: {
            NewTaskView(isVisible: self.$showAddSubtask, list: .inbox, project: nil, mainTask: task,
                        tasks: Binding(
                            get: { task.subtasks ?? [] },
                            set: { task.subtasks = $0 }
                        ))
                .frame(minWidth: 200, maxHeight: 180)
                .presentationCompactAdaptation(.popover)
        })
        #endif
    }
}
// swiftlint:enable function_body_length
// swiftlint:enable cyclomatic_complexity
