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
        NavigationView {
            VStack {
                TextField("Group name", text: $group.name)
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
    @State var group = ProjectGroup(name: "ZZZZ")
       
    return EditProjectGroupView(group: group)
}
