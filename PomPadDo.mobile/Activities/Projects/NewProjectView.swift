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
    
    enum FocusField: Hashable {
        case projectName
    }
    
    @FocusState private var focusField: FocusField?
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Project name", text: $projectName)
                    .focused($focusField, equals: .projectName)
                    .task {
                        self.focusField = .projectName
                    }
                
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
    @Previewable @State var isVisible = true
    let previewer = try? Previewer()
    
    NewProjectView(isVisible: $isVisible)
        .modelContainer(previewer!.container)
}
