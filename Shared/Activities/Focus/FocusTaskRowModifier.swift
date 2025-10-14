//
//  FocusTaskRowModifier.swift
//  PomPadDo
//
//  Created by Andrey Mikhaylin on 25.08.2025.
//
// swiftlint:disable function_body_length
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable type_body_length
// swiftlint:disable file_length

import SwiftUI
import SwiftData

struct FocusTaskRowModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var timer: FocusTimer
    @EnvironmentObject var focusTask: FocusTask
    @Bindable var task: Todo
    @Binding var viewMode: Int
    @State private var showAddSubtask = false
    @Query var groups: [ProjectGroup]
    @State private var renameTask: Todo?
    @Query var projects: [Project]
    
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
                task.setDueDate(dueDate: nil)
            } label: {
                Image(systemName: "clear")
                Text("Clear due date")
            }
            
            Button {
                task.setDueDate(dueDate: Calendar.current.startOfDay(for: Date()))
            } label: {
                Image(systemName: "calendar")
                Text("Today")
            }
            
            Button {
                task.setDueDate(dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())))
            } label: {
                Image(systemName: "sunrise")
                Text("Tomorrow")
            }
            
            Button {
                task.nextWeek()
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
            
            Button {
                focusTask.task = task
                viewMode = 1
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
                        task.priority = priority
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
            
            #if os(iOS)
            Divider()
            
            Button {
                showAddSubtask.toggle()
            } label: {
                Image(systemName: "plus")
                Text("Add subtask")
            }
            #endif
            
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
                        task.project = project
                        task.status = project.getDefaultStatus()
                        project.tasks?.append(task)
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
                        } label: {
                            Text(status.name)
                        }
                    }
                } label: {
                    Text("Move to status")
                }
            }
            
            Divider()
            
            #if os(iOS)
            Button {
                renameTask = task
            } label: {
                Text("Rename task")
            }
            #endif
            
            Button {
                let newTask = task.copy(modelContext: modelContext)
                
                modelContext.insert(newTask)
                newTask.reconnect()
            } label: {
                Image(systemName: "doc.on.doc")
                Text("Duplicate task")
            }
            
            Button {
                if let focus = focusTask.task, task == focus {
                    focusTask.task = nil
                }

                TasksQuery.deleteTask(context: modelContext,
                                          task: task)
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
        .popover(isPresented: $showAddSubtask, attachmentAnchor: .point(.topLeading), content: {
            NewTaskView(isVisible: self.$showAddSubtask, list: .inbox, project: nil, mainTask: task)
                .frame(minWidth: 200, maxHeight: 220)
                .presentationCompactAdaptation(.popover)
        })
        .popover(item: $renameTask, attachmentAnchor: .point(.topLeading), content: { editTask in
            EditTaskNameView(task: editTask)
                .frame(minWidth: 200, maxWidth: 300, maxHeight: 140)
                .presentationCompactAdaptation(.popover)
        })
        #endif
    }
}
// swiftlint:enable function_body_length
// swiftlint:enable cyclomatic_complexity
// swiftlint:enable type_body_length
// swiftlint:enable file_length
