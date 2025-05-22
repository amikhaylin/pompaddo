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
    @Bindable var task: Todo
    
    var body: some View {
        VStack {
            TextField("Task", text: $task.name)
            
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
    @Previewable @State var task = Todo(name: "Some task")
       
    EditTaskNameView(task: task)
}
