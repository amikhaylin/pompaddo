//
//  NewTaskView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 14.05.2024.
//

import SwiftUI
import SwiftData

struct NewTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @Binding var isVisible: Bool
    @State var list: SideBarItem
    @State private var taskName = ""
    @State private var link = ""
    @State private var dueToday = false
    @State var project: Project?
    @State var mainTask: Todo?
    @Binding var tasks: [Todo]
    
    enum FocusField: Hashable {
        case taskName
        case link
    }
    
    @FocusState private var focusField: FocusField?
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Add task to ")
                        .font(.headline)
                    Text("\(getListName())")
                        .font(.headline)
                }
                
                TextField("Task name", text: $taskName)
                    .focused($focusField, equals: .taskName)
                    .task {
                        self.focusField = .taskName
                    }
                
                TextField("Link", text: $link)
                    .textContentType(.URL)
                    .focused($focusField, equals: .link)
                
                Toggle("Due today", isOn: $dueToday)
                    .toggleStyle(.switch)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        self.isVisible = false
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("OK") {
                        self.isVisible = false
                        let task = Todo(name: taskName, link: link)
                        if dueToday {
                            task.dueDate = Calendar.current.startOfDay(for: Date())
                        } else if project == nil && mainTask == nil {
                            setDueDate(task: task)
                        }
                        
                        if let mainTask = mainTask {
                            mainTask.subtasks?.append(task)
                        }
                        
                        if let project = project {
                            task.status = project.getDefaultStatus()
                            task.project = project
                        }

                        modelContext.insert(task)
                        task.reconnect()
                        
                        if list != .inbox {
                            tasks.append(task)
                        }
                        // FIXME: if list == .inbox {
//                            refresher.refresh.toggle()
//                        } else {
//                            tasks.append(task)
//                        }
                    }
                }
            }
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
        case .alltasks:
            break
        }
    }
    
    private func getListName() -> String {
        if let mainTask = mainTask {
            return mainTask.name
        }
        
        if let project = project {
            return project.name
        }
        
        return list.name
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        
        @State var isVisible = true
        @State var tasks: [Todo] = []
        
        return NewTaskView(isVisible: $isVisible, list: .inbox, tasks: $tasks)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
