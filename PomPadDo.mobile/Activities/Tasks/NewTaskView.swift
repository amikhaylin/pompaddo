//
//  NewTaskView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 14.05.2024.
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
    @State private var dueToday = false
    @State var project: Project?
    @State var mainTask: Todo?
    @State var status: Status?

    enum FocusField: Hashable {
        case taskName
        case link
    }

    @FocusState private var focusField: FocusField?

    var body: some View {
        NavigationView {
            VStack {
                Text("Add task to \(getListName())")
                    .font(.headline)

                TextField("Task name", text: $taskName)
                    .accessibilityIdentifier("TaskName")
                    .focused($focusField, equals: .taskName)
                    .task {
                        self.focusField = .taskName
                    }

                TextField("Link", text: $link)
                    .textContentType(.URL)
                    .focused($focusField, equals: .link)

                Toggle("Due today", isOn: $dueToday)
                    .toggleStyle(.switch)
                    .accessibilityIdentifier("DueToday")
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        self.isVisible = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
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
                    .accessibilityIdentifier("SaveTask")
                }
            }
        }
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
    @Previewable @State var refresher = Refresher()
    let previewer = try? Previewer()

    return NewTaskView(isVisible: $isVisible, list: .inbox)
        .environmentObject(refresher)
        .modelContainer(previewer!.container)
}
