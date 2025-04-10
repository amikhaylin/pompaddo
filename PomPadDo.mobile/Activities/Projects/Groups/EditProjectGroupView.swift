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
    
    enum FocusField: Hashable {
        case groupName
    }
    
    @FocusState private var focusField: FocusField?
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Group name", text: $group.name)
                    .focused($focusField, equals: .groupName)
                    .task {
                        self.focusField = .groupName
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
    @Previewable @State var group = ProjectGroup(name: "ZZZZ")
       
    return EditProjectGroupView(group: group)
}
