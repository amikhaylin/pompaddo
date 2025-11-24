//
//  SettingsView.swift
//  PomPadDo.watch Watch App
//
//  Created by Andrey Mikhaylin on 29.08.2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("timerWorkSession") private var timerWorkSession: Double = 1500.0
    @AppStorage("timerBreakSession") private var timerBreakSession: Double = 300.0
    @AppStorage("timerLongBreakSession") private var timerLongBreakSession: Double = 1200.0
    @AppStorage("timerWorkSessionsCount") private var timerWorkSessionsCount: Double = 4.0
    
    @AppStorage("showDeadlinesSection") var showDeadlinesSection: Bool = true
    
    var body: some View {
        Form {
            Section("General") {
                Toggle("Show Deadlines section", isOn: $showDeadlinesSection)
                    .toggleStyle(.switch)
            }
            
            Section("Focus Timer") {
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
        }
        .navigationBarTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
