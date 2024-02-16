//
//  InboxView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 15.02.2024.
//

import SwiftUI
import SwiftData

struct TasksListView: View {
    @Query(filter: #Predicate { task in
        task.project == nil && task.parentTask == nil
    }, sort: [SortDescriptor(\Todo.dueDate)]) var tasks: [Todo]
    
    var body: some View {
        List {
            ForEach(tasks) { task in
                TaskStringView(task: task)
            }
        }
    }
    
    init(parentTask: Todo? = nil) {
        if let parentTask = parentTask {
            _tasks = Query(filter: #Predicate<Todo> { task in
                parentTask.subtasks?.contains(task) == true
            }, sort: [SortDescriptor(\Todo.dueDate)])
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        
        return TasksListView()
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
