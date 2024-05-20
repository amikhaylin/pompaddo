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
    @Bindable var task: Todo
    @State private var showingAlertSign = false
    var showingProject: Bool
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                HStack {
                    TaskCheckBoxView(task: task)
                        .foregroundColor(.gray)
                    
                    switch task.priority {
                    case 1:
                        Image(systemName: "flag.fill")
                            .foregroundStyle(Color.blue)
                    case 2:
                        Image(systemName: "flag.fill")
                            .foregroundStyle(Color.yellow)
                    case 3:
                        Image(systemName: "flag.fill")
                            .foregroundStyle(Color.red)
                    default:
                        EmptyView()
                    }
                    
                    NavigationLink {
                        EditTaskView(task: task)
                    } label: {
                        Text(task.name)
                            .foregroundStyle(task.completed ? Color.gray : Color.primary)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }


                    
                }
                HStack {
                    Spacer()
                    
                    if !task.link.isEmpty {
                        if let url = URL(string: task.link) {
                            Link(destination: url) {
                                Image(systemName: "link.circle.fill")
                            }
                        }
                    }
                    
                    if showingProject {
                        if let project = task.project {
                            Text("\(project.name)")
                                .foregroundStyle(Color.gray)
                                .font(.caption)
                        }
                    }
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
                    
                    if task.tomatoesCount > 0 {
                        Image(systemName: "target")
                            .foregroundStyle(Color.gray)
                        Text("\(task.tomatoesCount)")
                            .foregroundStyle(Color.gray)
                            .font(.caption)
                    }
                    
                    if task.hasEstimate {
                        Image(systemName: "pencil.and.list.clipboard")
                            .foregroundStyle(Color.gray)
                        // TODO: Change factor in settings
                        Text("\(task.sumEstimates(1.7))h")
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
                    
                    if showingAlertSign {
                        Image(systemName: "bell")
                            .foregroundStyle(Color.gray)
                    }
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
    
    init(task: Todo, showingProject: Bool = true) {
        self.task = task
        self.showingProject = showingProject
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        
        return TaskRowView(task: previewer.task, showingProject: true)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
