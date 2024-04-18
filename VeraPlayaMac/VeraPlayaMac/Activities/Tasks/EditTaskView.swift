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
    @State private var dueDate = Date()
    @State private var showingDatePicker = false
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $task.name)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top, 10.0)
                
                if showingDatePicker {
                    HStack {
                        DatePicker("Due Date",
                                   selection: $dueDate,
                                   displayedComponents: .date)
                        .onChange(of: dueDate, { _, newValue in
                            task.dueDate = newValue
                        })
                        
                        Button {
                            task.dueDate = nil
                            showingDatePicker = false
                        } label: {
                            Image(systemName: "clear")
                        }
                        
                        Button {
                            task.dueDate = Calendar.current.startOfDay(for: Date())
                        } label: {
                            Image(systemName: "calendar")
                        }
                        
                        Button {
                            task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                        } label: {
                            Image(systemName: "sunrise")
                        }
                    }
                } else {
                    Button {
                        withAnimation {
                            showingDatePicker.toggle()
                            task.dueDate = Calendar.current.startOfDay(for: dueDate)
                        }
                    } label: {
                        Label("Set due Date", systemImage: "calendar.badge.plus")
                    }
                }
                
                Picker("Repeat", selection: $task.repeation) {
                    ForEach(RepeationMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode as RepeationMode?)
                    }
                }
                
                Picker("Priority", selection: $task.priority) {
                    ForEach(0...3, id: \.self) { priority in
                        HStack {
                            switch priority {
                            case 0:
                                Text("None")
                            case 3:
                                Text("High")
                            case 2:
                                Text("Medium")
                            case 1:
                                Text("Low")
                            default:
                                EmptyView()
                            }
                        }
                        .tag(priority as Int)
                    }
                }.pickerStyle(.segmented)
                
                HStack {
                    TextField("Link", text: $task.link)
                        .textContentType(.URL)
                    if let url = URL(string: task.link) {
                        Link(destination: url,
                             label: {
                            Image(systemName: "link")
                        })
                    }
                }
                
                LabeledContent("Note") {
                    TextEditor(text: $task.note)
                        .background(Color.primary.colorInvert())
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.black, lineWidth: 1 / 3)
                                .opacity(0.3)
                        )
                        .frame(maxHeight: .infinity)
                        .padding(.bottom, 10.0)
                }
                .padding(.bottom, 10.0)
            }
        }
        .padding(10)
        .onChange(of: task) { _, _ in
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
