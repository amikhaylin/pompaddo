//
//  InboxView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 15.02.2024.
//

import SwiftUI
import SwiftData

struct TasksListView: View {
    var tasks: [Todo]
    
    var body: some View {
        List {
            ForEach(tasks) { task in
                TaskStringView(task: task)
            }
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        let tasks: [Todo] = [previewer.task]
        
        return TasksListView(tasks: tasks)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
