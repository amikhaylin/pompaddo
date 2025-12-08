//
//  SettingsView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 06.06.2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("timerWorkSession") private var timerWorkSession: Double = 1500.0
    @AppStorage("timerBreakSession") private var timerBreakSession: Double = 300.0
    @AppStorage("timerLongBreakSession") private var timerLongBreakSession: Double = 1200.0
    @AppStorage("timerWorkSessionsCount") private var timerWorkSessionsCount: Double = 4.0
    
    @AppStorage("estimateFactor") private var estimateFactor: Double = 1.7
    @AppStorage("showReviewBadge") private var showReviewProjectsBadge: Bool = false
    
    @AppStorage("showDeadlinesSection") var showDeadlinesSection: Bool = true
    @AppStorage("showAllSection") var showAllSection: Bool = true
    @AppStorage("showReviewSection") var showReviewSection: Bool = true
    @AppStorage("showTomorrowSection") var showTomorrowSection: Bool = true
    
    @State private var viewMode = 0
    
    var body: some View {
        VStack {
            Picker("", selection: $viewMode) {
                ForEach(0...2, id: \.self) { mode in
                    HStack {
                        switch mode {
                        case 0:
                            Label("General", systemImage: "gear")
                        case 1:
                            Label("Focus timer", systemImage: "timer")
                        case 2:
                            Label("Estimates", systemImage: "hourglass")
                        default:
                            EmptyView()
                        }
                    }
                    .tag(mode as Int)
                }
            }.pickerStyle(.segmented)
            
            switch viewMode {
            case 0:
                Form {
                    Toggle("Show count of projects to review on app icon", isOn: $showReviewProjectsBadge)
                        .toggleStyle(.switch)
                    
                    Section("Lists") {
                        Toggle("Show Deadlines list", isOn: $showDeadlinesSection)
                            .toggleStyle(.switch)
                        Toggle("Show All list", isOn: $showAllSection)
                            .toggleStyle(.switch)
                        Toggle("Show Review list", isOn: $showReviewSection)
                            .toggleStyle(.switch)
                        Toggle("Show Tomorrow list", isOn: $showTomorrowSection)
                            .toggleStyle(.switch)
                    }
                }
            case 1:
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
            case 2:
                Form {
                    VStack {
                        Text("Estimate factor: \(estimateFactor, specifier: "%.2f")")
                        Slider(value: $estimateFactor, in: 0.01...3) {
                            EmptyView()
                        } minimumValueLabel: {
                            Text("0.01")
                        } maximumValueLabel: {
                            Text("3")
                        }
                    }
                    
                    Button {
                        estimateFactor = 1.7
                    } label: {
                        Label("Restore defaults", systemImage: "arrow.circlepath")
                    }
                }
            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    SettingsView()
}
