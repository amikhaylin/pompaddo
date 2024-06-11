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
                        ForEach(section == .completed ? tasks.filter({ $0.completed }) : tasks.filter({ $0.completed == false }),
                                     id: \.self) { task in
                            if let subtasks = task.subtasks, subtasks.count > 0 {
                                OutlineGroup([task],
                                             id: \.self,
                                             children: \.subtasks) { maintask in
                                    TaskRowView(task: maintask)
                                        .modifier(TaskRowModifier(task: maintask,
                                                                  modelContext: modelContext,
                                                                  selectedTasks: $selectedTasks,
                                                                  projects: projects,
                                                                  list: list))
                                        .tag(maintask)
                                }
                            } else {
                                TaskRowView(task: task)
                                    .modifier(TaskRowModifier(task: task,
                                                              modelContext: modelContext,
                                                              selectedTasks: $selectedTasks,
                                                              projects: projects,
                                                              list: list))
                                    .tag(task)
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
