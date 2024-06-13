//
//  TasksListView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 15.02.2024.
//

import SwiftUI
import SwiftData

enum CommonTaskListSections: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    case todo = "To do"
    case completed = "Completed"
    
    func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

struct TasksListView: View {
    @Environment(\.modelContext) private var modelContext
    @State var tasks: [Todo]

    @State private var selectedTasks = Set<Todo>()
    
    @State var list: SideBarItem
    @State var title: String
    @State var mainTask: Todo?
    @State private var newTaskIsShowing = false
    
    @State private var groupsExpanded: Set<String> = ["To do", "Completed"]
    
    @State private var showInspector = false
    
    @Query var projects: [Project]
    
    var body: some View {
        NavigationStack {
            List(selection: $selectedTasks) {
                ForEach(CommonTaskListSections.allCases) { section in
                    DisclosureGroup(section.localizedString(), isExpanded: Binding<Bool>(
                        get: { groupsExpanded.contains(section.rawValue) },
                        set: { isExpanding in
                            if isExpanding {
                                groupsExpanded.insert(section.rawValue)
                            } else {
                                groupsExpanded.remove(section.rawValue)
                            }
                        }
                    )) {
                        OutlineGroup(section == .completed ? tasks.filter({ $0.completed }) : tasks.filter({ $0.completed == false }),
                                     id: \.self,
                                     children: \.subtasks) { task in
                            TaskRowView(task: task)
                                .draggable(task)
                                .dropDestination(for: Todo.self) { tasks, _ in
                                    // Attach dropped task as subtask
                                    for dropTask in tasks where dropTask != task {
                                        dropTask.disconnectFromAll()
                                        dropTask.parentTask = task
                                        dropTask.reconnect()
                                    }
                                    return true
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        deleteTask(task: task)
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        if !task.completed {
                                            task.complete(modelContext: modelContext)
                                        } else {
                                            task.reactivate()
                                        }
                                    } label: {
                                        if !task.completed {
                                            Label("Complete", systemImage: "checkmark.square.fill")
                                        } else {
                                            Label("Reactivate", systemImage: "square")
                                        }
                                    }
                                    .tint(.green)
                                }
                                .contextMenu {
                                    Button {
                                        task.dueDate = nil
                                    } label: {
                                        Image(systemName: "clear")
                                        Text("Clear due date")
                                    }
                                    
                                    Button {
                                        task.dueDate = Calendar.current.startOfDay(for: Date())
                                    } label: {
                                        Image(systemName: "calendar")
                                        Text("Today")
                                    }
                                    
                                    Button {
                                        task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                                    } label: {
                                        Image(systemName: "sunrise")
                                        Text("Tomorrow")
                                    }
                                    
                                    if task.repeation != .none {
                                        Button {
                                            task.skip()
                                        } label: {
                                            Image(systemName: "arrow.uturn.forward")
                                            Text("Skip")
                                        }
                                    }
                                    Divider()
                                    
                                    Button {
                                        selectedTasks.removeAll()
                                        let subtask = Todo(name: "", parentTask: task)
                                        task.subtasks?.append(subtask)
                                        modelContext.insert(subtask)
                                        
                                        selectedTasks.insert(subtask)
                                    } label: {
                                        Image(systemName: "plus")
                                        Text("Add subtask")
                                    }
                                    
                                    if let subtasks = task.subtasks, subtasks.count > 0 {
                                        NavigationLink {
                                            TasksListView(tasks: subtasks,
                                                          list: list,
                                                          title: task.name,
                                                          mainTask: task)
                                        } label: {
                                            Image(systemName: "arrow.right")
                                            Text("Open subtasks")
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    Menu {
                                        ForEach(projects) { project in
                                            Button {
                                                task.project = project
                                                task.status = project.getStatuses().sorted(by: { $0.order < $1.order }).first
                                                project.tasks?.append(task)
                                            } label: {
                                                Text(project.name)
                                            }
                                        }
                                    } label: {
                                        Text("Move task to project")
                                    }
                                    
                                    if let project = task.project {
                                        Menu {
                                            ForEach(project.getStatuses().sorted(by: { $0.order < $1.order })) { status in
                                                Button {
                                                    task.moveToStatus(status: status,
                                                                      project: project,
                                                                      context: modelContext)
                                                } label: {
                                                    Text(status.name)
                                                }
                                            }
                                        } label: {
                                            Text("Move to status")
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    Button {
                                        selectedTasks.removeAll()
                                        let newTask = task.copy(modelContext: modelContext)
                                        
                                        modelContext.insert(newTask)
                                        newTask.reconnect()
                                        
                                        selectedTasks.insert(newTask)
                                    } label: {
                                        Image(systemName: "doc.on.doc")
                                        Text("Dublicate task")
                                    }
                                    
                                    Button {
                                        deleteTask(task: task)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(Color.red)
                                        Text("Delete task")
                                    }
                                }
                        }
                    }
                    .dropDestination(for: Todo.self) { tasks, _ in
                        for task in tasks {
                            task.disconnectFromParentTask()
                            task.parentTask = nil
                            setDueDate(task: task)
                            
                            if section == CommonTaskListSections.completed {
                                if !task.completed {
                                    task.complete(modelContext: modelContext)
                                }
                            } else {
                                task.reactivate()
                            }
                        }
                        return true
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    addToCurrentList()
                } label: {
                    Label("Add task to current list", systemImage: "plus")
                }

                Button {
                    deleteItems()
                } label: {
                    Label("Delete task", systemImage: "trash")
                        .foregroundStyle(Color.red)
                }.disabled(selectedTasks.count == 0)
                
                #if os(iOS)
                EditButton()
                #endif

                Button {
                    showInspector.toggle()
                } label: {
                    Label("Show task details", systemImage: "sidebar.trailing")
                }
            }
        }
        .navigationTitle(title)
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
        .onChange(of: selectedTasks) { _, _ in
            if selectedTasks.count > 0 {
                showInspector = true
            }
        }
        .onChange(of: list) { _, _ in
            selectedTasks.removeAll()
            showInspector = false
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
    
    private func deleteTask(task: Todo) {
        withAnimation {
            TasksQuery.deleteTask(context: modelContext,
                                  task: task)
        }
    }
    
    private func setDueDate(task: Todo) {
        switch list {
        case .inbox:
            break
        case .today:
            task.dueDate = Calendar.current.startOfDay(for: Date())
        case .tomorrow:
            task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
        case .projects:
            break
        case .review:
            break
        }
    }

    private func addToCurrentList() {
        withAnimation {
            selectedTasks.removeAll()
            let task = Todo(name: "")
            if let mainTask = mainTask {
                mainTask.subtasks?.append(task)
            } else {
                setDueDate(task: task)
            }
            tasks.append(task)
            modelContext.insert(task)

            selectedTasks.insert(task)
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        let tasks: [Todo] = [previewer.task]
        
        return TasksListView(tasks: tasks, 
                             list: .inbox,
                             title: "Some list")
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
