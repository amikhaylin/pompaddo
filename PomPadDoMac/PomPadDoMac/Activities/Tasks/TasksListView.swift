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
    @EnvironmentObject var refresher: Refresher
    @EnvironmentObject var showInspector: InspectorToggler
    @EnvironmentObject var selectedTasks: SelectedTasks
    @State var tasks: [Todo]

//    @State private var selectedTasks = Set<Todo>()
    
    @State var list: SideBarItem
    @State var title: String
    @State var mainTask: Todo?
    @State private var newTaskIsShowing = false
    
    @State private var groupsExpanded: Set<String> = ["To do", "Completed"]
    
//    @State private var showInspector = false
    
    @Query var projects: [Project]
    
    var body: some View {
        NavigationStack {
            List(selection: $selectedTasks.tasks) {
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
                        ForEach(section == .completed ? tasks.filter({ $0.completed && ($0.parentTask == nil || mainTask != nil) }) : tasks.filter({ $0.completed == false }),
                                     id: \.self) { task in
                            if let subtasks = task.subtasks, subtasks.count > 0 {
                                OutlineGroup([task],
                                             id: \.self,
                                             children: \.subtasks) { maintask in
                                    TaskRowView(task: maintask)
                                        .modifier(TaskRowModifier(task: maintask,
                                                                  selectedTasks: $selectedTasks.tasks,
                                                                  projects: projects,
                                                                  list: list))
                                        .modifier(TaskSwipeModifier(task: maintask, list: list))
                                        .tag(maintask)
                                }
                            } else {
                                TaskRowView(task: task)
                                    .modifier(TaskRowModifier(task: task,
                                                              selectedTasks: $selectedTasks.tasks,
                                                              projects: projects,
                                                              list: list))
                                    .modifier(TaskSwipeModifier(task: task, list: list))
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
                    newTaskIsShowing.toggle()
                } label: {
                    Label("Add task to current list", systemImage: "plus")
                }
                .accessibility(identifier: "AddToCurrentList")
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
                
                #if os(iOS)
                EditButton()
                #endif

                Button {
                    showInspector.on.toggle()
                } label: {
                    Label("Show task details", systemImage: "sidebar.trailing")
                }
                .accessibility(identifier: "ShowTaskDetails")
            }
        }
        .navigationTitle(title)
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
        .onChange(of: selectedTasks.tasks) { _, _ in
            if selectedTasks.tasks.count > 0 && !showInspector.on {
                showInspector.on = true
            }
        }
        .onChange(of: list) { _, _ in
            selectedTasks.tasks.removeAll()
            showInspector.on = false
        }
        #if os(macOS)
        .sheet(isPresented: $newTaskIsShowing) {
            NewTaskView(isVisible: self.$newTaskIsShowing, list: list, project: nil, mainTask: mainTask, tasks: $tasks)
        }
        #else
        .popover(isPresented: $newTaskIsShowing, attachmentAnchor: .point(.topLeading), content: {
            NewTaskView(isVisible: self.$newTaskIsShowing, list: list, project: nil, mainTask: mainTask, tasks: $tasks)
                .frame(minWidth: 200, maxHeight: 180)
                .presentationCompactAdaptation(.popover)
        })
        #endif
    }
    
    private func deleteItems() {
        for task in selectedTasks.tasks {
            TasksQuery.deleteTask(context: modelContext,
                                  task: task)
        }
        showInspector.on = false
        selectedTasks.tasks.removeAll()
        refresher.refresh.toggle()
    }
    
    private func deleteTask(task: Todo) {
        TasksQuery.deleteTask(context: modelContext,
                              task: task)
        refresher.refresh.toggle()
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
