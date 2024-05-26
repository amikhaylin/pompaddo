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
            Picker("Order", selection: $status.order) {
                ForEach(1...project.getStatuses().count, id: \.self) { order in
                    Text("\(order)")
                        .tag(order)
                }
            }
            Toggle("Do Completion", isOn: $status.doCompletion)
                .toggleStyle(.switch)
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        guard let firstStatus = previewer.project.statuses?.first else { return EmptyView() }
            
        @State var status = firstStatus
        @State var project = previewer.project
        
        return StatusRowView(status: firstStatus,
                             project: project)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
