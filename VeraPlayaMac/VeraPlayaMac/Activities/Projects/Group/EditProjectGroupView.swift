//
//  EditProjectGroupView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 07.05.2024.
//

import SwiftUI
import SwiftData

struct EditProjectGroupView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isVisible: Bool
    @Bindable var group: ProjectGroup
    @State private var groupName = ""
    
    var body: some View {
        VStack {
            TextField("Group name", text: $group.name)
            
            HStack {
                Button("OK") {
                    self.isVisible = false
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
        let previewer = try Previewer()
        
        @State var isVisible = true
        @State var group = ProjectGroup(name: "ZZZZ")
        
        return EditProjectGroupView(isVisible: $isVisible, group: group)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
