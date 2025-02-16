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
    @Bindable var project: Project
    
    var body: some View {
        VStack {
            TextField("Project name", text: $project.name)
            
            HStack {
                Button("OK") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .frame(width: 400, height: 100)
        .padding()
    }
}

#Preview {
    @State var project = Project(name: "ZZZZ")
       
    return EditProjectNameView(project: project)
}
