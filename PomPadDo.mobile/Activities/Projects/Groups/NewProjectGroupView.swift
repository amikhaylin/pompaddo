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
    
    enum FocusField: Hashable {
        case groupName
    }
    
    @FocusState private var focusField: FocusField?
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Group name", text: $groupName)
                    .focused($focusField, equals: .groupName)
                    .task {
                        self.focusField = .groupName
                    }
                    .accessibilityIdentifier("GroupNameField")
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
                        let group = ProjectGroup(name: groupName)
                        modelContext.insert(group)
                    }
                    .accessibility(identifier: "SaveGroup")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var isVisible = true
    let previewer = try? Previewer()
    
    NewProjectGroupView(isVisible: $isVisible)
        .modelContainer(previewer!.container)
}
