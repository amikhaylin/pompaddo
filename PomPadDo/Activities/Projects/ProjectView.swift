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
        .toolbar {
            ToolbarItemGroup {
                if project.hasEstimate {
                    Text("Project estimate is \(project.sumEstimateByProject(estimateFactor)) hours")
                        .foregroundStyle(Color.gray)
                }

                if let statuses = project.statuses, statuses.count > 0 {
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
                    }
                    .pickerStyle(.segmented)
                    .accessibility(identifier: "ProjectViewMode")
                }

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
                    showInspector.show.toggle()
                } label: {
                    Label("Show task details", systemImage: "sidebar.trailing")
                }
            }
        }
        .navigationTitle(project.name)
        .onChange(of: selectedTasks.tasks) { _, _ in
            if selectedTasks.tasks.count > 0 {
                showInspector.show = true
            }
        }
        .onChange(of: project) { _, _ in
            selectedTasks.tasks.removeAll()
            showInspector.show = false
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
            }
            if showInspector.show {
                showInspector.show = false
            }
            
            if selectedTasks.tasks.count > 0 {
                selectedTasks.tasks.removeAll()
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var selectedTasks = SelectedTasks()
    @Previewable @StateObject var showInspector = InspectorToggler()
    @Previewable @State var refresher = Refresher()
    let previewer = try? Previewer()
    
    ProjectView(project: previewer!.project)
        .environmentObject(showInspector)
        .environmentObject(selectedTasks)
        .environmentObject(refresher)
        .modelContainer(previewer!.container)
}
