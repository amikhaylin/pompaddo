//
//  EditTaskNameView.swift
//  PomPadDo.mobile
//
//  Created by Andrey Mikhaylin on 21.05.2025.
//

import SwiftUI
import SwiftData

struct EditTaskNameView: View {
    @Environment(\.presentationMode) var presentationMode
    @Bindable var task: Todo
    
    enum FocusField: Hashable {
        case taskName
    }
    
    @FocusState private var focusField: FocusField?
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Task", text: $task.name)
                    .focused($focusField, equals: .taskName)
                    .task {
                        self.focusField = .taskName
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
    @Previewable @State var task = Todo(name: "Some task")
       
    EditTaskNameView(task: task)
}
