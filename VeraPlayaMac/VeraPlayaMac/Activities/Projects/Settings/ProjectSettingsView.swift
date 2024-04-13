//
//  ProjectSettingsView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 09.04.2024.
//

import SwiftUI
import SwiftData

struct ProjectSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isVisible: Bool
    @Bindable var project: Project
    @State private var selectedStatus: Status?
    
    var body: some View {
        VStack {
            HStack {
                Text("Statuses")
                Spacer()
                Button(action: {
                    let status = Status(name: "Unnamed",
                                        order: project.statuses.count + 1)
                    project.statuses.append(status)
                    modelContext.insert(status)
                }, label: {
                    Image(systemName: "plus")
                })
                .buttonStyle(PlainButtonStyle())
                Button(action: {
                    if let status = selectedStatus, let index = project.statuses.firstIndex(of: status) {
                        project.statuses.remove(at: index)
                        modelContext.delete(status)
                    }
                }, label: {
                    Image(systemName: "trash")
                })
                .buttonStyle(PlainButtonStyle())
            }
            List(project.statuses.sorted(by: { $0.order < $1.order }),
                 selection: $selectedStatus) { status in
                StatusRowView(status: status,
                              project: project)
                .tag(status as Status)
            }
            Spacer()
            Section {
                TextField("Project name", text: $project.name)
                HStack {
                    DatePicker("Review date", selection: $project.reviewDate)
                    
                    Picker("Review days count", selection: $project.reviewDaysCount) {
                        ForEach(1...31, id: \.self) { days in
                            Text("\(days)")
                                .tag(days)
                        }
                    }
                }
            }
            HStack {
                Spacer()
                Button("Close") {
                    self.isVisible = false
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .frame(width: 600, height: 600)
        .padding()
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        @State var project = previewer.project
        @State var isVisible = true
  
        return ProjectSettingsView(isVisible: $isVisible,
                                   project: previewer.project)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
