//
//  ProjectSettingsView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 20.05.2024.
//

import SwiftUI
import SwiftData

struct ProjectSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var project: Project
    @State private var selectedStatus = Set<Status>()
    
    var body: some View {
        VStack {
            List(project.getStatuses().sorted(by: { $0.order < $1.order }),
                 selection: $selectedStatus) { status in
                StatusRowView(status: status,
                              project: project)
                .tag(status as Status)
            }
             .toolbar {
                 ToolbarItemGroup {
                     Button(action: {
                         let status = Status(name: "Unnamed",
                                             order: project.getStatuses().count + 1)
                         project.statuses?.append(status)
                         modelContext.insert(status)
                         // if project has tasks and statuses count = 1 then connect all tasks to added status
                         if project.getStatuses().count == 1 {
                             for task in project.getTasks() {
                                 task.status = status
                             }
                         }
                     }, label: {
                         Image(systemName: "plus")
                     })
                     
                     Button(action: {
                         for status in selectedStatus {
                             if  let index = project.statuses?.firstIndex(of: status) {
                                 project.statuses?.remove(at: index)
                                 modelContext.delete(status)
                                 
                                 // if status has tasks then move its to first status or nil
                                 for task in project.getTasks().filter({ $0.status == status && $0.parentTask == nil }) {
                                     if let firstStatus = project.getStatuses().sorted(by: { $0.order < $1.order }).first {
                                         task.status = firstStatus
                                     } else {
                                         task.status = nil
                                     }
                                 }
                             }
                         }
                     }, label: {
                         Image(systemName: "trash")
                             .foregroundStyle(Color.red)
                     })

                     EditButton()
                 }
             }
            
            
            Spacer()
            Form {
                TextField("Project name", text: $project.name)

                DatePicker("Review date", selection: $project.reviewDate)
                    
                Picker("Review days count", selection: $project.reviewDaysCount) {
                    ForEach(1...31, id: \.self) { days in
                        Text("\(days)")
                            .tag(days)
                    }
                }
                    
                Toggle("Show estimate", isOn: $project.hasEstimate)
                    .toggleStyle(.switch)
            }
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var project = previewer.project
        @State var isVisible = true
  
        return ProjectSettingsView(project: previewer.project)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
