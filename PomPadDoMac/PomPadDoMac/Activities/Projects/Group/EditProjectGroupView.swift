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
    @Bindable var group: ProjectGroup
    @State private var groupName = ""
    
    var body: some View {
        VStack {
            TextField("Group name", text: $group.name)
            
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
    do {
        @State var group = ProjectGroup(name: "ZZZZ")
        
        return EditProjectGroupView(group: group)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
