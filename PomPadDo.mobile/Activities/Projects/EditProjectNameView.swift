//
//  EditProjectNameView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 03.09.2024.
//

import SwiftUI
import SwiftData

struct EditProjectNameView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var project: Project
    @State private var name: String
    
    enum FocusField: Hashable {
        case projectName
    }
    
    @FocusState private var focusField: FocusField?
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Project name", text: $name)
                    .focused($focusField, equals: .projectName)
                    .task {
                        self.focusField = .projectName
                    }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("OK") {
                        project.name = name
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    init(project: Project) {
        self.project = project
        self.name = project.name
    }
}

#Preview {
    @Previewable @State var project = Project(name: "ZZZZ")
       
    EditProjectNameView(project: project)
}
