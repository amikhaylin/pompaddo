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
    @State private var taskName = ""
    
    var body: some View {
        VStack {
            Text("Add task to inbox...")
                .font(.headline)
            
            TextField("Task name", text: $taskName)
            
            HStack {
                Button("Cancel") {
                    self.isVisible = false
                }
                Spacer()
                Button("OK") {
                    self.isVisible = false
                    let task = Todo(name: taskName)
                    modelContext.insert(task)
                }
            }
        }
        .frame(width: 400, height: 100)
        .padding()
    }
}

//#Preview {
//    do {
//        let previewer = try Previewer()
//        
//        var isVisible = true
//        
//        return NewTaskView(isVisible: isVisible)
//            .modelContainer(previewer.container)
//    } catch {
//        return Text("Failed to create preview: \(error.localizedDescription)")
//    }
//}
