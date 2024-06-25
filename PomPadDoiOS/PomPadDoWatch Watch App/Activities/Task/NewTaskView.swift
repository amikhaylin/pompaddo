//
//  NewTaskView.swift
//  PomPadDoWatch Watch App
//
//  Created by Andrey Mikhaylin on 25.06.2024.
//

import SwiftUI
import SwiftData

struct NewTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @State private var taskName = ""
    
    var body: some View {
        NavigationView {
            TextField("Add task to Inbox", text: $taskName)
                .onSubmit {
                    let task = Todo(name: taskName)
                    modelContext.insert(task)
                    presentationMode.wrappedValue.dismiss()
                }
        }
    }
}

#Preview {
    NewTaskView()
}
