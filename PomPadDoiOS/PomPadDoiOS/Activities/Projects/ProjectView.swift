//
//  ProjectView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 20.05.2024.
//

import SwiftUI

import SwiftUI
import SwiftData

struct ProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedTasks: Set<Todo>
    
    @Bindable var project: Project
    
    @State private var showSettings = false
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if project.projectViewMode == 1 {
                    KanbanView(project: project,
                               selectedTasks: $selectedTasks,
                               path: $path)
                } else {
                    ProjectTasksListView(selectedTasks: $selectedTasks,
                                         project: project,
                                         path: $path)
                }
            }
            .navigationDestination(for: Todo.self) { task in
                EditTaskView(task: task)
            }
            .toolbar {
                if project.hasEstimate {
                    ToolbarItem {
                        // TODO: Change factor in settings
                        Text("Project estimate is \(project.sumEstimateByProject(1.7)) hours")
                            .foregroundStyle(Color.gray)
                    }
                }
                
                ToolbarItem {
                    Picker("View Mode", selection: $project.projectViewMode) {
                        ForEach(0...1, id: \.self) { mode in
                            HStack {
                                switch mode {
                                case 0:
                                    Image(systemName: "list.bullet")
                                case 1:
                                    Image(systemName: "chart.bar")
                                default:
                                    EmptyView()
                                }
                            }
                            .tag(mode as Int)
                        }
                    }.pickerStyle(.segmented)
                }
                
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
                            .foregroundStyle(Color.red)
                    }.disabled(selectedTasks.count == 0)
                }
                
                ToolbarItem {
                    NavigationLink {
                        ProjectSettingsView(project: self.project)
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                
                ToolbarItem {
                    EditButton()
                }
            }
            .navigationTitle(project.name)
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
    
    private func addTaskToProject() {
        withAnimation {
            selectedTasks = []
            let task = Todo(name: "",
                            status: project.getStatuses().sorted(by: { $0.order < $1.order }).first,
                            project: project)
            modelContext.insert(task)
            
//            selectedTasks.insert(task)
            path.append(task)
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var selectedTasks = Set<Todo>()
        @State var project = previewer.project
        
        return ProjectView(selectedTasks: $selectedTasks,
                                    project: previewer.project)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}

