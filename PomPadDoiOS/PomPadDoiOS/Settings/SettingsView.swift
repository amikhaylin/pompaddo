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
    
    @State private var viewMode = 0
    
    var body: some View {
        VStack {
            Picker("", selection: $viewMode) {
                ForEach(0...1, id: \.self) { mode in
                    HStack {
                        switch mode {
                        case 0:
                            Label("Focus timer", systemImage: "timer")
                        case 1:
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
                    VStack {
                        Text("Work session duration: \(Common.formatSeconds(Int(timerWorkSession)))")
                        Slider(value: $timerWorkSession, in: 600...3600) {
                            EmptyView()
                        } minimumValueLabel: {
                            Text("10m")
                        } maximumValueLabel: {
                            Text("1h")
                        }
                    }
                    
                    VStack {
                        Text("Break duration: \(Common.formatSeconds(Int(timerBreakSession)))")
                        Slider(value: $timerBreakSession, in: 60...3600) {
                            EmptyView()
                        } minimumValueLabel: {
                            Text("1m")
                        } maximumValueLabel: {
                            Text("1h")
                        }
                    }

                    VStack {
                        Text("Long break duration: \(Common.formatSeconds(Int(timerLongBreakSession)))")
                        Slider(value: $timerLongBreakSession, in: 60...3600) {
                            EmptyView()
                        } minimumValueLabel: {
                            Text("1m")
                        } maximumValueLabel: {
                            Text("1h")
                        }
                    }

                    VStack {
                        Text("Work sessions before long break: \(timerWorkSessionsCount, specifier: "%.0f")")
                        Slider(value: $timerWorkSessionsCount, in: 1...10) {
                            EmptyView()
                        } minimumValueLabel: {
                            Text("1")
                        } maximumValueLabel: {
                            Text("10")
                        }
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
            case 1:
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
                        Label("Default values", systemImage: "arrow.circlepath")
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
