//
//  FocusTimerView.swift
//  PomPadDo.watch Watch App
//
//  Created by Andrey Mikhaylin on 29.08.2025.
//

import SwiftUI

struct FocusTimerView: View {
    @EnvironmentObject var timer: FocusTimer
    @EnvironmentObject var focusTask: FocusTask
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                CircularProgressView(progress: CGFloat(timer.fractionPassed),
                                     color: timer.mode == .work ? .red : .green,
                                     lineWidth: 5)
                .frame(width: 150, height: 150)
                
                VStack {
                    Text("\(timer.secondsLeftString)")
                        .font(.system(size: 50, weight: .semibold, design: .rounded))
                    
                    Text("\(timer.mode.title)")
                        .font(.system(size: 24, weight: .light, design: .rounded))
                        .foregroundStyle(timer.mode == .work ? Color.red : Color.green)
                }
            }
            Spacer()
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                // start
                if timer.state == .idle {
                    Button {
                        timer.start()
                    } label: {
                        Image(systemName: "play.fill")
                    }
                    .padding()
                    .accessibility(identifier: "StartTimerButton")
                }
                // resume
                if timer.state == .paused {
                    Button {
                        timer.resume()
                    } label: {
                        Image(systemName: "play.fill")
                    }
                    .padding()
                    .accessibility(identifier: "ResumeTimerButton")
                }
                // pause
                if timer.state == .running {
                    Button {
                        timer.pause()
                    } label: {
                        Image(systemName: "pause.fill")
                    }
                    .padding()
                    .accessibility(identifier: "PauseTimerButton")
                }
                
                //task
                if let task = focusTask.task {
                    NavigationLink {
                        TaskDetailsView(task: task, list: .focus)
                    } label: {
                        Image(systemName: "checkmark.square")
                    }
                }
                
                // reset / stop
                if timer.state == .running || timer.state == .paused {
                    if timer.mode == .pause || timer.mode == .longbreak {
                        Button {
                            timer.reset()
                            timer.skip()
                            timer.start()
                        } label: {
                            Image(systemName: "forward.fill")
                        }
                        .padding()
                        .accessibility(identifier: "SkipTimerButton")
                    } else {
                        Button {
                            timer.reset()
                            if timer.mode == .pause || timer.mode == .longbreak {
                                timer.skip()
                            }
                        } label: {
                            Image(systemName: "stop.fill")
                        }
                        .padding()
                        .accessibility(identifier: "StopTimerButton")
                    }
                }
            }

        }

    }
}

#Preview {
    @Previewable @StateObject var timer = FocusTimer(workInSeconds: 1500,
                                                     breakInSeconds: 300,
                                                     longBreakInSeconds: 1200,
                                                     workSessionsCount: 4)
    @Previewable @StateObject var focusTask = FocusTask()

    FocusTimerView()
        .environmentObject(timer)
        .environmentObject(focusTask)
}
