//
//  NewProjectGroupView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 06.05.2024.
//

import SwiftUI
import SwiftData

struct NewProjectGroupView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isVisible: Bool
    @State private var groupName = ""
    
    var body: some View {
        VStack {
            TextField("Group name", text: $groupName)
            
            HStack {
                Button("Cancel") {
                    self.isVisible = false
                }
                .keyboardShortcut(.cancelAction)
                Spacer()
                Button("OK") {
                    self.isVisible = false
                    let group = ProjectGroup(name: groupName)
                    modelContext.insert(group)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .frame(width: 400, height: 100)
        .padding()
    }
}

#Preview {
    @Previewable @State var isVisible = true
    let previewer = try? Previewer()
    
    NewProjectGroupView(isVisible: $isVisible)
        .modelContainer(previewer!.container)
}
