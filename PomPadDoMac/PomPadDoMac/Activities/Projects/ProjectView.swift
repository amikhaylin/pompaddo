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
    @State private var selectedTasks = Set<Todo>()
    @State private var showInspector = false
    @AppStorage("estimateFactor") private var estimateFactor: Double = 1.7
    @State private var newTaskIsShowing = false
    
    @Bindable var project: Project
    
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            if project.projectViewMode == 1 {
                BoardView(project: project,
                           selectedTasks: $selectedTasks)
            } else {
                ProjectTasksListView(selectedTasks: $selectedTasks,
                                     project: project)
            }
        }
        .inspector(isPresented: $showInspector) {
            Group {
                if let selectedTask = selectedTasks.first {
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
                }.disabled(selectedTasks.count == 0)
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
                    showInspector.toggle()
                } label: {
                    Label("Show task details", systemImage: "sidebar.trailing")
                }
            }
        }
        .navigationTitle(project.name)
        .onChange(of: selectedTasks) { _, _ in
            if selectedTasks.count > 0 {
                showInspector = true
            }
        }
        .onChange(of: project) { _, _ in
            selectedTasks.removeAll()
            showInspector = false
        }
        #if os(macOS)
        .sheet(isPresented: $newTaskIsShowing) {
            NewTaskView(isVisible: self.$newTaskIsShowing, list: .projects, project: project, mainTask: nil,
                        tasks: Binding(
                            get: { project.tasks ?? [] },
                            set: { project.tasks = $0 }
                        ))
                .environmentObject(refresher)
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
                .environmentObject(refresher)
        })
        #endif
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
        @State var project = previewer.project
        
        return ProjectView(project: previewer.project)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
