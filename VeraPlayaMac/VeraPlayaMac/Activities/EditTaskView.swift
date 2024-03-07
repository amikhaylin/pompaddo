//
//  EditTaskView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 18.02.2024.
//

import SwiftUI
import SwiftData

struct EditTaskView: View {
    @Bindable var task: Todo
    @State private var dueDate = Date.now
    @State private var showingDatePicker = false
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $task.name)
                
                if showingDatePicker {
                    HStack{
                        Image(systemName: "calendar.badge.plus")

                        DatePicker("Due Date", 
                                   selection: $dueDate,
                                   displayedComponents: .date)
                        .onChange(of: dueDate, { oldValue, newValue in
                            task.dueDate = newValue
                        })
                    }
                } else {
                    Button {
                        withAnimation {
                            showingDatePicker.toggle()
                            task.dueDate = dueDate
                        }
                    } label: {
                        Label("Set due Date", systemImage: "calendar.badge.plus")
                    }
                }
            }
        }
        .padding(10)
        .onChange(of: task) { oldValue, newValue in
            setPicker()
        }
        .onAppear(perform: {
            setPicker()
        })

    }
    
    func setPicker() {
        if let date = task.dueDate {
            dueDate = date
            showingDatePicker = true
        } else {
            dueDate = Date.now
            showingDatePicker = false
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        
        return EditTaskView(task: previewer.task)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
