//
//  TaskDetailsView.swift
//  PomPadDoWatch Watch App
//
//  Created by Andrey Mikhaylin on 25.06.2024.
//

import SwiftUI
import SwiftData
import WidgetKit

struct TaskDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var refresher: Refresher
    @Bindable var task: Todo
    @State var list: SideBarItem
    @Binding var tasks: [Todo]
    
    var body: some View {
        ScrollView(.vertical) {
            Text(task.name)
            
            if let project = task.project {
                if let status = task.status, project.showStatus {
                    Text("\(project.name)→\(status.name)")
                        .foregroundStyle(Color.gray)
                        .font(.caption)
                } else {
                    Text("\(project.name)")
                        .foregroundStyle(Color.gray)
                        .font(.caption)
                }
            }
            
            HStack {
                if let subtasksCount = task.subtasks?.count,
                   subtasksCount > 0,
                   let finished = task.subtasks?.filter({ $0.completed }) {
                    
                    CircularProgressView(progress: CGFloat(subtasksCount == finished.count ? 1.0 : 1.0 / Double(subtasksCount) * Double(finished.count)),
                                         color: .gray,
                                         lineWidth: 2)
                    .frame(width: 15, height: 15)
                    
                    Text("\(subtasksCount == finished.count ? 100 : (100 / subtasksCount) * finished.count) %")
                        .foregroundStyle(Color.gray)
                        .font(.caption)
                }

                if !task.link.isEmpty {
                    if URL(string: task.link) != nil {
                        Image(systemName: "link.circle.fill")
                    }
                }
                
                if task.tomatoesCount > 0 {
                    Image(systemName: "target")
                        .foregroundStyle(Color.gray)
                    Text("\(task.tomatoesCount)")
                        .foregroundStyle(Color.gray)
                        .font(.caption)
                }
                
                if let dueDate = task.dueDate {
                    HStack {
                        if task.repeation != .none {
                            Image(systemName: "repeat")
                                .foregroundStyle(Color.gray)
                        }
                        if Calendar.current.isDateInToday(dueDate) {
                            Text("Today")
                                .foregroundStyle(Color.blue)
                                .font(.caption)
                        } else if Calendar.current.isDateInTomorrow(dueDate) {
                            Text("Tomorrow")
                                .foregroundStyle(Color.blue)
                                .font(.caption)
                        } else if Calendar.current.isDateInYesterday(dueDate) {
                            Text("Yesterday")
                                .foregroundStyle(Color.red)
                                .font(.caption)
                        } else {
                            Text(dueDate, format: .dateTime.day().month().year())
                                .foregroundStyle(dueDate < Calendar.current.startOfDay(for: Date()) ? Color.red : Color.blue)
                                .font(.caption)
                        }
                    }
                }
            }
            
            Button {
                if !task.completed {
                    task.complete(modelContext: modelContext)
                } else {
                    task.reactivate(modelContext: modelContext)
                }
                WidgetCenter.shared.reloadAllTimelines()
                presentationMode.wrappedValue.dismiss()
            } label: {
                Label("Complete", systemImage: "checkmark.square")
            }
            
            Button {
                task.setDueDate(modelContext: modelContext, dueDate: Calendar.current.startOfDay(for: Date()))
                if list == .tomorrow {
                    if let index = tasks.firstIndex(of: task) {
                        tasks.remove(at: index)
                    }
                    WidgetCenter.shared.reloadAllTimelines()
                }
                presentationMode.wrappedValue.dismiss()
            } label: {
                Label("Today", systemImage: "calendar")
            }
            
            Button {
                task.setDueDate(modelContext: modelContext, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())))
                if list == .today {
                    if let index = tasks.firstIndex(of: task) {
                        tasks.remove(at: index)
                    }
                    WidgetCenter.shared.reloadAllTimelines()
                }
                presentationMode.wrappedValue.dismiss()
            } label: {
                Label("Tomorrow", systemImage: "sunrise")
            }
        
            Button {
                task.nextWeek(modelContext: modelContext)
                if list == .today || list == .tomorrow {
                    if let index = tasks.firstIndex(of: task) {
                        tasks.remove(at: index)
                    }
                    WidgetCenter.shared.reloadAllTimelines()
                }
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                    Text("Next week")
                }
            }
            
            Button {
                task.setDueDate(modelContext: modelContext, dueDate: nil)
                if list == .today || list == .tomorrow {
                    if let index = tasks.firstIndex(of: task) {
                        tasks.remove(at: index)
                    }
                    WidgetCenter.shared.reloadAllTimelines()
                }
                presentationMode.wrappedValue.dismiss()
            } label: {
                Label("Clear due date", systemImage: "clear")
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
                    WidgetCenter.shared.reloadAllTimelines()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label("Skip", systemImage: "arrow.uturn.forward")
                }
            }
        
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
            }
        
            if let parentTask = task.parentTask {
                NavigationLink {
                    TasksListView(tasks: parentTask.subtasks != nil ? parentTask.subtasks! : [Todo](),
                                  list: list,
                                  title: parentTask.name,
                                  mainTask: parentTask)
                    .id(refresher.refresh)
                } label: {
                    Label("Open parent task", systemImage: "arrow.left")
                }
            }
            
            Button {
                TasksQuery.deleteTask(context: modelContext,
                                      task: task)
                if let index = tasks.firstIndex(of: task) {
                    tasks.remove(at: index)
                    WidgetCenter.shared.reloadAllTimelines()
                }
                presentationMode.wrappedValue.dismiss()
            } label: {
                Label("Delete task", systemImage: "trash")
                    .foregroundStyle(Color.red)
            }
        }
    }
}

#Preview {
    @Previewable @State var refresher = Refresher()
    let previewer = try? Previewer()
    
    TaskDetailsView(task: previewer!.task, list: .today, tasks: .constant([previewer!.task]))
        .environmentObject(refresher)
        .modelContainer(previewer!.container)
}
