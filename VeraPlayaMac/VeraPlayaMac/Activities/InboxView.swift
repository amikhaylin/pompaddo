//
//  InboxView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 17.02.2024.
//

import SwiftUI
import SwiftData

struct InboxView: View {
    @Query(filter: #Predicate { task in
        task.project == nil && task.parentTask == nil
    }, sort: [SortDescriptor(\Todo.dueDate)]) var tasks: [Todo]
    
    var body: some View {
        TasksListView(tasks: tasks)
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        
        return InboxView()
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
