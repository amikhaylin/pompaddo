//
//  NewTaskView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 27.02.2024.
//

import SwiftData
import SwiftUI

struct NewTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var refresher: Refresher
    @Binding var isVisible: Bool
    @State var list: SideBarItem
    @State private var taskName = ""
    @State private var link = ""
    @State var project: Project?
    @State var mainTask: Todo?
    @State var status: Status?
    @State private var dueDateType: DueDateType = .none
    @State private var priority: Int = 0
    @State private var dueDate = Date()

    var body: some View {
        VStack {
            Text("Add task to \(getListName())")
                .font(.headline)

            TextField("Task name", text: $taskName)
                .accessibilityIdentifier("TaskName")

            TextField("Link", text: $link)
                .textContentType(.URL)
            
            HStack {
                if list != .today && list != .tomorrow {
                    Menu {
                        ForEach(DueDateType.allCases, id: \.self) { dueType in
                            Button {
                                dueDateType = dueType
                            } label: {
                                switch dueType {
                                case .none:
                                    Image(systemName: "xmark.square")
                                    Text("None")
                                case .today:
                                    Image(systemName: "calendar")
                                    Text("Today")
                                case .tomorrow:
                                    Image(systemName: "sunrise")
                                    Text("Tomorrow")
                                case .nextweek:
                                    Image(systemName: "calendar.badge.clock")
                                    Text("Next week")
                                case .custom:
                                    Image(systemName: "calendar")
                                    Text("Custom")
                                }
                            }
                        }
                    } label: {
                        switch dueDateType {
                        case .none:
                            Image(systemName: "calendar")
                            Text("Due Date")
                        case .today:
                            Image(systemName: "calendar")
                            Text("Today")
                        case .tomorrow:
                            Image(systemName: "sunrise")
                            Text("Tomorrow")
                        case .nextweek:
                            Image(systemName: "calendar.badge.clock")
                            Text("Next week")
                        case .custom:
                            Image(systemName: "calendar")
                            Text("Custom")
                        }
                    }
                    
                    if dueDateType == .custom {
                        DatePicker("",
                                   selection: $dueDate,
                                   displayedComponents: .date)
                    }
                }
                
                Spacer()
                
                Menu {
                    ForEach(0...3, id: \.self) { pri in
                        Button {
                            priority = pri
                        } label: {
                            switch pri {
                            case 3:
                                Text("High")
                            case 2:
                                Text("Medium")
                            case 1:
                                Text("Low")
                            default:
                                Text("None")
                            }
                        }
                    }
                } label: {
                    Image(systemName: "flag")
                    switch priority {
                    case 3:
                        Text("High")
                    case 2:
                        Text("Medium")
                    case 1:
                        Text("Low")
                    default:
                        Text("Priority")
                    }
                }
            }

            HStack {
                Button("Cancel") {
                    self.isVisible = false
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button {
                    save()
                    taskName = ""
                    link = ""
                } label: {
                    Image(systemName: "plus.square.on.square")
                }
                .help("Save and Add next")
                
                Button("OK") {
                    save()
                    self.isVisible = false
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .accessibilityIdentifier("SaveTask")
            }
        }
        .frame(width: 400, height: 140)
        .padding()
    }

    private func save() {
        let task = Todo(name: taskName, link: link)
        if dueDateType != .none {
            switch dueDateType {
            case .today:
                task.setDueDate(dueDate: Calendar.current.startOfDay(for: Date()))
            case .tomorrow:
                task.setDueDate(dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())))
            case .nextweek:
                task.nextWeek()
            case .custom:
                task.setDueDate(dueDate: dueDate)
            default:
                break
            }
        } else if project == nil && mainTask == nil {
            setDueDate(task: task)
        }
        
        task.priority = priority

        if let mainTask = mainTask {
            mainTask.subtasks?.append(task)
        }

        if let project = project {
            if let status = status {
                task.status = status
            } else {
                task.status = project.getDefaultStatus()
            }
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
            task.setDueDate(
                dueDate: Calendar.current.date(
                    byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())))
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

    private func getListName() -> String {
        return mainTask?.name ?? status?.name ?? project?.name ?? list.name
    }
}

#Preview {
    @Previewable @State var tasks: [Todo] = []
    @Previewable @State var isVisible = true
    let previewer = try? Previewer()

    NewTaskView(isVisible: $isVisible, list: .inbox)
        .modelContainer(previewer!.container)
}
