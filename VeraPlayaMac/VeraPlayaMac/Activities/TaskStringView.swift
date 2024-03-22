//
//  TaskStringView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 15.02.2024.
//

import SwiftUI
import SwiftData
import Charts

struct TaskStringView: View {
    @Bindable var task: Todo
    @State private var expandSubtask = false
    
    var body: some View {
        HStack {
            Toggle(isOn: $task.completed) {}
                .toggleStyle(.checkbox)
            
            Text(task.name)
                .foregroundStyle(task.completed ? Color.gray : Color.primary)
            
            Spacer()

            if let project = task.project {
                Text("\(project.name)")
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

#Preview {
    do {
        let previewer = try Previewer()
        
        return TaskStringView(task: previewer.task)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
