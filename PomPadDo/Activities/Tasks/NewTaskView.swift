//
//  NewTaskView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 27.02.2024.
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
    
    var body: some View {
        VStack {
            Text("Add task to \(getListName())")
                .font(.headline)
            
            TextField("Task name", text: $taskName)
            
            TextField("Link", text: $link)
                .textContentType(.URL)
            
            Toggle("Due today", isOn: $dueToday)
                .toggleStyle(.switch)
            
            HStack {
                Button("Cancel") {
                    self.isVisible = false
                }
                .keyboardShortcut(.cancelAction)
                Spacer()
                
                Button("Save and Add next") {
                    save()
                    taskName = ""
                    link = ""
                }
                
                Spacer()
                Button("OK") {
                    save()
                    self.isVisible = false
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .frame(width: 400, height: 120)
        .padding()
    }
    
    private func save() {
        let task = Todo(name: taskName, link: link)
        if dueToday {
            task.setDueDate(dueDate: Calendar.current.startOfDay(for: Date()))
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
        }
    }
    
    private func getListName() -> String {
        return mainTask?.name ?? project?.name ?? list.name
    }
}

#Preview {
    @Previewable @State var tasks: [Todo] = []
    @Previewable @State var isVisible = true
    let previewer = try? Previewer()
        
    NewTaskView(isVisible: $isVisible, list: .inbox)
        .modelContainer(previewer!.container)
}
