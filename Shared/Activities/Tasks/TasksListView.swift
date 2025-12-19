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
    @EnvironmentObject var focusTask: FocusTask
    @Query var tasks: [Todo]

    @Binding var list: SideBarItem?
    @State private var title: String
    @State private var newTaskIsShowing = false
    
    @State private var groupsExpanded: Set<String> = ["To do", "Completed"]
    
    @Query var projects: [Project]
    
    @State private var searchText = ""
    
    var searchResults: [Todo] {
        let innerTasks: [Todo]
        switch list {
        case .inbox:
            innerTasks = tasks.sorted(by: TasksQuery.sortingWithCompleted)
        case .today:
            innerTasks = tasks.filter({ TasksQuery.checkToday(date: $0.completionDate) }).sorted(by: TasksQuery.sortingWithCompleted)
        case .tomorrow:
            innerTasks = tasks.sorted(by: TasksQuery.sortingWithCompleted)
        case .alltasks:
            innerTasks = tasks.sorted(by: TasksQuery.sortingWithCompleted)
        case .deadlines:
            innerTasks = tasks.sorted(by: TasksQuery.sortingDeadlines)
        case .trash:
            innerTasks = tasks.sorted(by: TasksQuery.sortDeleted)
        default:
            innerTasks = tasks.sorted(by: TasksQuery.sortingWithCompleted)
        }
        
        if searchText.isEmpty {
            return innerTasks
        } else {
            return innerTasks.filter { $0.name.localizedStandardContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(selection: $selectedTasks.tasks) {
                ForEach(CommonTaskListSections.allCases) { section in
                    DisclosureGroup(isExpanded: Binding<Bool>(
                        get: { groupsExpanded.contains(section.rawValue) },
                        set: { isExpanding in
                            if isExpanding {
                                groupsExpanded.insert(section.rawValue)
                            } else {
                                groupsExpanded.remove(section.rawValue)
                            }
                        }
                    )) {
                        ForEach(section == .completed ? searchResults.filter({ $0.completed && ($0.parentTask == nil) }) : searchResults.filter({ $0.completed == false }),
                                     id: \.self) { task in
                            if task.hasSubtasks() {
                                OutlineGroup([task],
                                             id: \.self,
                                             children: \.visibleSubtasks) { maintask in
                                        TaskRowView(task: maintask)
                                            .modifier(TaskRowModifier(task: maintask,
                                                                      selectedTasksSet: $selectedTasks.tasks,
                                                                      projects: projects,
                                                                      list: $list))
                                            .modifier(TaskSwipeModifier(task: maintask, list: $list))
                                            .tag(maintask)
                                            .listRowSeparator(.hidden)
                                }
                                .listRowSeparator(.hidden)
                            } else {
                                TaskRowView(task: task)
                                    .modifier(TaskRowModifier(task: task,
                                                              selectedTasksSet: $selectedTasks.tasks,
                                                              projects: projects,
                                                              list: $list))
                                    .modifier(TaskSwipeModifier(task: task, list: $list))
                                    .tag(task)
                                    .listRowSeparator(.hidden)
                            }
                        }
                    } label: {
                        HStack {
                            Text(section.localizedString())
                            
                            Text(" \(section == .completed ? searchResults.filter({ $0.completed && $0.parentTask == nil }).count : searchResults.filter({ $0.completed == false }).count)")
                                .foregroundStyle(Color.gray)
                                .font(.caption)
                        }
                    }
                    .listRowSeparator(.hidden)
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
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search tasks")
        }
        .toolbar {
            ToolbarItemGroup {
                if list != .deadlines && list != .trash {
                    Button {
                        newTaskIsShowing.toggle()
                    } label: {
                        Label("Add task to current list", systemImage: "plus")
                    }
                    .accessibility(identifier: "AddToCurrentList")
                    .help("Add task to current list ⌘⌥I")
                    .keyboardShortcut("i", modifiers: [.command, .option])
#if os(iOS)
                    .sheet(isPresented: $newTaskIsShowing, content: {
                        NewTaskView(isVisible: self.$newTaskIsShowing, list: list!, project: nil, mainTask: nil)
                            .presentationDetents([.height(220)])
                            .presentationDragIndicator(.visible)
                    })
#endif
                }

                if list == .trash {
                    Button {
                        restoreItems()
                    } label: {
                        Label("Undo delete", systemImage: "arrow.uturn.backward")
                    }
                    .disabled(selectedTasks.tasks.count == 0)
                    .help("Undo delete")
                    
                    Button {
                        TasksQuery.emptyTrash(context: modelContext, tasks: tasks)
                    } label: {
                        Label("Empty trash", systemImage: "trash.fill")
                            .foregroundStyle(Color.red)
                    }
                    .help("Empty trash")
                }
                
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
            NewTaskView(isVisible: self.$newTaskIsShowing, list: list!, project: nil, mainTask: nil)
        }
        #endif
    }
    
    private func deleteItems() {
        for task in selectedTasks.tasks {
            if let focus = focusTask.task, task == focus {
                focusTask.task = nil
            }

            if let list = list, list == .trash {
                TasksQuery.eraseTask(context: modelContext, task: task)
            } else {
                TasksQuery.deleteTask(task: task)
            }
        }
        if showInspector.show {
            showInspector.show = false
        }
        
        if selectedTasks.tasks.count > 0 {
            selectedTasks.tasks.removeAll()
        }
    }
    
    private func restoreItems() {
        for task in selectedTasks.tasks {
            TasksQuery.restoreTask(task: task)
        }
    }
        
    private func setDueDate(task: Todo) {
        switch list {
        case .inbox:
            break
        case .today:
            task.setDueDate(dueDate: Calendar.current.startOfDay(for: Date()))
        case .tomorrow:
            task.setDueDate(dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())))
        case .projects:
            break
        case .review:
            break
        case .alltasks:
            break
        default:
            break
        }
    }
    
    init(predicate: Predicate<Todo>, list: Binding<SideBarItem?>, title: String) {
        self._list = list
        self.title = title
        
        self._tasks = Query(filter: predicate)
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
    let _ = Previewer(container!)
    
    TasksListView(predicate: TasksQuery.predicateToday(),
                  list: .constant(.inbox),
                  title: "Some list")
    .environmentObject(showInspector)
    .environmentObject(selectedTasks)
    .environmentObject(refresher)
    .environmentObject(timer)
    .environmentObject(focusTask)
    .modelContainer(container!)
}
