//
//  EditTaskView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 18.02.2024.
//

import SwiftUI
import SwiftData

struct EditTaskView: View {
    @Bindable var task: Todo
    @State private var dueDate = Date()
    @State private var showingDatePicker = false
    
    @State private var alertDate = Date()
    @State private var showingReminderDatePicker = false
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $task.name)
                    .textFieldStyle(.roundedBorder)
            }
            
            Section("Due date") {
                if showingDatePicker {
                    Group {
                        DatePicker("Due Date",
                                   selection: $dueDate,
                                   displayedComponents: .date)
                        .onChange(of: dueDate, { _, newValue in
                            task.dueDate = newValue
                        })
                        
                        Button {
                            task.dueDate = Calendar.current.startOfDay(for: Date())
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text("Today")
                            }
                        }
                        
                        Button {
                            task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                        } label: {
                            HStack {
                                Image(systemName: "sunrise")
                                Text("Tomorrow")
                            }
                        }
                        
                        Button {
                            task.dueDate = nil
                            showingDatePicker = false
                        } label: {
                            HStack {
                                Image(systemName: "clear")
                                Text("Clear due date")
                            }
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
                
                if task.repeation == .custom {
                    HStack {
                        Picker("Repead every", selection: $task.customRepeatValue) {
                            ForEach(1...30, id: \.self) { units in
                                Text("\(units)")
                                    .tag(units)
                            }
                        }
                        Picker("", selection: $task.customRepeatType) {
                            ForEach(CustomRepeationType.allCases, id: \.self) { reptype in
                                Text(reptype.rawValue).tag(reptype as CustomRepeationType?)
                            }
                        }
                    }
                }
            }
            
            Section {
                
                Picker("Priority", selection: $task.priority) {
                    ForEach(0...3, id: \.self) { priority in
                        HStack {
                            switch priority {
                            case 3:
                                Text("High")
                            case 2:
                                Text("Medium")
                            case 1:
                                Text("Low")
                            default:
                                Text("None")
                            }
                        }
                        .tag(priority as Int)
                    }
                }.pickerStyle(.segmented)
                
                if task.hasEstimate {
                    Picker("Clarity", selection: $task.clarity) {
                        ForEach(0...3, id: \.self) { clarity in
                            HStack {
                                switch clarity {
                                case 1:
                                    Text("Clear")
                                case 2:
                                    Text("Half clear")
                                case 3:
                                    Text("Not clear")
                                default:
                                    Text("None")
                                }
                            }
                            .tag(clarity as Int)
                        }
                    }.pickerStyle(.segmented)
                    
                    Picker("Base hours", selection: $task.baseTimeHours) {
                        ForEach(1...100, id: \.self) { hours in
                            Text("\(hours)")
                                .tag(hours)
                        }
                    }
                    
                    HStack {
                        // TODO: Change factor in settings
                        Text("Estimate is \(task.sumEstimates(1.7)) hours")
                        
                        Button {
                            task.hasEstimate = false
                        } label: {
                            Image(systemName: "clear")
                        }
                    }
                } else {
                    Button {
                        withAnimation {
                            task.hasEstimate = true
                        }
                    } label: {
                        Label("Estimate", systemImage: "hourglass")
                    }
                }
            }
             
            Section {
                HStack {
                    TextField("Link", text: $task.link)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.URL)
                    if let url = URL(string: task.link) {
                        Link(destination: url,
                             label: {
                            Image(systemName: "link")
                        })
                    }
                }
            }
            
            Section("Reminder") {
                if showingReminderDatePicker {
                    Group {
                        DatePicker("Remind at",
                                   selection: $alertDate)
                        
                        Button {
                            NotificationManager.removeRequest(identifier: task.uid)
                            task.alertDate = alertDate
                            NotificationManager.setTaskNotification(task: task)
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.square")
                                Text("Apply reminder")
                            }
                        }
                        
                        Button {
                            task.alertDate = nil
                            NotificationManager.removeRequest(identifier: task.uid)
                            showingReminderDatePicker = false
                        } label: {
                            HStack {
                                Image(systemName: "clear")
                                Text("Clear reminder")
                            }
                        }
                    }
                } else {
                    Button {
                        withAnimation {
                            showingReminderDatePicker.toggle()
                            alertDate = Date()
                        }
                    } label: {
                        Label("Set Reminder", systemImage: "bell")
                    }
                }
            }
            
            Section("Focus stats") {
                HStack {
                    Text("Focused for ")
                    Image(systemName: "target")
                    Text("\(task.tomatoesCount)")
                    Image(systemName: "stopwatch")
                    Text("\(Int((task.tomatoesCount * 25) / 60))h\(Int((task.tomatoesCount * 25) % 60))m ")
                }
                
                HStack {
                    let totalFocused = task.getTotalFocus()
                    Text("Total focused ")
                    Image(systemName: "target")
                    Text("\(totalFocused)")
                    Image(systemName: "stopwatch")
                    Text("\(Int((totalFocused * 25) / 60))h\(Int((totalFocused * 25) % 60))m ")
                }
            }
            
            Section("Note") {
                
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
        }
        .onChange(of: task) { _, _ in
            setPicker()
        }
        .onAppear(perform: {
            setPicker()
        })
        .task {
            let hasAlert = await NotificationManager.checkTaskHasRequest(task: task)
            if task.alertDate != nil && !hasAlert {
                task.alertDate = nil
                showingReminderDatePicker = false
            }
        }
    }
    
    func setPicker() {
        if let date = task.dueDate {
            dueDate = date
            showingDatePicker = true
        } else {
            dueDate = Date.now
            showingDatePicker = false
        }
        
        if let date = task.alertDate {
            alertDate = date
            showingReminderDatePicker = true
        } else {
            alertDate = Date()
            showingReminderDatePicker = false
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
