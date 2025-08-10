//
//  EditTaskNameView.swift
//  PomPadDo
//
//  Created by Andrey Mikhaylin on 21.05.2025.
//

import SwiftUI
import SwiftData

struct EditTaskNameView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var task: Todo
    @State private var name: String
    
    var body: some View {
        VStack {
            TextField("Task", text: $name)
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                Spacer()
                Button("OK") {
                    task.name = name
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .frame(width: 400, height: 100)
        .padding()
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
