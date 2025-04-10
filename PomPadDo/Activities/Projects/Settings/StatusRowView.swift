//
//  StatusRowView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 09.04.2024.
//

import SwiftUI
import SwiftData

struct StatusRowView: View {
    @Bindable var status: Status
    @Bindable var project: Project
    
    var body: some View {
        HStack {
            TextField("Name", text: $status.name)
            
            Spacer()
            Toggle("Clear due date", isOn: $status.clearDueDate)
                .toggleStyle(.switch)
            Toggle("Do Completion", isOn: $status.doCompletion)
                .toggleStyle(.switch)
        }
    }
}

#Preview {
    let previewer = try? Previewer()
   
    StatusRowView(status: previewer!.projectStatus,
                  project: previewer!.project)
        .modelContainer(previewer!.container)
}
