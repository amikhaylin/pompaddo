//
//  BoardView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 12.04.2024.
//

import SwiftUI
import SwiftData

struct BoardView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var project: Project
    
    @Binding var selectedTasks: Set<Todo>
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                
                ForEach(project.getStatuses().sorted(by: { $0.order < $1.order })) { status in
                    VStack {
                        Text(status.name)
                        List(selection: $selectedTasks) {
                            ForEach(project.getTasks()
                                        .filter({ $0.status == status && $0.parentTask == nil })
                                        .sorted(by: TasksQuery.defaultSorting),
                                    id: \.self) { task in
                                if let subtasks = task.subtasks, subtasks.count > 0 {
                                    OutlineGroup([task],
                                                 id: \.self,
                                                 children: \.subtasks) { maintask in
                                        TaskRowView(task: maintask, showingProject: false, nameLineLimit: 5)
                                            .modifier(ProjectTaskModifier(task: maintask,
                                                                          selectedTasks: $selectedTasks,
                                                                          project: project))
                                            .tag(maintask)
                                    }
                                } else {
                                    TaskRowView(task: task, showingProject: false, nameLineLimit: 5)
                                        .modifier(ProjectTaskModifier(task: task,
                                                                      selectedTasks: $selectedTasks,
                                                                      project: project))
                                        .tag(task)
                                }
                            }
                            .listRowSeparator(.visible)
                        }
                        .cornerRadius(5)
                    }
                    .dropDestination(for: Todo.self) { tasks, _ in
                        for task in tasks {
                            task.disconnectFromParentTask()
                            task.parentTask = nil
                            task.project = project
                            project.tasks?.append(task)
                            
                            if status.doCompletion {
                                if !task.completed {
                                    task.complete(modelContext: modelContext)
                                }
                            } else {
                                task.reactivate()
                            }
                            task.status = status
                        }
                        return true
                    }
                    .frame(minWidth: 200, idealWidth: 300)
                }
            }
        }
        .padding()
    }
    
    private func deleteTask(task: Todo) {
        withAnimation {
            TasksQuery.deleteTask(context: modelContext,
                                  task: task)
        }
    }
    
    private func deleteItems() {
        withAnimation {
            for task in selectedTasks {
                TasksQuery.deleteTask(context: modelContext,
                                      task: task)
            }
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var selectedTasks = Set<Todo>()
        @State var project = previewer.project
        
        return BoardView(project: project,
                            selectedTasks: $selectedTasks)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
    
}
