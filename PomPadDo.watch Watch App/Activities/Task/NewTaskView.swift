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
    @EnvironmentObject var refresher: Refresher
    @State private var taskName = ""
    @State private var dueToday = false
    
    var body: some View {
        NavigationView {
            TextField("Add task to Inbox", text: $taskName)
                .onSubmit {
                    let task = Todo(name: taskName)
                    
                    if dueToday {
                        task.dueDate = Calendar.current.startOfDay(for: Date())
                    }
                    
                    modelContext.insert(task)
                    presentationMode.wrappedValue.dismiss()
                }
            
            Toggle("Due today", isOn: $dueToday)
                .toggleStyle(.switch)
        }
    }
}

#Preview {
    NewTaskView()
}
