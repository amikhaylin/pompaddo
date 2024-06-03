//
//  FocusTimer.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 03.05.2024.
//  based on PomodoroTimer by Martin B.I.
//

import Foundation
import Observation
import AudioToolbox
import AVKit

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
class FocusTimer: ObservableObject {
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
    private var currentNotificatioId: String = ""

    private var timer: Timer?
  
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
        state = .idle
        killTimer()
        dateStarted = Date.now
        secondsPassed = 0
        fractionPassed = 0
        secondsPassedBeforePause = 0
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
    
    // MARK: private methods
    private func setNotification(removeOld: Bool = false) {
        var dispMode: String = ""
        switch self.mode {
        case .work:
            dispMode = "work session"
        default:
            dispMode = self.mode.title
        }
        if removeOld {
            NotificationManager.removeRequest(identifier: currentNotificatioId)
        }
        currentNotificatioId = UUID().uuidString
        NotificationManager.setNotification(timeInterval: TimeInterval(secondsLeft),
                                            identifier: currentNotificatioId,
                                            title: "PomPadDo Timer",
                                            body: "Your \(dispMode) is finished")
    }
    
    private func createTimer() {
        // schedule notification
        setNotification(removeOld: true)
        // create timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[self] _ in
            self.onTick()
        }
    }
  
    private func killTimer() {
        NotificationManager.removeRequest(identifier: currentNotificatioId)
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
        // done? play sound, reset, switch (work->pause->work), reset timer
        if self.secondsLeft == 0 {
            #if os(macOS)
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_UserPreferredAlert))
            #else
            AudioServicesPlaySystemSound(SystemSoundID(1002))
            #endif
            
            self.fractionPassed = 0
            self.secondsPassedBeforePause = 0
            self.skip() // to switch mode
            dateStarted = Date.now
            secondsPassed = 0
            fractionPassed = 0
            state = .running
            setNotification()
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
