//
//  FocusTimer.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 03.05.2024.
//  based on PomodoroTimer by Martin B.I.
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
            return NSLocalizedString("work", comment: "")
        case .pause:
            return NSLocalizedString("break", comment: "")
        case .longbreak:
            return NSLocalizedString("long break", comment: "")
        }
    }
}

@MainActor
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
    private var currentDate: Date = Calendar.current.startOfDay(for: Date.now)
    private var secondsPassedBeforePause: Int = 0
    private(set) var sessionsCounter: Int = 0
    private var currentNotificationId: String = ""

    private var timerTask: Task<Void, Never>?
  
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
        return Common.formatSeconds(_secondsPassed)
    }
    var secondsLeft: Int {
        Int(duration) - _secondsPassed
    }
    var secondsLeftString: String {
        return Common.formatSeconds(secondsLeft)
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
    func setDurations(workInSeconds: TimeInterval,
                      breakInSeconds: TimeInterval,
                      longBreakInSeconds: TimeInterval,
                      workSessionsCount: Int) {
        self.durationWork = workInSeconds
        self.durationBreak = breakInSeconds
        self.durationLongBreak = longBreakInSeconds
        self.workSessionsCount = workSessionsCount
    }
    
    func start() {
        let today = Calendar.current.startOfDay(for: Date.now)
        if !Calendar.current.isDate(today, inSameDayAs: currentDate) {
            currentDate = today
            sessionsCounter = 0
        }
        
        dateStarted = Date.now
        secondsPassed = 0
        fractionPassed = 0
        state = .running
        startTimer()
    }
    
    func resume() {
        dateStarted = Date.now
        state = .running
        startTimer()
    }
    
    func pause() {
        secondsPassedBeforePause = _secondsPassed
        state = .paused
        stopTimer()
    }
    
    func reset() {
        state = .idle
        stopTimer()
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
    
    func setNotification(removeOld: Bool = false) {
        var dispMode: String = ""
        switch self.mode {
        case .work:
            dispMode = "work session"
        default:
            dispMode = self.mode.title
        }
        if removeOld {
            NotificationManager.removeRequest(identifier: self.currentNotificationId)
        }
        self.currentNotificationId = UUID().uuidString
        NotificationManager.setNotification(timeInterval: TimeInterval(self.secondsLeft),
                                            identifier: self.currentNotificationId,
                                            title: "PomPadDo Timer",
                                            body: NSLocalizedString("Your \(dispMode) is finished", comment: ""))
    }
    
    func removeNotification() {
        NotificationManager.removeRequest(identifier: self.currentNotificationId)
    }

    // MARK: private methods
    private func startTimer() {
        stopTimer()
        
        timerTask = Task(priority: .background) { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                
                await MainActor.run {
                    self?.onTick()
                }
            }
        }
    }
    
    private func stopTimer() {
        NotificationManager.removeRequest(identifier: currentNotificationId)
        timerTask?.cancel()
        timerTask = nil
    }
  
    private func onTick() {
        DispatchQueue.main.async {
            // calculate the seconds since start date
            let secondsSinceStartDate = Date.now.timeIntervalSince(self.dateStarted)
            // add the seconds before paused (if any)
            self.secondsPassed = Int(secondsSinceStartDate) + self.secondsPassedBeforePause
            // calculate fraction
            self.fractionPassed = TimeInterval(self.secondsPassed) / self.duration
            // done? play sound, reset, switch (work->pause->work), reset timer
            if self.secondsLeft <= 0 {
                FocusSounds.play()
                
                self.fractionPassed = 0
                self.secondsPassedBeforePause = 0
                self.skip() // to switch mode
                self.dateStarted = Date.now
                self.secondsPassed = 0
                self.fractionPassed = 0
                self.state = .running
            } else if self.secondsLeft == 2 {
                self.setNotification()
            }
        }
    }
}
