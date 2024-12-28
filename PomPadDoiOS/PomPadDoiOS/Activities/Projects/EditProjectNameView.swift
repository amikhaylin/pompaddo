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
    @Bindable var project: Project
    
    enum FocusField: Hashable {
        case projectName
    }
    
    @FocusState private var focusField: FocusField?
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Project name", text: $project.name)
                    .focused($focusField, equals: .projectName)
                    .task {
                        self.focusField = .projectName
                    }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("OK") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    @State var project = Project(name: "ZZZZ")
       
    return EditProjectNameView(project: project)
}
