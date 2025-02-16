//
//  FocusTabItemView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 21.09.2024.
//

import SwiftUI

struct FocusTabItemView: View {
    @EnvironmentObject var timer: FocusTimer
    @Binding var tab: MainViewTabs
    @State private var focusMode: FocusTimerMode = .work
    @State private var focusState: FocusTimerState = .idle
    @State private var timerCount: String = ""
    
    var body: some View {
        Group {
            if focusState == .idle {
                Image(systemName: "target")
                    .foregroundStyle(tab == .focus ? Color.blue : Color.gray)
            } else {
                HStack {
                    if focusMode == .work {
                        Image(systemName: "target")
                            .foregroundStyle(tab == .focus ? Color.blue : Color.red)
                    } else {
                        Image(systemName: "cup.and.saucer.fill")
                            .foregroundStyle(tab == .focus ? Color.blue : Color.green)
                    }
                    if timer.state == .running {
                        Text(timerCount)
                            .foregroundStyle(focusMode == .work ? Color.red : Color.green)
                    } else {
                        Text(timerCount)
                            .foregroundStyle(focusMode == .work ? Color.red : Color.green)
                    }
                }
            }
        }
        .onChange(of: timer.secondsPassed, { _, _ in
            timerCount = timer.secondsLeftString
        })
        .onChange(of: timer.state) { _, _ in
            focusState = timer.state
        }
        .onChange(of: timer.mode) { _, _ in
            focusMode = timer.mode
        }
    }
}

#Preview {
    @Previewable @State var tab: MainViewTabs = .tasks
    
    FocusTabItemView(tab: $tab)
}
