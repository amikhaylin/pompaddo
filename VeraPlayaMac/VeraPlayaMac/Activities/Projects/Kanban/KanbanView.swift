//
//  KanbanView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 12.04.2024.
//

import SwiftUI
import SwiftData

struct KanbanView: View {
    @Bindable var project: Project
    
    @Binding var selectedTasks: Set<Todo>
    @Binding var currentTask: Todo?
    
    var body: some View {
        HStack {
            ForEach(project.statuses.sorted(by: { $0.order < $1.order })) { status in
                VStack {
                    Text(status.name)
                    List(project.tasks.filter({ $0.status == status && $0.parentTask == nil }), 
                         id: \.self,
                    selection: $selectedTasks) { task in
                        KanbanTaskRowView(task: task, completed: task.completed)
                    }
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }
                .frame(minWidth: 200)
                .padding()
                
            }
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var selectedTasks = Set<Todo>()
        @State var currentTask: Todo?
        @State var project = previewer.project
        
        return KanbanView(project: project,
                            selectedTasks: $selectedTasks,
                            currentTask: $currentTask)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
    
}
