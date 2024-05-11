//
//  FocusTimer.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 03.05.2024.
//

import Foundation
import Observation

enum FocusTimerState: String {
    case idle
    case running
    case paused
}

enum FocusTimerMode: String {
    case work
    case pause
    case longbreak

    var title: String {
        switch self {
        case .work:
            return "work"
        case .pause:
            return "break"
        case .longbreak:
            return "long break"
        }
    }
}

@Observable
class FocusTimer {
    // timer -> tick every second
    // properties -> how many seconds left / passed
    //            -> fraction 0-1
    //            -> String ... 10:42
    // methods -> play, pause, resume, reset, skip
    // helper functions

    private(set) var mode: FocusTimerMode = .work
    private(set) var state: FocusTimerState = .idle

    private var durationWork: TimeInterval
    private var durationBreak: TimeInterval
    private var durationLongBreak: TimeInterval
    private var workSessionsCount: Int
    
    private(set) var secondsPassed: Int = 0
    private(set) var fractionPassed: Double = 0
    private var dateStarted: Date = Date.now
    private var secondsPassedBeforePause: Int = 0
    private(set) var sessionsCounter: Int = 0

    private var timer: Timer?
//    private var audio: PomodoroAudio = PomodoroAudio()
  
    init(workInSeconds: TimeInterval, 
         breakInSeconds: TimeInterval,
         longBreakInSeconds: TimeInterval,
         workSessionsCount: Int) {
        self.durationWork = workInSeconds
        self.durationBreak = breakInSeconds
        self.durationLongBreak = longBreakInSeconds
        self.workSessionsCount = workSessionsCount
    }
  
    // MARK: Computed Properties
    var secondsPassedString: String {
        return formatSeconds(_secondsPassed)
    }
    var secondsLeft: Int {
        Int(duration) - _secondsPassed
    }
    var secondsLeftString: String {
        return formatSeconds(secondsLeft)
    }
    var fractionLeft: Double {
        1.0 - fractionPassed
    }
  
    private var duration: TimeInterval {
        if mode == .work {
            return durationWork
        } else if mode == .longbreak {
            return durationLongBreak
        } else {
            return durationBreak
        }
    }
  
    // MARK: Public Methods
    func start() {
        dateStarted = Date.now
        secondsPassed = 0
        fractionPassed = 0
        state = .running
        createTimer()
    }
    
    func resume() {
        dateStarted = Date.now
        state = .running
        createTimer()
    }
    
    func pause() {
        secondsPassedBeforePause = _secondsPassed
        state = .paused
        killTimer()
    }
    
    func reset() {
        secondsPassed = 0
        fractionPassed = 0
        secondsPassedBeforePause = 0
        state = .idle
        killTimer()
    }
    
    func skip() {
        if self.mode == .work {
            if sessionsCounter < workSessionsCount {
                self.mode = .pause
                sessionsCounter += 1
            } else {
                self.mode = .longbreak
                sessionsCounter = 0
            }
        } else {
            self.mode = .work
        }
    }
    
    func repeatTimer() {
        skip()
        secondsPassedBeforePause = 0
        start()
    }
  
    // MARK: private methods
    private func createTimer() {
        // schedule notification
        NotificationManager.removeRequest(identifier: "PomPadDo-Timer")
        NotificationManager.setNotification(timeInterval: TimeInterval(secondsLeft),
                                            identifier: "PomPadDo-Timer",
                                            title: "PomPadDo Timer",
                                            body: "Your focus timer is finished")
        // create timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.onTick()
        }
    }
  
    private func killTimer() {
        NotificationManager.removeRequest(identifier: "PomPadDo-Timer")
        timer?.invalidate()
        timer = nil
    }
  
    private func onTick() {
        // calculate the seconds since start date
        let secondsSinceStartDate = Date.now.timeIntervalSince(self.dateStarted)
        // add the seconds before paused (if any)
        self.secondsPassed = Int(secondsSinceStartDate) + self.secondsPassedBeforePause
        // calculate fraction
        self.fractionPassed = TimeInterval(self.secondsPassed) / self.duration
        // play tick
//    _audio.play(.tick)
        // done? play sound, reset, switch (work->pause->work), reset timer
        if self.secondsLeft == 0 {
//            self.fractionPassed = 0
            self.repeatTimer()
//            self.skip() // to switch mode
//            self.reset() // also resets timer
//        _audio.play(.done) // play ending sound
        }
    }
  
    private func formatSeconds(_ seconds: Int) -> String {
        if seconds <= 0 {
            return "00:00"
        }
        let hours: Int = seconds / 3600
        let minutes: Int = (seconds % 3600) / 60
        let secs: Int = seconds % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
}
