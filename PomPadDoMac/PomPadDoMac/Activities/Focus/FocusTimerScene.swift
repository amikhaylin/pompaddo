//
//  FocusTimerScene.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 19.06.2024.
//

import SwiftUI

struct FocusTimerScene: Scene {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var refresher: Refresher
    @State private var timerCount: String = ""
    @State private var focusMode: FocusTimerMode = .work
    
    @StateObject var timer = FocusTimer(workInSeconds: 1500,
                           breakInSeconds: 300,
                           longBreakInSeconds: 1200,
                           workSessionsCount: 4)

    var body: some Scene {
        MenuBarExtra {
            FocusTimerView(context: modelContext,
                           timerCount: $timerCount,
                           focusMode: $focusMode)
            .environmentObject(refresher)
            .environmentObject(timer)
            .modelContext(modelContext)
        } label: {
            HStack {
                if focusMode == .work {
                    let configuration = NSImage.SymbolConfiguration(pointSize: 16, weight: .light)
//                        .applying(.init(hierarchicalColor: .yellow))
                        .applying(.init(hierarchicalColor: .red))
                    
                    let image = NSImage(systemSymbolName: "target", accessibilityDescription: nil)
                    let updateImage = image?.withSymbolConfiguration(configuration)
                    
                    Image(nsImage: updateImage!)
                } else {
                    let configuration = NSImage.SymbolConfiguration(pointSize: 16, weight: .light)
//                        .applying(.init(hierarchicalColor: .blue))
                        .applying(.init(hierarchicalColor: .green))
                                    
                    let image = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: nil)
                    let updateImage = image?.withSymbolConfiguration(configuration)

                    Image(nsImage: updateImage!) // This works.
                }

                Text(timerCount)
            }
        }
        .menuBarExtraStyle(.window)
        .onChange(of: timer.secondsPassed, { _, _ in
            timerCount = timer.secondsLeftString
        })
        .onChange(of: timer.mode, { _, _ in
            focusMode = timer.mode
        })
    }
}
