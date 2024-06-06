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

    private enum Tabs: Hashable {
        case timer, estimates, advanced
    }

    var body: some View {
        TabView {
            Form {
                Slider(value: $timerWorkSession, in: 600...3600) {
                    Text("Work session duration: \(Common.formatSeconds(Int(timerWorkSession)))")
                } minimumValueLabel: {
                    Text("10m")
                } maximumValueLabel: {
                    Text("1h")
                }
                
                Slider(value: $timerBreakSession, in: 60...3600) {
                    Text("Break duration: \(Common.formatSeconds(Int(timerBreakSession)))")
                } minimumValueLabel: {
                    Text("1m")
                } maximumValueLabel: {
                    Text("1h")
                }

                Slider(value: $timerLongBreakSession, in: 60...3600) {
                    Text("Long break duration: \(Common.formatSeconds(Int(timerLongBreakSession)))")
                } minimumValueLabel: {
                    Text("1m")
                } maximumValueLabel: {
                    Text("1h")
                }

                Slider(value: $timerWorkSessionsCount, in: 1...10) {
                    Text("Work sessions before long break: \(timerWorkSessionsCount, specifier: "%.0f")")
                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text("10")
                }
                
                Button {
                    timerWorkSession = 1500.0
                    timerBreakSession = 300.0
                    timerLongBreakSession = 1200.0
                    timerWorkSessionsCount = 4.0
                } label: {
                    Label("Default values", systemImage: "arrow.circlepath")
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
                    Label("Default values", systemImage: "arrow.circlepath")
                }
            }
            .tabItem {
                Label("Estimates", systemImage: "hourglass")
            }

            Form {
                Slider(value: $refreshPeriod, in: 1...600) {
                    Text("Refresh period: \(Common.formatSeconds(Int(timerLongBreakSession)))")
                } minimumValueLabel: {
                    Text("1s")
                } maximumValueLabel: {
                    Text("10m")
                }
                
                Button {
                    refreshPeriod = 15.0
                } label: {
                    Label("Default values", systemImage: "arrow.circlepath")
                }
            }
            .tabItem {
                Label("Advanced", systemImage: "gear")
            }
            .tag(Tabs.advanced)
        }
        .padding(20)
        .frame(width: 575, height: 150)
    }
}

#Preview {
    SettingsView()
}
