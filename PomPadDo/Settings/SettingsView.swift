//
//  SettingsView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 05.06.2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("timerWorkSession") private var timerWorkSession: Double = 1500.0
    @AppStorage("timerBreakSession") private var timerBreakSession: Double = 300.0
    @AppStorage("timerLongBreakSession") private var timerLongBreakSession: Double = 1200.0
    @AppStorage("timerWorkSessionsCount") private var timerWorkSessionsCount: Double = 4.0
    
    @AppStorage("estimateFactor") private var estimateFactor: Double = 1.7
    
    @AppStorage("refreshPeriod") private var refreshPeriod: Double = 15.0
    
    @AppStorage("showReviewBadge") private var showReviewProjectsBadge: Bool = false

    private enum Tabs: Hashable {
        case general, timer, estimates, advanced
    }

    var body: some View {
        TabView {
            Form {
                Toggle("Show count of projects to review on app icon", isOn: $showReviewProjectsBadge)
                    .toggleStyle(.checkbox)
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
        .frame(width: 575, height: 150)
    }
}

#Preview {
    SettingsView()
}
