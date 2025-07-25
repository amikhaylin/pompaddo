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

    @State var list: SideBarItem
    @State var title: String
    @State var mainTask: Todo?
    @State private var newTaskIsShowing = false
    
    @State private var groupsExpanded: Set<String> = ["To do", "Completed"]
    
    @Query var projects: [Project]
    
    @State private var searchText = ""
    
    var searchResults: [Todo] {
        if searchText.isEmpty {
            return tasks
        } else {
            return tasks.filter { $0.name.localizedStandardContains(searchText) }
        }
    }
    
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
                        ForEach(section == .completed ? searchResults.filter({ $0.completed && ($0.parentTask == nil || mainTask != nil) }) : searchResults.filter({ $0.completed == false }),
                                     id: \.self) { task in
                            if let subtasks = task.subtasks, subtasks.count > 0 {
                                OutlineGroup([task],
                                             id: \.self,
                                             children: \.subtasks) { maintask in
                                    TaskRowView(task: maintask)
                                        .modifier(TaskRowModifier(task: maintask,
                                                                  selectedTasksSet: $selectedTasks.tasks,
                                                                  projects: projects,
                                                                  list: list,
                                                                  tasks: $tasks))
                                        .modifier(TaskSwipeModifier(task: maintask, list: list, tasks: $tasks))
                                        .tag(maintask)
                                }
                            } else {
                                TaskRowView(task: task)
                                    .modifier(TaskRowModifier(task: task,
                                                              selectedTasksSet: $selectedTasks.tasks,
                                                              projects: projects,
                                                              list: list,
                                                              tasks: $tasks))
                                    .modifier(TaskSwipeModifier(task: task, list: list, tasks: $tasks))
                                    .tag(task)
                            }
                        }
                    }
                    .dropDestination(for: Todo.self) { tasks, _ in
                        for task in tasks {
                            task.disconnectFromParentTask(modelContext: modelContext)
                            task.parentTask = nil
                            setDueDate(task: task)
                            
                            if section == CommonTaskListSections.completed {
                                if !task.completed {
                                    task.complete(modelContext: modelContext)
                                }
                            } else {
                                task.reactivate(modelContext: modelContext)
                            }
                            try? modelContext.save()
                        }
                        return true
                    }
                }
            }
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search tasks")
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
                    showInspector.show.toggle()
                } label: {
                    Label("Show task details", systemImage: "sidebar.trailing")
                }
                .accessibility(identifier: "ShowTaskDetails")
            }
        }
        .navigationTitle(title)
        .onChange(of: selectedTasks.tasks) { _, _ in
            if selectedTasks.tasks.count > 0 && !showInspector.show {
                showInspector.show = true
            }
        }
        .onChange(of: list) { _, _ in
            if showInspector.show {
                showInspector.show = false
            }
            
            if selectedTasks.tasks.count > 0 {
                selectedTasks.tasks.removeAll()
            }
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
            if let index = tasks.firstIndex(of: task) {
                tasks.remove(at: index)
            }
        }
        if showInspector.show {
            showInspector.show = false
        }
        
        if selectedTasks.tasks.count > 0 {
            selectedTasks.tasks.removeAll()
        }
    }
    
    private func deleteTask(task: Todo) {
        TasksQuery.deleteTask(context: modelContext,
                              task: task)
        if let index = tasks.firstIndex(of: task) {
            tasks.remove(at: index)
        }
    }
    
    private func setDueDate(task: Todo) {
        switch list {
        case .inbox:
            break
        case .today:
            task.setDueDate(modelContext: modelContext, dueDate: Calendar.current.startOfDay(for: Date()))
        case .tomorrow:
            task.setDueDate(modelContext: modelContext, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())))
        case .projects:
            break
        case .review:
            break
        case .alltasks:
            break
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
    let tasks: [Todo] = [previewer.task]
    
    TasksListView(tasks: tasks,
                  list: .inbox,
                  title: "Some list")
    .environmentObject(showInspector)
    .environmentObject(selectedTasks)
    .environmentObject(refresher)
    .environmentObject(timer)
    .environmentObject(focusTask)
    .modelContainer(container!)
}
