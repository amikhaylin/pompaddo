//
//  SubtasksListView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 09.03.2024.
//

import SwiftUI
import SwiftData

struct SubtasksListView: View {
    var tasks: [Todo]
    var selectedTask: Binding<Todo?>
    
    var body: some View {
        List(tasks, id: \.self, selection: selectedTask) { task in
            TaskStringView(task: task, selectedTask: selectedTask)
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        let tasks: [Todo] = [previewer.task]
        @State var selectedTask: Todo?
        
        return SubtasksListView(tasks: tasks, selectedTask: $selectedTask)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
