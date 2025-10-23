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
    @State private var createSimpleList = false
    
    var body: some View {
        VStack {
            TextField("Project name", text: $projectName)
                .accessibilityIdentifier("ProjectNameField")
            
            Toggle(isOn: $createSimpleList) {
                Text("Create simple list")
            }
            .toggleStyle(.switch)
            .accessibility(identifier: "CreateSimpleList")
            
            HStack {
                Button("Cancel") {
                    self.isVisible = false
                }
                .keyboardShortcut(.cancelAction)
                Spacer()
                Button("OK") {
                    self.isVisible = false
                    let project = Project(name: projectName)
                    if createSimpleList {
                        project.completedMoving = true
                        project.showStatus = false
                    }
                    modelContext.insert(project)
                    
                    if !createSimpleList {
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
                }
                .keyboardShortcut(.defaultAction)
                .accessibilityIdentifier("SaveProject")
            }
        }
        .frame(width: 400, height: 100)
        .padding()
    }
}

#Preview {
    @Previewable @State var isVisible = true
    let previewer = try? Previewer()
        
    NewProjectView(isVisible: $isVisible)
        .modelContainer(previewer!.container)
}
