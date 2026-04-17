//
//  FocusTimerTests.swift
//  PomPadDoTests
//
//  Created by Andrey Mikhaylin on 04.03.2026.
//

import Testing
import Dispatch
@testable import PomPadDo

@Suite("FocusTimerTests")
struct FocusTimerTests {
    @Test("Initial state uses work duration and zero progress")
    @MainActor
    func initialState() {
        let timer = FocusTimer(workInSeconds: 150,
                               breakInSeconds: 60,
                               longBreakInSeconds: 300,
                               workSessionsCount: 4)

        #expect(timer.mode == .work)
        #expect(timer.state == .idle)
        #expect(timer.secondsPassed == 0)
        #expect(timer.fractionPassed == 0)
        #expect(timer.fractionLeft == 1)
        #expect(timer.secondsLeft == 150)
        #expect(timer.secondsPassedString == "00:00")
        #expect(timer.secondsLeftString == "02:30")
    }

    @Test("setDurations updates secondsLeft for current mode")
    @MainActor
    func setDurationsUpdatesModeDurations() {
        let timer = FocusTimer(workInSeconds: 10,
                               breakInSeconds: 5,
                               longBreakInSeconds: 7,
                               workSessionsCount: 2)

        timer.setDurations(workInSeconds: 120,
                           breakInSeconds: 30,
                           longBreakInSeconds: 45,
                           workSessionsCount: 2)
        #expect(timer.secondsLeft == 120)

        timer.skip() // work -> pause
        #expect(timer.mode == .pause)
        #expect(timer.secondsLeft == 30)

        timer.skip() // pause -> work
        timer.skip() // work -> pause (session 2)
        timer.skip() // pause -> work
        timer.skip() // work -> longbreak
        #expect(timer.mode == .longbreak)
        #expect(timer.secondsLeft == 45)
    }

    @Test("skip cycles work -> pause and eventually longbreak")
    @MainActor
    func skipCyclesModesAndSessionsCounter() {
        let timer = FocusTimer(workInSeconds: 10,
                               breakInSeconds: 5,
                               longBreakInSeconds: 20,
                               workSessionsCount: 2)

        #expect(timer.mode == .work)
        #expect(timer.sessionsCounter == 0)

        timer.skip() // work -> pause
        #expect(timer.mode == .pause)
        #expect(timer.sessionsCounter == 1)

        timer.skip() // pause -> work
        #expect(timer.mode == .work)
        #expect(timer.sessionsCounter == 1)

        timer.skip() // work -> pause
        #expect(timer.mode == .pause)
        #expect(timer.sessionsCounter == 2)

        timer.skip() // pause -> work
        timer.skip() // work -> longbreak
        #expect(timer.mode == .longbreak)
        #expect(timer.sessionsCounter == 0)

        timer.skip() // longbreak -> work
        #expect(timer.mode == .work)
        #expect(timer.sessionsCounter == 0)
    }

    @Test("start begins ticking and updates progress")
    @MainActor
    func startRunsTimerTask() async {
        let timer = FocusTimer(workInSeconds: 10,
                               breakInSeconds: 5,
                               longBreakInSeconds: 20,
                               workSessionsCount: 2)
        defer { timer.reset() }

        timer.start()

        #expect(timer.state == .running)
        #expect(timer.secondsPassed == 0)

        let didTick = await waitUntil {
            timer.secondsPassed >= 1
        }

        #expect(didTick)
        #expect(timer.fractionPassed > 0)
        #expect(timer.secondsLeft < 10)
    }

    @Test("pause freezes elapsed time, resume continues")
    @MainActor
    func pauseAndResume() async {
        let timer = FocusTimer(workInSeconds: 10,
                               breakInSeconds: 5,
                               longBreakInSeconds: 20,
                               workSessionsCount: 2)
        defer { timer.reset() }

        timer.start()
        let didTick = await waitUntil {
            timer.secondsPassed >= 1
        }
        #expect(didTick)

        timer.pause()
        let elapsedAtPause = timer.secondsPassed
        #expect(timer.state == .paused)

        try? await Task.sleep(nanoseconds: 1_200_000_000)
        #expect(timer.secondsPassed == elapsedAtPause)

        timer.resume()
        #expect(timer.state == .running)

        let didResumeTick = await waitUntil {
            timer.secondsPassed > elapsedAtPause
        }
        #expect(didResumeTick)
    }

