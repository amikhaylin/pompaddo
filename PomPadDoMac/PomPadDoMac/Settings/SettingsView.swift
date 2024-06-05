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

    private enum Tabs: Hashable {
        case timer, estimates, advanced
    }

    var body: some View {
        TabView {
            Form {
                Slider(value: $timerWorkSession, in: 600...3600) {
                    Text("Work session duration: \(timerWorkSession / 60, specifier: "%.0f")m")
                } minimumValueLabel: {
                    Text("10m")
                } maximumValueLabel: {
                    Text("1h")
                }
                
                Slider(value: $timerBreakSession, in: 60...3600) {
                    Text("Break duration: \(timerBreakSession / 60, specifier: "%.0f")m")
                } minimumValueLabel: {
                    Text("1m")
                } maximumValueLabel: {
                    Text("1h")
                }

                Slider(value: $timerLongBreakSession, in: 60...3600) {
                    Text("Long break duration: \(timerLongBreakSession / 60, specifier: "%.0f")m")
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
            }
            .tabItem {
                Label("Estimates", systemImage: "hourglass")
            }

            Text("Advanced")
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
