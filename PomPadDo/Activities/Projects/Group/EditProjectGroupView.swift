//
//  EditProjectGroupView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 07.05.2024.
//

import SwiftUI
import SwiftData

struct EditProjectGroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var group: ProjectGroup
    @State private var name: String
    
    var body: some View {
        VStack {
            TextField("Group name", text: $name)
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                Spacer()
                
                Button("OK") {
                    group.name = name
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .frame(width: 400, height: 100)
        .padding()
    }
    
    init(group: ProjectGroup) {
        self.group = group
        self.name = group.name
    }
}

#Preview {
    @Previewable @State var group = ProjectGroup(name: "ZZZZ")
       
    EditProjectGroupView(group: group)
}
