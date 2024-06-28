//
//  TaskDetailsView.swift
//  PomPadDoWatch Watch App
//
//  Created by Andrey Mikhaylin on 25.06.2024.
//

import SwiftUI
import SwiftData

struct TaskDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var refresher: Refresher
    @Bindable var task: Todo
    
    var body: some View {
//        NavigationView {
        ScrollView(.vertical) {
//            VStack(alignment: .leading) {
                Text(task.name)
                
                if let project = task.project {
                    if let status = task.status, project.showStatus {
                        Text("\(project.name)>\(status.name)")
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
                        task.reactivate()
                    }
                    refresher.refresh.toggle()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label("Complete", systemImage: "checkmark.square")
                }
                
                Button {
                    let date = Calendar.current.startOfDay(for: Date())
                    task.dueDate = date
                    refresher.refresh.toggle()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label("Today", systemImage: "calendar")
                }
                
                Button {
                    let date = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                    task.dueDate = date
                    refresher.refresh.toggle()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label("Tomorrow", systemImage: "sunrise")
                }
                
                Button {
                    task.dueDate = nil
                    refresher.refresh.toggle()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label("Clear due date", systemImage: "clear")
                }
                
                Button {
                    task.skip()
                    refresher.refresh.toggle()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label("Skip", systemImage: "arrow.uturn.forward")
                }
                
                Button {
                    TasksQuery.deleteTask(context: modelContext,
                                          task: task)
                    refresher.refresh.toggle()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label("Delete task", systemImage: "trash")
                        .foregroundStyle(Color.red)
                }
            }
        }
//    }
}

#Preview {
    do {
        let previewer = try Previewer()
        
        return TaskDetailsView(task: previewer.task)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
