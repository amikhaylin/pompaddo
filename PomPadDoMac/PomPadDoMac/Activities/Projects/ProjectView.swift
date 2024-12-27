//
//  ProjectView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 12.04.2024.
//

import SwiftUI
import SwiftData

struct ProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @EnvironmentObject var showInspector: InspectorToggler
    @EnvironmentObject var selectedTasks: SelectedTasks
    @AppStorage("estimateFactor") private var estimateFactor: Double = 1.7
    @State private var newTaskIsShowing = false
    
    @Bindable var project: Project
    
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            if project.projectViewMode == 1 {
                BoardView(project: project)
            } else {
                ProjectTasksListView(project: project)
            }
        }
        .inspector(isPresented: $showInspector.on) {
            Group {
                if let selectedTask = selectedTasks.tasks.first {
                    EditTaskView(task: selectedTask)
                } else {
                    Text("Select a task")
                }
            }
            .inspectorColumnWidth(min: 300, ideal: 300, max: 600)
        }
        .toolbar {
            ToolbarItemGroup {
                if project.hasEstimate {
                    Text("Project estimate is \(project.sumEstimateByProject(estimateFactor)) hours")
                        .foregroundStyle(Color.gray)
                }

                Picker("View Mode", selection: $project.projectViewMode) {
                    ForEach(0...1, id: \.self) { mode in
                        HStack {
                            switch mode {
                            case 0:
                                Image(systemName: "list.bullet")
                            case 1:
                                Image(systemName: "rectangle.split.3x1")
                            default:
                                EmptyView()
                            }
                        }
                        .tag(mode as Int)
                    }
                }.pickerStyle(.segmented)

                Button {
                    newTaskIsShowing.toggle()
                } label: {
                    Label("Add task to current list", systemImage: "plus")
                }
                .help("Add task to current list ⌘⌥I")
                .keyboardShortcut("i", modifiers: [.command, .option])
                
                Button {
                    deleteItems()
                } label: {
                    Label("Delete task", systemImage: "trash")
                        .foregroundStyle(Color.red)
                }.disabled(selectedTasks.tasks.count == 0)
                    .help("Delete task")
                    .keyboardShortcut(.delete)

                #if os(macOS)
                Button {
                    showSettings.toggle()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
                .help("Settings")
                .sheet(isPresented: $showSettings, content: {
                    ProjectSettingsView(isVisible: self.$showSettings,
                                        project: self.project)
                })
                #else
                NavigationLink {
                    ProjectSettingsView(project: self.project)
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
                .help("Settings")
                
                EditButton()
                #endif
                
                Button {
                    showInspector.on.toggle()
                } label: {
                    Label("Show task details", systemImage: "sidebar.trailing")
                }
            }
        }
        .navigationTitle(project.name)
        .onChange(of: selectedTasks.tasks) { _, _ in
            if selectedTasks.tasks.count > 0 {
                showInspector.on = true
            }
        }
        .onChange(of: project) { _, _ in
            selectedTasks.tasks.removeAll()
            showInspector.on = false
        }
        #if os(macOS)
        .sheet(isPresented: $newTaskIsShowing) {
            NewTaskView(isVisible: self.$newTaskIsShowing, list: .projects, project: project, mainTask: nil,
                        tasks: Binding(
                            get: { project.tasks ?? [] },
                            set: { project.tasks = $0 }
                        ))
        }
        #else
        .popover(isPresented: $newTaskIsShowing, attachmentAnchor: .point(.topLeading), content: {
            NewTaskView(isVisible: self.$newTaskIsShowing, list: .projects, project: project, mainTask: nil,
                        tasks: Binding(
                            get: { project.tasks ?? [] },
                            set: { project.tasks = $0 }
                        ))
                .frame(minWidth: 200, maxHeight: 180)
                .presentationCompactAdaptation(.popover)
        })
        #endif
    }
    
    private func deleteItems() {
        withAnimation {
            for task in selectedTasks.tasks {
                TasksQuery.deleteTask(context: modelContext,
                                      task: task)
//                if let index = project.tasks?.firstIndex(of: task) {
//                    project.tasks.remove(at: index)
//                }
            }
            if showInspector.on {
                showInspector.on = false
            }
            
            if selectedTasks.tasks.count > 0 {
                selectedTasks.tasks.removeAll()
            }
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var project = previewer.project
        
        return ProjectView(project: previewer.project)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
