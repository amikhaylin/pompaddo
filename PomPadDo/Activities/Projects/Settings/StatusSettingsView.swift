//
//  StatusSettingsView.swift
//  PomPadDo
//
//  Created by Andrey Mikhaylin on 23.05.2025.
//

import SwiftUI
import SwiftData

struct StatusSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @Bindable var status: Status
    @Bindable var project: Project
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    if let index = project.statuses?.firstIndex(of: status) {
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
                        
                        if project.statuses?.count == 0 {
                            project.projectViewMode = 0
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(Color.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            TextField("Name", text: $status.name)
            
            Toggle("Clear due date", isOn: $status.clearDueDate)
                .toggleStyle(.switch)
            Toggle("Do Completion", isOn: $status.doCompletion)
                .toggleStyle(.switch)
            Toggle("Clear Focus", isOn: $status.clearFocus)
                .toggleStyle(.switch)
            
            HStack {
                Spacer()
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .frame(width: 320, height: 170)
        .padding()
    }
}

#Preview {
    @Previewable @State var isVisible = true
    let previewer = try? Previewer()
    
    StatusSettingsView(status: previewer!.projectStatus,
                       project: previewer!.project)
        .modelContainer(previewer!.container)
}
