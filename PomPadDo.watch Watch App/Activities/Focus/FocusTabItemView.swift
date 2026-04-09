//
//  FocusTabItemView.swift
//  PomPadDo.watch Watch App
//
//  Created by Andrey Mikhaylin on 09.04.2026.
//

import SwiftUI

import SwiftUI

struct FocusTabItemView: View {
    @Environment(FocusTimer.self) var timer
    @State private var timerCount: String = ""
    
    var body: some View {
        Group {
            if timer.state == .idle {
                Image("tomato")
                #if os(watchOS)
                Text("Focus")
                #endif
            } else {
                HStack {
                    if timer.mode == .work {
                        Image("tomato.fill")
                            .symbolRenderingMode(.multicolor)
                    } else {
                        Image(systemName: "cup.and.saucer.fill")
                    }
                    if timer.state == .running {
                        Text(timerCount)
                            .foregroundStyle(timer.mode == .work ? Color.red : Color.green)
                    } else {
                        Text(timerCount)
                            .foregroundStyle(timer.mode == .work ? Color.red : Color.green)
                    }
                }
            }
        }
        .onChange(of: timer.secondsPassed, { _, _ in
            timerCount = timer.secondsLeftString
        })
    }
}

#Preview {
    @Previewable @State var timer = FocusTimer(workInSeconds: 1500,
                                                     breakInSeconds: 300,
                                                     longBreakInSeconds: 1200,
                                                     workSessionsCount: 4)
    
    FocusTabItemView()
        .environment(timer)
}
