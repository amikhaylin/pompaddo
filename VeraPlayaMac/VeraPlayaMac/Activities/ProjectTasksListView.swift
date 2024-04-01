//
//  ProjectTasksListView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 27.03.2024.
//

import SwiftUI
import SwiftData

struct ProjectTasksListView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedTasks: Set<Todo>
    @Binding var currentTask: Todo?
    
    @Binding var project: Project?
    @State private var groupsExpanded = true
    
    var body: some View {
        Group {
            if let project = project {
                List(selection: $selectedTasks) {
                    ForEach(project.statuses.sorted(by: { $0.order < $1.order })) { status in
                        DisclosureGroup(status.name, isExpanded: $groupsExpanded) {
                            OutlineGroup(project.tasks.filter({ $0.status == status && $0.parentTask == nil }),
                                         id: \.self,
                                         children: \.subtasks) { task in
                                TaskStringView(task: task)
                                    .draggable(task)
                                    .contextMenu {
                                        Button {
                                            selectedTasks = []
                                            let subtask = Todo(name: "", parentTask: task)
                                            task.subtasks?.append(subtask)
                                            modelContext.insert(subtask)
        
                                            currentTask = subtask
                                        } label: {
                                            Image(systemName: "plus")
                                            Text("Add subtask")
                                        }
                                    }
                            }
                        }
                        .dropDestination(for: Todo.self) { tasks, _ in
                            for task in tasks {
                                task.status = status
                            }
                            return true
                        }
                    }
                }
            } else {
                Text("Select a project")
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    addTaskToProject()
                } label: {
                    Label("Add task to current list", systemImage: "plus")
                }
            }
            
            ToolbarItem {
                Button {
                    deleteItems()
                } label: {
                    Label("Delete task", systemImage: "trash")
                }.disabled(selectedTasks.count == 0)
            }
        }
    }
    
    private func deleteItems() {
        withAnimation {
            for task in selectedTasks {
                modelContext.delete(task)
            }
        }
    }
    
    private func addTaskToProject() {
        withAnimation {
            selectedTasks = []
            if let project = project {
                let task = Todo(name: "",
                                status: project.statuses.sorted(by: { $0.order < $1.order }).first,
                                project: project)
                modelContext.insert(task)
                currentTask = task
            }
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var selectedTasks = Set<Todo>()
        @State var currentTask: Todo?
        @State var project: Project? = previewer.project
        
        return ProjectTasksListView(selectedTasks: $selectedTasks,
                                    currentTask: $currentTask,
                                    project: $project)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
