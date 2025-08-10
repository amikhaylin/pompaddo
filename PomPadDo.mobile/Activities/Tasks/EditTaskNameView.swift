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
    @State private var task: Todo
    @State private var name: String
    
    enum FocusField: Hashable {
        case taskName
    }
    
    @FocusState private var focusField: FocusField?
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Task", text: $name)
                    .focused($focusField, equals: .taskName)
                    .task {
                        self.focusField = .taskName
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
                        task.name = name
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    init(task: Todo) {
        self.task = task
        self.name = task.name
    }
}

#Preview {
    @Previewable @State var task = Todo(name: "Some task")
       
    EditTaskNameView(task: task)
}
