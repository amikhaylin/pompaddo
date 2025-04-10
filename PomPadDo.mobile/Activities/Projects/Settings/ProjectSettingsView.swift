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
            List(selection: $selectedStatus) {
                ForEach(project.getStatuses().sorted(by: { $0.order < $1.order }), id: \.self) { status in
                    StatusRowView(status: status,
                                  project: project)
                    .tag(status as Status)
                }
                .onMove(perform: { from, toInt in
                    var statusList = project.getStatuses().sorted(by: { $0.order < $1.order })
                    statusList.move(fromOffsets: from, toOffset: toInt)

                    var order = 0
                    for status in statusList {
                        order += 1
                        status.order = order
                    }
                })
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
                                     if let firstStatus = project.getDefaultStatus() {
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
                
                Toggle("Move completed", isOn: $project.completedMoving)
                    .toggleStyle(.switch)
                
                Toggle("Show status in tasks's lists", isOn: $project.showStatus)
                    .toggleStyle(.switch)
                
                Toggle("Show project in Review", isOn: $project.showInReview)
                    .toggleStyle(.switch)
            }
        }
    }
}

#Preview {
    let previewer = try? Previewer()

    ProjectSettingsView(project: previewer!.project)
        .modelContainer(previewer!.container)
}
