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
                        Image(systemName: "calendar.badge.plus")

                        DatePicker("Due Date", 
                                   selection: $dueDate,
                                   displayedComponents: .date)
                        .onChange(of: dueDate, { _, newValue in
                            task.dueDate = newValue
                        })
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
                    ForEach(Priority.allCases, id: \.self) { priority in
                        HStack {
                            Image(systemName: "flag.fill")
                                
//                                    .foregroundStyle({
//                                        switch priority {
//                                        case .none:
//                                            return Color.gray
//                                        case.high:
//                                            return Color.red
//                                        case .medium:
//                                            return Color.yellow
//                                        case .low:
//                                            return Color.blue
//                                        }
//                                    })

                            //                        switch priority {
                            //                        case .none:
                            //                            Image(systemName: "flag.fill")
                            //                                .foregroundStyle(Color.grey)
                            //                        case.high:
                            //                            Image(systemName: "flag.fill")
                            //                                .foregroundStyle(Color.red)
                            //                        case .medium:
                            //                            Image(systemName: "flag.fill")
                            //                                .foregroundStyle(Color.yellow)
                            //                        case .low:
                            //                            Image(systemName: "flag.fill")
                            //                                .foregroundStyle(Color.blue)
                            //                        }
                            Text(priority.rawValue)
                        }
                        .tag(priority as Priority?)
                    }
                }
                
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
