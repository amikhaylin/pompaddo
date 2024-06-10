//
//  NewProjectView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 21.03.2024.
//

import SwiftUI
import SwiftData

struct NewProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isVisible: Bool
    @State private var projectName = ""
    
    var body: some View {
        VStack {
            TextField("Project name", text: $projectName)
            
            HStack {
                Button("Cancel") {
                    self.isVisible = false
                }
                .keyboardShortcut(.cancelAction)
                Spacer()
                Button("OK") {
                    self.isVisible = false
                    let project = Project(name: projectName)
                    modelContext.insert(project)
                    
                    var order = 0
                    for name in DefaultProjectStatuses.allCases {
                        order += 1
                        let status = Status(name: name.localizedString(),
                                            order: order,
                                            doCompletion: name.competion)
                        modelContext.insert(status)
                        project.statuses?.append(status)
                    }
                    
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .frame(width: 400, height: 100)
        .padding()
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        
        @State var isVisible = true
        
        return NewProjectView(isVisible: $isVisible)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
