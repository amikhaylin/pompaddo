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
    @State private var timerCount: String = ""
    
    var body: some View {
        Group {
            if timer.state == .idle {
                Image(systemName: "target")
                    .foregroundStyle(tab == .focus ? Color.blue : Color.gray)
            } else {
                HStack {
                    if timer.mode == .work {
                        Image(systemName: "target")
                            .foregroundStyle(tab == .focus ? Color.blue : Color.red)
                    } else {
                        Image(systemName: "cup.and.saucer.fill")
                            .foregroundStyle(tab == .focus ? Color.blue : Color.green)
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
    @Previewable @State var tab: MainViewTabs = .tasks
    @Previewable @StateObject var timer = FocusTimer(workInSeconds: 1500,
                                                     breakInSeconds: 300,
                                                     longBreakInSeconds: 1200,
                                                     workSessionsCount: 4)
    
    FocusTabItemView(tab: $tab)
        .environmentObject(timer)
}
