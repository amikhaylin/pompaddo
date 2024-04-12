//
//  ProjectView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 12.04.2024.
//

import SwiftUI
import SwiftData

struct ProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedTasks: Set<Todo>
    @Binding var currentTask: Todo?
    
    @Bindable var project: Project
    
    @State private var showSettings = false
    
    @State private var projectViewMode = 0
    
    var body: some View {
        Group {
            if projectViewMode == 1 {
                KanbanView(project: project,
                           selectedTasks: $selectedTasks,
                           currentTask: $currentTask)
            } else {
                ProjectTasksListView(selectedTasks: $selectedTasks,
                                     currentTask: $currentTask,
                                     project: project)
            }
        }
        .toolbar {
            ToolbarItem {
                Picker("View Mode", selection: $projectViewMode) {
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
                }.disabled(selectedTasks.count == 0)
            }
            
            ToolbarItem {
                Button {
                    showSettings.toggle()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showSettings, content: {
            ProjectSettingsView(isVisible: self.$showSettings,
                                project: self.project)
        })
    }
    
    private func deleteItems() {
        withAnimation {
            for task in selectedTasks {
                task.disconnect()
                modelContext.delete(task)
            }
        }
    }
    
    private func addTaskToProject() {
        withAnimation {
            selectedTasks = []
            let task = Todo(name: "",
                            status: project.statuses.sorted(by: { $0.order < $1.order }).first,
                            project: project)
            modelContext.insert(task)
            currentTask = task
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var selectedTasks = Set<Todo>()
        @State var currentTask: Todo?
        @State var project = previewer.project
        
        return ProjectView(selectedTasks: $selectedTasks,
                                    currentTask: $currentTask,
                                    project: previewer.project)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
