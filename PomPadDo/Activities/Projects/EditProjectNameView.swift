//
//  EditProjectNameView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 03.09.2024.
//

import SwiftUI
import SwiftData

struct EditProjectNameView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var project: Project
    @State private var name: String
    
    var body: some View {
        VStack {
            TextField("Project name", text: $name)
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                .keyboardShortcut(.escape)
                Spacer()
                
                Button("OK") {
                    project.name = name
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .keyboardShortcut(.return)
            }
        }
        .frame(width: 400, height: 100)
        .padding()
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
