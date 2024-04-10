//
//  NewTaskView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 27.02.2024.
//

import SwiftUI
import SwiftData

struct NewTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isVisible: Bool
    @State var list: SideBarItem
    @State private var taskName = ""
    @State private var link = ""
    
    var body: some View {
        VStack {
            Text("Add task to \(list)...")
                .font(.headline)
            
            TextField("Task name", text: $taskName)
            
            TextField("Link", text: $link)
                .textContentType(.URL)
            
            HStack {
                Button("Cancel") {
                    self.isVisible = false
                }
                .keyboardShortcut(.cancelAction)
                Spacer()
                Button("OK") {
                    self.isVisible = false
                    let task = Todo(name: taskName, link: link)
                    if list == .today {
                        task.dueDate = Calendar.current.startOfDay(for: Date())
                    }

                    modelContext.insert(task)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .frame(width: 400, height: 100)
        .padding()
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        
        @State var isVisible = true
        
        return NewTaskView(isVisible: $isVisible, list: .inbox)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
