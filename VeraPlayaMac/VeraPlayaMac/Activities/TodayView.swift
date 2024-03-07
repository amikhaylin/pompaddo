//
//  TodayView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 07.03.2024.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Query(filter: predicate(), sort: [SortDescriptor(\Todo.dueDate)]) var tasks: [Todo]
    var selectedTask: Binding<Todo?>
    
    var body: some View {
        TasksListView(tasks: tasks, selectedTask: selectedTask)
    }
    
    static func predicate() -> Predicate<Todo> {
        let now = Date()
        return #Predicate<Todo> { task in
            if let date = task.dueDate {
                return date <= now
            } else {
                return false
            }
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var selectedTask: Todo?
        
        return TodayView(selectedTask: $selectedTask)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
