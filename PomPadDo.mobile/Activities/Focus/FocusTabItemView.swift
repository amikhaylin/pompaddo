//
//  FocusTabItemView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 21.09.2024.
//

import SwiftUI

struct FocusTabItemView: View {
    @Environment(FocusTimer.self) var timer
    @State private var timerCount: String = ""
    
    var body: some View {
        Group {
            if timer.state == .idle {
                Label("Focus", image: "tomato")
            } else {
                if timer.mode == .work {
                    Label("\(timer.mode.title)", image: "tomato.fill")
                } else {
                    Label("\(timer.mode.title)", systemImage: "cup.and.saucer.fill")
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
