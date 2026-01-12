//
//  TaskRowView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 15.02.2024.
//

import SwiftUI
import SwiftData
import Charts

struct TaskRowView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var focusTask: FocusTask
    @Bindable var task: Todo
    @State private var showingAlertSign = false
    @AppStorage("estimateFactor") private var estimateFactor: Double = 1.7
    var showingProject: Bool
    var nameLineLimit: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TaskCheckBoxView(task: task)
                
                Text(task.name)
                    .foregroundStyle(task.completed ? Color.gray : Color.primary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(nameLineLimit)
            }
            
            HStack {
                Spacer()
                
                if showingProject {
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
                }
                
                if let parentTask = task.parentTask {
                    Text("←\(parentTask.name)")
                        .foregroundStyle(Color.gray)
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                
                if let subtasksCount = task.subtasks?.filter({ $0.deletionDate == nil }).count,
                   subtasksCount > 0,
                   let finished = task.subtasks?.filter({ $0.deletionDate == nil && $0.completed }) {
                    
                    CircularProgressView(progress: CGFloat(subtasksCount == finished.count ? 1.0 : 1.0 / Double(subtasksCount) * Double(finished.count)),
                                         color: .gray,
                                         lineWidth: 2)
                    .frame(width: 15, height: 15)
                    
                    Text("\(subtasksCount == finished.count ? 100 : (100 / subtasksCount) * finished.count) %")
                        .foregroundStyle(Color.gray)
                        .font(.caption)
                }
                
                if !task.link.isEmpty {
                    if let url = URL(string: task.link) {
                        #if os(macOS)
                        Link(destination: url) {
                            Image(systemName: "link.circle.fill")
                        }
                        #else
                        Image(systemName: "link.circle.fill")
                        #endif
                    }
                }
                
                if let focus = focusTask.task, focus == task {
                    Image("tomato")
                        .foregroundStyle(Color.red)
                    if task.tomatoesCount > 0 {
                        Text("\(task.tomatoesCount)")
                            .foregroundStyle(Color.gray)
                            .font(.caption)
                    }
                } else if task.tomatoesCount > 0 {
                    Image("tomato")
                        .foregroundStyle(Color.gray)
                    Text("\(task.tomatoesCount)")
                        .foregroundStyle(Color.gray)
                        .font(.caption)
                }
                
                if task.hasEstimate {
                    Image(systemName: "hourglass")
                        .foregroundStyle(Color.gray)
                    Text("\(task.sumEstimates(estimateFactor))h")
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
                            Text(dueDate, style: .date)
                                .foregroundStyle(dueDate < Calendar.current.startOfDay(for: Date()) ? Color.red : Color.blue)
                                .font(.caption)
                        }
                    }
                }
                
                if let completionDate = task.completionDate {
                    HStack {
                        Text("/")
                        if Calendar.current.isDateInToday(completionDate) {
                            Text("Today")
                        } else if Calendar.current.isDateInTomorrow(completionDate) {
                            Text("Tomorrow")
                        } else if Calendar.current.isDateInYesterday(completionDate) {
                            Text("Yesterday")
                        } else {
                            HStack {
                                Text(completionDate, style: .date)
                            }
                        }
                    }
                    .foregroundStyle(Color.gray)
                    .font(.caption)
                }
                
                if showingAlertSign {
                    Image(systemName: "bell")
                        .foregroundStyle(Color.gray)
                }
            }
            
            if let deadlineDate = task.deadline {
                HStack {
                    Spacer()
                    Image(systemName: "calendar.badge.exclamationmark")
                        .foregroundStyle(Color.gray)
                    if Calendar.current.isDateInToday(deadlineDate) {
                        Text("Today")
                            .foregroundStyle(Color.yellow)
                            .font(.caption)
                    } else if Calendar.current.isDateInTomorrow(deadlineDate) {
                        Text("Tomorrow")
                            .foregroundStyle(Color.yellow)
                            .font(.caption)
                    } else if Calendar.current.isDateInYesterday(deadlineDate) {
                        Text("Yesterday")
                            .foregroundStyle(Color.red)
                            .font(.caption)
                    } else {
                        Text(deadlineDate, style: .date)
                            .foregroundStyle(deadlineDate < Calendar.current.startOfDay(for: Date()) ? Color.red : Color.green)
                            .font(.caption)
                    }
                }
            }
            
            if let deletionDate = task.deletionDate {
                HStack {
                    Spacer()
                    
                    Image(systemName: "trash")
                        .foregroundStyle(Color.gray)
                    Text(deletionDate, style: .date)
                }
            }
        }
        .task {
            showingAlertSign = await NotificationManager.checkTaskHasRequest(task: task)
        }
        .refreshable {
            showingAlertSign = await NotificationManager.checkTaskHasRequest(task: task)
        }
    }
    
    init(task: Todo, showingProject: Bool = true, nameLineLimit: Int = 1) {
        self.task = task
        self.showingProject = showingProject
        self.nameLineLimit = nameLineLimit
    }
}

#Preview {
    let previewer = try? Previewer()
    
    TaskRowView(task: previewer!.task, showingProject: true)
        .modelContainer(previewer!.container)
}
