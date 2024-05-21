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
        NavigationView {
            VStack {
                TextField("Project name", text: $projectName)
            }
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
                        modelContext.insert(project)
                        
                        var order = 0
                        for name in DefaultProjectStatuses.allCases {
                            order += 1
                            let status = Status(name: name.rawValue,
                                                order: order,
                                                doCompletion: name.competion)
                            modelContext.insert(status)
                            project.statuses?.append(status)
                        }
                    }
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
