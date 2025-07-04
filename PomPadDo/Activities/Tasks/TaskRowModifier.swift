//
//  TaskRowModifier.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 11.06.2024.
//
// swiftlint:disable function_body_length
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable type_body_length

import SwiftUI
import SwiftData

struct TaskRowModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @EnvironmentObject var showInspector: InspectorToggler
    @EnvironmentObject var selectedTasks: SelectedTasks
    @EnvironmentObject var timer: FocusTimer
    @EnvironmentObject var focusTask: FocusTask
    @Bindable var task: Todo
    @Binding var selectedTasksSet: Set<Todo>
    var projects: [Project]
    var list: SideBarItem
    @Binding var tasks: [Todo]
    @State private var showAddSubtask = false
    @Query var groups: [ProjectGroup]
    @State private var renameTask: Todo?
    
    func body(content: Content) -> some View {
       content
        .draggable(task)
        .dropDestination(for: Todo.self) { tasks, _ in
            // Attach dropped task as subtask
            for dropTask in tasks where dropTask != task {
                dropTask.disconnectFromAll(modelContext: modelContext)
                dropTask.parentTask = task
                dropTask.reconnect(modelContext: modelContext)
            }
            return true
        }
        .contextMenu {
            Button {
                if selectedTasksSet.count > 0 && selectedTasksSet.contains(task) {
                    for task in selectedTasksSet {
                        task.setDueDate(modelContext: modelContext, dueDate: nil)
                        if list == .today || list == .tomorrow {
                            if let index = tasks.firstIndex(of: task) {
                                tasks.remove(at: index)
                            }
                        }
                    }
                } else {
                    if list == .today || list == .tomorrow {
                        if let index = tasks.firstIndex(of: task) {
                            tasks.remove(at: index)
                        }
                    }
                }
            } label: {
                Image(systemName: "clear")
                Text("Clear due date")
            }
            
            Button {
                if selectedTasksSet.count > 0 && selectedTasksSet.contains(task) {
                    for task in selectedTasksSet {
                        task.setDueDate(modelContext: modelContext, dueDate: Calendar.current.startOfDay(for: Date()))
                        if list == .tomorrow {
                            if let index = tasks.firstIndex(of: task) {
                                tasks.remove(at: index)
                            }
                        }
                    }
                } else {
                    task.setDueDate(modelContext: modelContext, dueDate: Calendar.current.startOfDay(for: Date()))
                    if list == .tomorrow {
                        if let index = tasks.firstIndex(of: task) {
                            tasks.remove(at: index)
                        }
                    }
                }
            } label: {
                Image(systemName: "calendar")
                Text("Today")
            }
            
            Button {
                if selectedTasksSet.count > 0 && selectedTasksSet.contains(task) {
                    for task in selectedTasksSet {
                        task.setDueDate(modelContext: modelContext, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())))
                        if list == .today {
                            if let index = tasks.firstIndex(of: task) {
                                tasks.remove(at: index)
                            }
                        }
                    }
                } else {
                    task.setDueDate(modelContext: modelContext, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())))
                    if list == .today {
                        if let index = tasks.firstIndex(of: task) {
                            tasks.remove(at: index)
                        }
                    }
                }
            } label: {
                Image(systemName: "sunrise")
                Text("Tomorrow")
            }
            
            Button {
                if selectedTasksSet.count > 0 && selectedTasksSet.contains(task) {
                    for task in selectedTasksSet {
                        task.nextWeek(modelContext: modelContext)
                        if list == .today || list == .tomorrow {
                            if let index = tasks.firstIndex(of: task) {
                                tasks.remove(at: index)
                            }
                        }
                    }
                } else {
                    task.nextWeek(modelContext: modelContext)
                    if list == .today || list == .tomorrow {
                        if let index = tasks.firstIndex(of: task) {
                            tasks.remove(at: index)
                        }
                    }
                }
            } label: {
                Image(systemName: "calendar.badge.clock")
                Text("Next week")
            }
            
            if task.repeation != .none {
                Button {
                    task.skip(modelContext: modelContext)
                    
                    if list == .today || list == .tomorrow {
                        if let date = task.dueDate {
                            let today = Calendar.current.startOfDay(for: Date())
                            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
                            let future = Calendar.current.date(byAdding: .day, value: 1, to: tomorrow)!

                            if (list == .today && date >= tomorrow) || (list == .tomorrow && date >= future) {
                                if let index = tasks.firstIndex(of: task) {
                                    tasks.remove(at: index)
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                    Text("Skip")
                }
            }

            Divider()
            
            Button {
                focusTask.task = task
                if timer.state == .idle {
                    timer.reset()
                    timer.start()
                } else if timer.state == .paused {
                    timer.resume()
                }
            } label: {
                Image(systemName: "play.fill")
                Text("Start focus")
            }
            
            Divider()
            
            Menu {
                Button {
                    CalendarManager.addToCalendar(title: task.name, eventStartDate: Date.now, eventEndDate: Date.now, isAllDay: true)
                } label: {
                    Image(systemName: "calendar.badge.plus")
                    Text("for Today")
                }

                Button {
                    if let dueDate = task.dueDate {
                        CalendarManager.addToCalendar(title: task.name, eventStartDate: dueDate, eventEndDate: dueDate, isAllDay: true)
                    } else {
                        CalendarManager.addToCalendar(title: task.name, eventStartDate: Date.now, eventEndDate: Date.now, isAllDay: true)
                    }
                } label: {
                    Image(systemName: "calendar.badge.plus")
                    Text("for Due Date")
                }
            } label: {
                Image(systemName: "calendar.badge.plus")
                Text("Add to Calendar")
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
                    try? modelContext.save()
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
                
                Button {
                    task.disconnectFromParentTask(modelContext: modelContext)
                    task.parentTask = nil
                } label: {
                    Text("Extract subtask")
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
                ForEach(projects.sorted(by: ProjectsQuery.defaultSorting)) { project in
                    Button {
                        if selectedTasksSet.count > 0 && selectedTasksSet.contains(task) {
                            for task in selectedTasksSet {
                                task.project = project
                                task.status = project.getDefaultStatus()
                                project.tasks?.append(task)
                                if list == .inbox {
                                    if let index = tasks.firstIndex(of: task) {
                                        tasks.remove(at: index)
                                    }
                                }
                            }
                        } else {
                            task.project = project
                            task.status = project.getDefaultStatus()
                            project.tasks?.append(task)
                            if list == .inbox {
                                if let index = tasks.firstIndex(of: task) {
                                    tasks.remove(at: index)
                                }
                            }
                        }
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
                renameTask = task
            } label: {
                Text("Rename task")
            }
            
            Button {
                let newTask = task.copy(modelContext: modelContext)
                
                modelContext.insert(newTask)
                newTask.reconnect(modelContext: modelContext)
                
                tasks.append(newTask)
            } label: {
                Image(systemName: "doc.on.doc")
                Text("Duplicate task")
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
                    showInspector.show = false
                    selectedTasksSet.removeAll()
                } else {
                    TasksQuery.deleteTask(context: modelContext,
                                          task: task)
                    if let index = tasks.firstIndex(of: task) {
                        tasks.remove(at: index)
                    }
                }
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
        .sheet(item: $renameTask, onDismiss: {
            renameTask = nil
        }, content: { editTask in
            EditTaskNameView(task: editTask)
                .presentationDetents([.height(200)])
        })
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
        .popover(item: $renameTask, attachmentAnchor: .point(.topLeading), content: { editTask in
            EditTaskNameView(task: editTask)
                .frame(minWidth: 200, maxWidth: 300, maxHeight: 100)
                .presentationCompactAdaptation(.popover)
        })
        #endif
    }
}
// swiftlint:enable function_body_length
// swiftlint:enable cyclomatic_complexity
// swiftlint:enable type_body_length
