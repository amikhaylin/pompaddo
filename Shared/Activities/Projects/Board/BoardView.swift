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
    @EnvironmentObject var focusTask: FocusTask
    @EnvironmentObject var timer: FocusTimer
    @Bindable var project: Project
    
    @State private var searchText = ""
    @State private var statusToEdit: Status?
    
    @State private var newTaskToStatus: Status?
    
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
                                Button {
                                    newTaskToStatus = status
                                } label: {
                                    Image(systemName: "plus")
                                }
                                .buttonStyle(.plain)
                                .help("Add task to status")

                                Spacer()
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
                                Spacer()
                            }
                            List(selection: $selectedTasks.tasks) {
                                ForEach(searchResults
                                    .filter({ $0.status == status && $0.parentTask == nil })
                                    .sorted(by: TasksQuery.sortingWithCompleted),
                                        id: \.self) { task in
                                    if task.visibleSubtasks?.isEmpty == false {
                                        OutlineGroup([task],
                                                     id: \.self,
                                                     children: \.visibleSubtasks) { maintask in
                                            if maintask.deletionDate == nil || task == maintask || task.deletionDate != nil {
                                                TaskRowView(task: maintask, showingProject: false, nameLineLimit: 5)
                                                    .modifier(ProjectTaskModifier(task: maintask,
                                                                                  selectedTasksSet: $selectedTasks.tasks,
                                                                                  project: project,
                                                                                  tasks: Binding(
                                                                                    get: { project.tasks ?? [] },
                                                                                    set: { project.tasks = $0 })))
                                                    .tag(maintask)
                                                    .listRowSeparator(.hidden)
                                            }
                                        }
                                        .listRowSeparator(.hidden)
                                    } else {
                                        TaskRowView(task: task, showingProject: false, nameLineLimit: 5)
                                            .modifier(ProjectTaskModifier(task: task,
                                                                          selectedTasksSet: $selectedTasks.tasks,
                                                                          project: project,
                                                                          tasks: Binding(
                                                                            get: { project.tasks ?? [] },
                                                                            set: { project.tasks = $0 })))
                                            .tag(task)
                                            .listRowSeparator(.hidden)
                                    }
                                }
                            }
                            .cornerRadius(5)
                        }
                        .dropDestination(for: Todo.self) { tasks, _ in
                            for task in tasks {
                                task.moveToStatus(status: status,
                                                  project: project,
                                                  context: modelContext,
                                                  focusTask: focusTask,
                                                  timer: timer)
                                
//                                task.disconnectFromParentTask()
//                                task.parentTask = nil
//                                task.project = project
//                                project.tasks?.append(task)
//                                
//                                if status.doCompletion {
//                                    if !task.completed {
//                                        task.complete(modelContext: modelContext)
//                                    }
//                                } else {
//                                    task.reactivate()
//                                }
//                                
//                                if status.clearDueDate {
//                                    task.setDueDate(dueDate: nil)
//                                }
//                                
//                                task.status = status
                            }
                            return true
                        }
                        .frame(width: status.width)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                            .frame(width: 5)
                            #if os(macOS)
                            .cursor(.resizeLeftRight)
                            #endif
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
        #if os(macOS)
        .sheet(item: $newTaskToStatus, onDismiss: {
            newTaskToStatus = nil
        }, content: { toStatus in
            NewTaskView(isVisible: .constant(true), list: .projects, project: project, mainTask: nil, status: toStatus)
        })
        #else
        .sheet(item: $newTaskToStatus, content: { toStatus in
            NewTaskView(isVisible: .constant(true), list: .projects, project: project, mainTask: nil, status: toStatus)
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
        })
        #endif
    }
    
    private func deleteTask(task: Todo) {
        withAnimation {
            if let focus = focusTask.task, task == focus {
                focusTask.task = nil
            }
            
            TasksQuery.deleteTask(task: task)
        }
    }
    
    private func deleteItems() {
        withAnimation {
            for task in selectedTasks.tasks {
                if let focus = focusTask.task, task == focus {
                    focusTask.task = nil
                }
                
                TasksQuery.deleteTask(task: task)
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
