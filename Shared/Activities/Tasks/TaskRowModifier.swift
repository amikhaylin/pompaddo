//
//  TaskRowModifier.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 11.06.2024.
//
// swiftlint:disable function_body_length
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable type_body_length
// swiftlint:disable file_length

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
    @Binding var list: SideBarItem?
    @State private var showAddSubtask = false
    @Query var groups: [ProjectGroup]
    @State private var renameTask: Todo?
    
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
            if let list = list, list == .trash {
                Button {
                    if selectedTasksSet.count > 0 && selectedTasksSet.contains(task) {
                        for task in selectedTasksSet {
                            TasksQuery.restoreTask(task: task)
                        }
                    } else {
                        TasksQuery.restoreTask(task: task)
                    }
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                    Text("Undo delete")
                }
            } else {
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
                
                Button {
                    if selectedTasksSet.count > 0 && selectedTasksSet.contains(task) {
                        for task in selectedTasksSet {
                            task.setDueDate(dueDate: nil)
                        }
                    } else {
                        task.setDueDate(dueDate: nil)
                    }
                } label: {
                    Image(systemName: "xmark.square")
                    Text("Clear due date")
                }
                
                Button {
                    if selectedTasksSet.count > 0 && selectedTasksSet.contains(task) {
                        for task in selectedTasksSet {
                            task.setDueDate(dueDate: Calendar.current.startOfDay(for: Date()))
                        }
                    } else {
                        task.setDueDate(dueDate: Calendar.current.startOfDay(for: Date()))
                    }
                } label: {
                    Image(systemName: "calendar")
                    Text("Today")
                }
                
                Button {
                    if selectedTasksSet.count > 0 && selectedTasksSet.contains(task) {
                        for task in selectedTasksSet {
                            task.setDueDate(dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())))
                        }
                    } else {
                        task.setDueDate(dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())))
                    }
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
                } label: {
                    Image(systemName: "calendar.badge.clock")
                    Text("Next week")
                }
                
                if task.repeation != .none {
                    Button {
                        task.skip()
                    } label: {
                        Image(systemName: "arrow.uturn.forward")
                        Text("Skip")
                    }
                }
                
                Divider()
                
                if let focus = focusTask.task, focus == task {
                    Button {
                        timer.reset()
                        if timer.mode == .pause || timer.mode == .longbreak {
                            timer.skip()
                        }
                        focusTask.task = nil
                    } label: {
                        Image(systemName: "stop.fill")
                        Text("Stop focus")
                    }
                } else {
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
                    Image(systemName: "flag")
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
                    SubtasksListView(list: $list,
                                     title: task.name,
                                     mainTask: task)
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
                        SubtasksListView(list: $list,
                                         title: parentTask.name,
                                         mainTask: parentTask)
                        .environmentObject(showInspector)
                        .environmentObject(selectedTasks)
                    } label: {
                        Image(systemName: "arrow.left")
                        Text("Open parent task")
                    }
                    
                    Button {
                        task.disconnectFromParentTask()
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
                                }
                            } else {
                                task.project = project
                                task.status = project.getDefaultStatus()
                                project.tasks?.append(task)
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
                                                  context: modelContext,
                                                  focusTask: focusTask,
                                                  timer: timer)
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
                    newTask.reconnect()
                } label: {
                    Image(systemName: "doc.on.doc")
                    Text("Duplicate task")
                }
            }
            
            Button {
                if selectedTasksSet.count > 0 {
                    for task in selectedTasksSet {
                        if let focus = focusTask.task, task == focus {
                            focusTask.task = nil
                        }

                        if let list = list, list == .trash {
                            TasksQuery.eraseTask(context: modelContext, task: task)
                        } else {
                            TasksQuery.deleteTask(task: task)
                        }
                    }
                    showInspector.show = false
                    selectedTasksSet.removeAll()
                } else {
                    if let focus = focusTask.task, task == focus {
                        focusTask.task = nil
                    }

                    if let list = list, list == .trash {
                        TasksQuery.eraseTask(context: modelContext, task: task)
                    } else {
                        TasksQuery.deleteTask(task: task)
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
            NewTaskView(isVisible: self.$showAddSubtask, list: .inbox, project: nil, mainTask: task)
        }
        .sheet(item: $renameTask, onDismiss: {
            renameTask = nil
        }, content: { editTask in
            EditTaskNameView(task: editTask)
                .presentationDetents([.height(200)])
        })
        #else
        .sheet(isPresented: $showAddSubtask, content: {
            NewTaskView(isVisible: self.$showAddSubtask, list: .inbox, project: nil, mainTask: task)
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
        })
        .sheet(item: $renameTask, onDismiss: {
            renameTask = nil
        }, content: { editTask in
            EditTaskNameView(task: editTask)
                .presentationDetents([.height(140)])
                .presentationDragIndicator(.visible)
        })
        #endif
    }
}
// swiftlint:enable function_body_length
// swiftlint:enable cyclomatic_complexity
// swiftlint:enable type_body_length
// swiftlint:enable file_length