    @Test("reset returns timer to idle and clears progress")
    @MainActor
    func resetClearsProgress() async {
        let timer = FocusTimer(workInSeconds: 10,
                               breakInSeconds: 5,
                               longBreakInSeconds: 20,
                               workSessionsCount: 2)

        timer.start()
        let didTick = await waitUntil {
            timer.secondsPassed >= 1
        }
        #expect(didTick)
        #expect(timer.state == .running)

        timer.reset()

        #expect(timer.state == .idle)
        #expect(timer.mode == .work)
        #expect(timer.secondsPassed == 0)
        #expect(timer.fractionPassed == 0)
        #expect(timer.fractionLeft == 1)
        #expect(timer.secondsLeft == 10)
        #expect(timer.secondsPassedString == "00:00")
    }

    @Test("receiveState + start keeps transferred timer in sync")
    @MainActor
    func receiveStateThenStartKeepsTimersAligned() async {
        let timer1 = FocusTimer(workInSeconds: 120,
                                breakInSeconds: 60,
                                longBreakInSeconds: 180,
                                workSessionsCount: 4)
        let timer2 = FocusTimer(workInSeconds: 120,
                                breakInSeconds: 60,
                                longBreakInSeconds: 180,
                                workSessionsCount: 4)
        defer {
            timer1.reset()
            timer2.reset()
        }

        timer1.start()
        try? await Task.sleep(nanoseconds: 150_000_000)

        timer2.receiveState(mode: timer1.mode,
                            state: timer1.state,
                            dateStarted: timer1.dateStarted,
                            secondsPassedBeforePause: timer1.secondsPassedBeforePause)

        #expect(timer2.mode == timer1.mode)
        #expect(timer2.state == timer1.state)
        #expect(timer2.dateStarted == timer1.dateStarted)
        #expect(timer2.secondsPassedBeforePause == timer1.secondsPassedBeforePause)

        timer2.start()

        let bothTicked = await waitUntil {
            timer1.secondsPassed >= 1 && timer2.secondsPassed >= 1
        }
        #expect(bothTicked)

        #expect(timer1.mode == timer2.mode)
        #expect(timer1.state == timer2.state)
        #expect(timer1.secondsPassed == timer2.secondsPassed)
        #expect(timer1.secondsLeft == timer2.secondsLeft)
        #expect(timer1.secondsLeftString == timer2.secondsLeftString)
    }

    @Test("synchronizeToCurrentTime advances mode after missed running time")
    @MainActor
    func synchronizeToCurrentTimeAdvancesSingleTransition() {
        let timer = FocusTimer(workInSeconds: 10,
                               breakInSeconds: 5,
                               longBreakInSeconds: 20,
                               workSessionsCount: 2)

        timer.receiveState(mode: .work,
                           state: .running,
                           dateStarted: .now.addingTimeInterval(-12),
                           secondsPassedBeforePause: 0)

        timer.synchronizeToCurrentTime()

        #expect(timer.mode == .pause)
        #expect(timer.sessionsCounter == 1)
        #expect(timer.secondsPassed == 2)
        #expect(timer.secondsLeft == 3)
    }

    @Test("synchronizeToCurrentTime handles multiple transitions")
    @MainActor
    func synchronizeToCurrentTimeAdvancesMultipleTransitions() {
        let timer = FocusTimer(workInSeconds: 10,
                               breakInSeconds: 5,
                               longBreakInSeconds: 20,
                               workSessionsCount: 2)

        timer.receiveState(mode: .work,
                           state: .running,
                           dateStarted: .now.addingTimeInterval(-37),
                           secondsPassedBeforePause: 0)

        timer.synchronizeToCurrentTime()

        #expect(timer.mode == .work)
        #expect(timer.sessionsCounter == 2)
        #expect(timer.secondsPassed == 7)
        #expect(timer.secondsLeft == 3)
    }

    @MainActor
    private func waitUntil(timeoutNanoseconds: UInt64 = 3_000_000_000,
                           pollNanoseconds: UInt64 = 50_000_000,
                           _ condition: @escaping () -> Bool) async -> Bool {
        let deadline = DispatchTime.now().uptimeNanoseconds + timeoutNanoseconds
        while DispatchTime.now().uptimeNanoseconds < deadline {
            if condition() {
                return true
            }
            try? await Task.sleep(nanoseconds: pollNanoseconds)
        }
        return condition()
    }
}
