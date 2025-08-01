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
    
    enum FocusField: Hashable {
        case groupName
    }
    
    @FocusState private var focusField: FocusField?
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Group name", text: $name)
                    .focused($focusField, equals: .groupName)
                    .task {
                        self.focusField = .groupName
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
                        group.name = name
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    init(group: ProjectGroup) {
        self.group = group
        self.name = group.name
    }
}

#Preview {
    @Previewable @State var group = ProjectGroup(name: "ZZZZ")
       
    return EditProjectGroupView(group: group)
}
