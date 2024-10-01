//
//  NewTaskView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 14.05.2024.
//

import SwiftUI
import SwiftData

struct NewTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @Binding var isVisible: Bool
    @State var list: SideBarItem
    @State private var taskName = ""
    @State private var link = ""
    @State private var dueToday = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Add task to \(list)...")
                    .font(.headline)
                
                TextField("Task name", text: $taskName)
                
                TextField("Link", text: $link)
                    .textContentType(.URL)
                
                Toggle("Due today", isOn: $dueToday)
                    .toggleStyle(.switch)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        self.isVisible = false
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("OK") {
                        self.isVisible = false
                        let task = Todo(name: taskName, link: link)
                        if list == .today || dueToday {
                            task.dueDate = Calendar.current.startOfDay(for: Date())
                        }
                        
                        modelContext.insert(task)
                        refresher.refresh.toggle()
                    }
                }
            }
        }
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
