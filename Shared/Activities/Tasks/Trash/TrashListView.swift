//
//  TrashListView.swift
//  PomPadDo
//
//  Created by Andrey Mikhaylin on 29.12.2025.
//

import SwiftUI
import SwiftData

struct TrashListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @EnvironmentObject var showInspector: InspectorToggler
    @EnvironmentObject var selectedTasks: SelectedTasks
    @Query(filter: TasksQuery.predicateTrash()) var tasks: [Todo]

    @Binding var list: SideBarItem?
    @State private var title: String
    
    @Query var projects: [Project]
    
    @State private var searchText = ""
    
    var searchResults: [Todo] {
        let innerTasks: [Todo]
        innerTasks = tasks.sorted(by: TasksQuery.sortDeleted)
        
        if searchText.isEmpty {
            return innerTasks
        } else {
            return innerTasks.filter { $0.name.localizedStandardContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(selection: $selectedTasks.tasks) {
                ForEach(searchResults.filter({ $0.parentTask == nil || $0.parentTask?.deletionDate == nil }),
                             id: \.self) { task in
                    if task.visibleSubtasks?.isEmpty == false {
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
            }
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search tasks")
        }
        .toolbar {
            ToolbarItemGroup {
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
    }
    
    private func deleteItems() {
        for task in selectedTasks.tasks {
            TasksQuery.eraseTask(context: modelContext, task: task)
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
    
    init(list: Binding<SideBarItem?>, title: String) {
        self._list = list
        self.title = title
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
    
    TrashListView(list: .constant(.inbox),
                  title: "Some list")
    .environmentObject(showInspector)
    .environmentObject(selectedTasks)
    .environmentObject(refresher)
    .environmentObject(timer)
    .environmentObject(focusTask)
    .modelContainer(container!)
}
