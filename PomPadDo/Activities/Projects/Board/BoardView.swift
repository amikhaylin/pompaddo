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
    @EnvironmentObject var showInspector: InspectorToggler
    @EnvironmentObject var selectedTasks: SelectedTasks
    @Bindable var project: Project
    
    @State private var searchText = ""
    @State private var statusToEdit: Status?
    
    var searchResults: [Todo] {
        if searchText.isEmpty {
            return project.getTasks()
        } else {
            return project.getTasks().filter { $0.name.localizedStandardContains(searchText) }
        }
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                
                ForEach(project.getStatuses().sorted(by: { $0.order < $1.order })) { status in
                    HStack {
                        VStack {
                            HStack {
                                #if os(macOS)
                                Button {
                                    statusToEdit = status
                                } label: {
                                    Text(status.name == "" ? "Unnamed" : status.name)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .sheet(item: $statusToEdit, content: { status in
                                    StatusSettingsView(status: status,
                                                        project: self.project)
                                })
                                #else
                                NavigationLink {
                                    StatusSettingsView(status: status,
                                                       project: self.project)
                                } label: {
                                    Text(status.name == "" ? "Unnamed" : status.name)
                                }
                                .buttonStyle(PlainButtonStyle())
                                #endif
                                
                                Text(" \(project.getTasks().filter({ $0.status == status && $0.parentTask == nil }).count)")
                                    .foregroundStyle(Color.gray)
                                    .font(.caption)
                            }
                            List(selection: $selectedTasks.tasks) {
                                ForEach(searchResults
                                    .filter({ $0.status == status && $0.parentTask == nil })
                                    .sorted(by: TasksQuery.defaultSorting),
                                        id: \.self) { task in
                                    if let subtasks = task.subtasks, subtasks.count > 0 {
                                        OutlineGroup([task],
                                                     id: \.self,
                                                     children: \.subtasks) { maintask in
                                            TaskRowView(task: maintask, showingProject: false, nameLineLimit: 5)
                                                .modifier(ProjectTaskModifier(task: maintask,
                                                                              selectedTasksSet: $selectedTasks.tasks,
                                                                              project: project,
                                                                              tasks: Binding(
                                                                                get: { project.tasks ?? [] },
                                                                                set: { project.tasks = $0 })))
                                                .tag(maintask)
                                        }
                                    } else {
                                        TaskRowView(task: task, showingProject: false, nameLineLimit: 5)
                                            .modifier(ProjectTaskModifier(task: task,
                                                                          selectedTasksSet: $selectedTasks.tasks,
                                                                          project: project,
                                                                          tasks: Binding(
                                                                            get: { project.tasks ?? [] },
                                                                            set: { project.tasks = $0 })))
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
                                
                                if status.clearDueDate {
                                    task.dueDate = nil
                                }
                                
                                task.status = status
                            }
                            return true
                        }
                        .frame(width: status.width)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                            .frame(width: 5)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        let newWidth = status.width + gesture.translation.width
                                        status.width = max(newWidth, 300)
                                    }
                            )
                    }
                }
            }
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search tasks")
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
            for task in selectedTasks.tasks {
                TasksQuery.deleteTask(context: modelContext,
                                      task: task)
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var selectedTasks = SelectedTasks()
    @Previewable @StateObject var showInspector = InspectorToggler()
    @Previewable @State var refresher = Refresher()
    @Previewable @StateObject var timer = FocusTimer(workInSeconds: 1500,
                                                     breakInSeconds: 300,
                                                     longBreakInSeconds: 1200,
                                                     workSessionsCount: 4)
                              
    @Previewable @StateObject var focusTask = FocusTask()
    @Previewable @State var container = try? ModelContainer(for: Schema([
                                                            ProjectGroup.self,
                                                            Status.self,
                                                            Todo.self,
                                                            Project.self
                                                        ]),
                                                       configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    let previewer = Previewer(container!)
    
    BoardView(project: previewer.project)
        .modelContainer(container!)
        .environmentObject(showInspector)
        .environmentObject(selectedTasks)
        .environmentObject(refresher)
        .environmentObject(timer)
        .environmentObject(focusTask)
}
