//
//  FocusTabItemView.swift
//  PomPadDoiOS
//
//  Created by Andrey Mikhaylin on 21.09.2024.
//

import SwiftUI

struct FocusTabItemView: View {
    @Environment(\.openURL) private var openURL
    @Environment(FocusTimer.self) var timer
    @State private var timerCount: String = ""
    
    @AppStorage("scWork") var scWork: Bool = false
    @AppStorage("scWorkName") var scWorkName: String = ""
    
    @AppStorage("scBreak") var scBreak: Bool = false
    @AppStorage("scBreakName") var scBreakName: String = ""

    @AppStorage("scPause") var scPause: Bool = false
    @AppStorage("scPauseName") var scPauseName: String = ""

    @AppStorage("scResume") var scResume: Bool = false
    @AppStorage("scResumeName") var scResumeName: String = ""
    
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
        .onChange(of: timer.mode, { _, newValue in
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
        .onChange(of: timer.state) { _, newValue in
            switch newValue {
            case .running:
                if scResume {
                    runShortcut(scResumeName)
                }
            case .paused:
                if scPause {
                    runShortcut(scPauseName)
                }
            default:
                break
            }
        }
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
        
        openURL(url) { accepted in
            print(accepted ? "Success" : "Failure")
        }
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
