//
//  StatusRowView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 20.05.2024.
//

import SwiftUI
import SwiftData

struct StatusRowView: View {
    @Bindable var status: Status
    @Bindable var project: Project
    
    var body: some View {
        VStack {
            TextField("Name", text: $status.name)
            Toggle("Clear due date", isOn: $status.clearDueDate)
                .toggleStyle(.switch)
            Toggle("Do Completion", isOn: $status.doCompletion)
                .toggleStyle(.switch)
        }
    }
}

#Preview {
    let previewer = try? Previewer()
    guard let firstStatus = previewer!.project.statuses?.first else { return EmptyView() }
            
    return StatusRowView(status: firstStatus,
                         project: previewer!.project)
}
