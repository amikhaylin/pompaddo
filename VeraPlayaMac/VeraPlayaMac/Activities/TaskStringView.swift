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
    var selectedTask: Binding<Todo?>
    
    var body: some View {
        HStack {
            Toggle(isOn: $task.completed, label: {
                Text(task.name)
                    .foregroundStyle(task.completed ? Color.gray : Color.primary)
            })
            .toggleStyle(.checkbox)
            
            Spacer()

            if let project = task.project {
                Text("\(project.name)")
            }
            
            if let subtasksCount = task.subtasks?.count,
                subtasksCount > 0,
               let finished = task.subtasks?.filter( { $0.completed } ),
               let unfinished = task.subtasks?.filter( { $0.completed == false }) {
                let data = [(name: "Unfinished", value: unfinished.count),
                            (name: "Finished", value: finished.count)]
                
                Chart (data, id: \.name) { name, value in
                    SectorMark(angle: .value("Value", value),
                               innerRadius: .ratio(0.6))
                        .foregroundStyle(by: .value("Product category", name))
                }
                .chartLegend(.hidden)
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
        
        @State var selectedTask: Todo?
        
        return TaskStringView(task: previewer.task, selectedTask: $selectedTask)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
