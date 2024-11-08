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
        NavigationView {
            VStack {
                TextField("Project name", text: $projectName)
                
                Toggle(isOn: $createSimpleList) {
                    Text("Create simple list")
                }
                .toggleStyle(.switch)
                .accessibility(identifier: "CreateSimpleList")
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        self.isVisible = false
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("OK") {
                        self.isVisible = false
                        let project = Project(name: projectName)
                        if createSimpleList {
                            project.completedMoving = true
                            project.showStatus = false
                        }
                        modelContext.insert(project)
                        
                        var order = 0
                        for name in DefaultProjectStatuses.allCases {
                            order += 1
                            if !(createSimpleList && name == .progress) {
                                let status = Status(name: name.rawValue,
                                                    order: order,
                                                    doCompletion: name.competion)
                                modelContext.insert(status)
                                project.statuses?.append(status)
                            }
                        }
                    }
                    .accessibility(identifier: "SaveProject")
                }
            }
        }
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
