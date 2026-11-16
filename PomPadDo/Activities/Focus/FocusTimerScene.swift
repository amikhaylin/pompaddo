//
//  FocusTimerScene.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 19.06.2024.
//

import SwiftUI
import SwiftData

struct FocusTimerScene: Scene {
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var modelContext
    @Environment(Refresher.self) var refresher
    @Environment(FocusTimer.self) var timer
    @Environment(FocusTask.self) var focusTask
    @State private var timerCount: String = ""
    @State private var focusMode: FocusTimerMode = .work
    @State private var focusState: FocusTimerState = .idle
    
    @AppStorage("scWork") var scWork: Bool = false
    @AppStorage("scWorkName") var scWorkName: String = ""
    
    @AppStorage("scBreak") var scBreak: Bool = false
    @AppStorage("scBreakName") var scBreakName: String = ""

    @AppStorage("scPause") var scPause: Bool = false
    @AppStorage("scPauseName") var scPauseName: String = ""

    @AppStorage("scResume") var scResume: Bool = false
    @AppStorage("scResumeName") var scResumeName: String = ""
    
    var body: some Scene {
        MenuBarExtra {
            FocusTimerView(context: modelContext,
                           timerCount: $timerCount,
                           focusMode: $focusMode)
            .environment(refresher)
            .modelContext(modelContext)
        } label: {
            if focusState == .idle {
                let configuration = NSImage.SymbolConfiguration(pointSize: 14, weight: .light)
                
                let image = NSImage(named: "tomato")
                
                if let updateImage = image?.withSymbolConfiguration(configuration) {
                    Image(nsImage: updateImage)
                }
            } else {
                HStack {
                    if focusMode == .work {
                        let configuration = NSImage.SymbolConfiguration(pointSize: 14, weight: .light)
                            .applying(.preferringMulticolor())
  
                        let image = NSImage(named: "tomato.fill")

                        if let updateImage = image?.withSymbolConfiguration(configuration) {
                            Image(nsImage: updateImage)
                        }
                    } else {
                        let configuration = NSImage.SymbolConfiguration(pointSize: 14, weight: .light)
                            .applying(.init(hierarchicalColor: .green))
                        
                        let image = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: nil)
                        if let updateImage = image?.withSymbolConfiguration(configuration) {
                            Image(nsImage: updateImage)
                        }
                    }
                    
                    Text(timerCount)
                }
            }
        }
        .menuBarExtraStyle(.window)
        .onChange(of: timer.secondsPassed, { _, _ in
            timerCount = timer.secondsLeftString
        })
        .onChange(of: timer.mode, { _, newValue in
            focusMode = timer.mode
            
            switch newValue {
            case .work:
                if scWork {
                    runShortcut(scWorkName)
                }
            case .pause:
                if scBreak {
                    runShortcut(scBreakName)
                }
            case .longbreak:
                if scBreak {
                    runShortcut(scBreakName)
                }
            }
        })
        .onChange(of: timer.state) { oldValue, newValue in
            focusState = timer.state
            
            // work start
            if newValue == .running && oldValue == .idle && timer.mode == .work {
                if scWork {
                    runShortcut(scWorkName)
                }
            }
            
            // pause
            if newValue == .paused && oldValue == .running {
                if scPause {
                    runShortcut(scPauseName)
                }
            }
            
            // resume
            if newValue == .running && oldValue == .paused {
                if scResume {
                    runShortcut(scResumeName)
                }
            }
        }
        .onChange(of: timer.sessionsCounter, { _, newValue in
            if let task = focusTask.task, newValue > 0 {
                task.tomatoesCount += 1
            }
        })
    }
    
    private func runShortcut(_ name: String) {
        var components = URLComponents()
        components.scheme = "shortcuts"
        components.host = "run-shortcut"
        components.queryItems = [
            URLQueryItem(name: "name", value: name)
        ]

        guard let url = components.url else {
            return
        }
        
        openURL(url)
    }
}
