//
//  FocusTimerScene.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 19.06.2024.
//

import SwiftUI

struct FocusTimerScene: Scene {
    @Environment(\.modelContext) private var modelContext
    @Environment(Refresher.self) var refresher
    @Environment(FocusTimer.self) var timer
    @Environment(FocusTask.self) var focusTask
    @State private var timerCount: String = ""
    @State private var focusMode: FocusTimerMode = .work
    @State private var focusState: FocusTimerState = .idle
    
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
                
                let updateImage = image?.withSymbolConfiguration(configuration)
                
                Image(nsImage: updateImage!)
            } else {
                HStack {
                    if focusMode == .work {
                        let configuration = NSImage.SymbolConfiguration(pointSize: 14, weight: .light)
                            .applying(.preferringMulticolor())
  
                        let image = NSImage(named: "tomato.fill")

                        let updateImage = image?.withSymbolConfiguration(configuration)
                        
                        Image(nsImage: updateImage!)
                    } else {
                        let configuration = NSImage.SymbolConfiguration(pointSize: 14, weight: .light)
                            .applying(.init(hierarchicalColor: .green))
                        
                        let image = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: nil)
                        let updateImage = image?.withSymbolConfiguration(configuration)
                        
                        Image(nsImage: updateImage!) // This works.
                    }
                    
                    Text(timerCount)
                }
            }
        }
        .menuBarExtraStyle(.window)
        .onChange(of: timer.secondsPassed, { _, _ in
            timerCount = timer.secondsLeftString
        })
        .onChange(of: timer.mode, { _, _ in
            focusMode = timer.mode
        })
        .onChange(of: timer.state) { _, _ in
            focusState = timer.state
        }
        .onChange(of: timer.sessionsCounter, { _, newValue in
            if let task = focusTask.task, newValue > 0 {
                task.tomatoesCount += 1
            }
        })
    }
}
