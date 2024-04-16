//
//  TaskRowView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 15.02.2024.
//

import SwiftUI
import SwiftData
import Charts

struct TaskRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var task: Todo
    @State private var completed: Bool
    
    var body: some View {
        ScrollView(.horizontal) {
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
                
                Text(task.name)
                    .foregroundStyle(task.completed ? Color.gray : Color.primary)
                
                Spacer()
                
                if !task.link.isEmpty {
                    if let url = URL(string: task.link) {
                        Link(destination: url) {
                            Image(systemName: "link.circle.fill")
                        }
                    }
                }
                
                if let project = task.project {
                    Text("\(project.name)")
                        .foregroundStyle(Color.gray)
                        .font(.caption)
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
        }
    }
    
    init(task: Todo, completed: Bool) {
        self.task = task
        self.completed = completed
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        
        return TaskRowView(task: previewer.task, completed: false)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
