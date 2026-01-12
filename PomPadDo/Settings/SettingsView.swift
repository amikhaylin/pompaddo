//
//  SettingsView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 05.06.2024.
//

import SwiftUI
import CloudStorage

struct SettingsView: View {
    @AppStorage("timerWorkSession") private var timerWorkSession: Double = 1500.0
    @AppStorage("timerBreakSession") private var timerBreakSession: Double = 300.0
    @AppStorage("timerLongBreakSession") private var timerLongBreakSession: Double = 1200.0
    @AppStorage("timerWorkSessionsCount") private var timerWorkSessionsCount: Double = 4.0
    
    @AppStorage("estimateFactor") private var estimateFactor: Double = 1.7
    
    @AppStorage("refreshPeriod") private var refreshPeriod: Double = 15.0
    
    @AppStorage("showReviewBadge") private var showReviewProjectsBadge: Bool = false
    
    @AppStorage("showDeadlinesSection") var showDeadlinesSection: Bool = true
    @AppStorage("showAllSection") var showAllSection: Bool = true
    @AppStorage("showReviewSection") var showReviewSection: Bool = true
    @AppStorage("showTomorrowSection") var showTomorrowSection: Bool = true
    @AppStorage("showTrashSection") var showTrashSection: Bool = true
    
    @AppStorage("emptyTrash") var emptyTrash: Bool = true
    @AppStorage("eraseTasksForDays") var eraseTasksForDays: Int = 7
    
    @CloudStorage("bujoCheckboxes") var bujoCheckboxes: Bool = false

    private enum Tabs: Hashable {
        case general, timer, estimates, advanced
    }

    var body: some View {
        TabView {
            Form {
                Section("General") {
                    Toggle("Empty trash", isOn: $emptyTrash)
                        .toggleStyle(.checkbox)
                        
                    if emptyTrash {
                        HStack {
                            Picker("", selection: $eraseTasksForDays) {
                                ForEach(1..<31) {
                                    Text("\($0)")
                                        .tag($0)
                                }
                            }
                            Text(" days")
                        }
                    }
                    Toggle("Show count of projects to review on app icon", isOn: $showReviewProjectsBadge)
                        .toggleStyle(.checkbox)
                    
                    Toggle("BuJo checkboxes style", isOn: $bujoCheckboxes)
                        .toggleStyle(.checkbox)
                }
                Section("Lists") {
                    Toggle("Show Deadlines list", isOn: $showDeadlinesSection)
                        .toggleStyle(.checkbox)
                    Toggle("Show All list", isOn: $showAllSection)
                        .toggleStyle(.checkbox)
                    Toggle("Show Review list", isOn: $showReviewSection)
                        .toggleStyle(.checkbox)
                    Toggle("Show Tomorrow list", isOn: $showTomorrowSection)
                        .toggleStyle(.checkbox)
                    Toggle("Show Trash list", isOn: $showTrashSection)
                        .toggleStyle(.checkbox)
                }
            }
            .tabItem {
                Label("General", systemImage: "gear")
            }
            .tag(Tabs.general)
            
            Form {
                Picker("Work session duration", selection: $timerWorkSession) {
                    ForEach(Array(stride(from: 60, through: 3600, by: 60)), id: \.self) { index in
                        Text(Common.formatSecondsToMinutes(Int(index)))
                            .tag(Double(index))
                    }
                }
                
                Picker("Break duration", selection: $timerBreakSession) {
                    ForEach(Array(stride(from: 60, through: 3600, by: 60)), id: \.self) { index in
                        Text(Common.formatSecondsToMinutes(Int(index)))
                            .tag(Double(index))
                    }
                }

                Picker("Long break duration", selection: $timerLongBreakSession) {
                    ForEach(Array(stride(from: 60, through: 3600, by: 60)), id: \.self) { index in
                        Text(Common.formatSecondsToMinutes(Int(index)))
                            .tag(Double(index))
                    }
                }

                Picker("Work sessions before long break", selection: $timerWorkSessionsCount) {
                    ForEach(1..<11) {
                        Text("\($0)")
                            .tag(Double($0))
                    }
                }
                
                Button {
                    timerWorkSession = 1500.0
                    timerBreakSession = 300.0
                    timerLongBreakSession = 1200.0
                    timerWorkSessionsCount = 4.0
                } label: {
                    Label("Restore defaults", systemImage: "arrow.circlepath")
                }
            }
            .tabItem {
                Label("Focus timer", systemImage: "timer")
            }
            .tag(Tabs.timer)

            Form {
                Slider(value: $estimateFactor, in: 0.01...3) {
                    Text("Estimate factor: \(estimateFactor, specifier: "%.2f")")
                } minimumValueLabel: {
                    Text("0.01")
                } maximumValueLabel: {
                    Text("3")
                }
                
                Button {
                    estimateFactor = 1.7
                } label: {
                    Label("Restore defaults", systemImage: "arrow.circlepath")
                }
            }
            .tabItem {
                Label("Estimates", systemImage: "hourglass")
            }
        }
        .padding(20)
        .frame(width: 575, height: 300)
    }
}

#Preview {
    SettingsView()
}
