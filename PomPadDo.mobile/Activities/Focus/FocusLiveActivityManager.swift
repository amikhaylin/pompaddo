#if os(iOS) && canImport(ActivityKit)
import ActivityKit
import Foundation

struct FocusTimerLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var mode: String
        var timerState: String
        var startDate: Date
        var endDate: Date
        var remainingSeconds: Int
        var durationSeconds: Int
    }

    var title: String
}

@MainActor
final class FocusLiveActivityManager {
    private var activity: Activity<FocusTimerLiveActivityAttributes>?

    init() {
        activity = Activity<FocusTimerLiveActivityAttributes>.activities.first
    }

    func synchronize(with timer: FocusTimer) {
        Task {
            await synchronizeActivity(with: timer)
        }
    }

    func end() {
        Task {
            await endActivities()
        }
    }

    private func synchronizeActivity(with timer: FocusTimer) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            await endActivities()
            return
        }

        switch timer.state {
        case .running, .paused:
            await startOrUpdateActivity(with: timer)
        case .idle:
            await endActivities()
        }
    }

    private func startOrUpdateActivity(with timer: FocusTimer) async {
        let contentState = makeContentState(from: timer)
        let staleDate = timer.state == .running ? contentState.endDate : nil
        let content = ActivityContent(state: contentState, staleDate: staleDate)

        if activity == nil {
            activity = Activity<FocusTimerLiveActivityAttributes>.activities.first
        }

        if let activity {
            await activity.update(content)
        } else {
            do {
                activity = try Activity.request(attributes: .init(title: "PomPadDo Timer"),
                                                content: content,
                                                pushType: nil)
            } catch {
                return
            }
        }
    }

    private func endActivities() async {
        for existingActivity in Activity<FocusTimerLiveActivityAttributes>.activities {
            await existingActivity.end(nil, dismissalPolicy: .immediate)
        }
        activity = nil
    }

    private func makeContentState(from timer: FocusTimer) -> FocusTimerLiveActivityAttributes.ContentState {
        let durationSeconds = max(1, timer.currentDurationSeconds)
        let elapsedSeconds = min(max(0, timer.secondsPassed), durationSeconds)
        let remainingSeconds = max(0, durationSeconds - elapsedSeconds)

        let startDate = Date.now.addingTimeInterval(-TimeInterval(elapsedSeconds))
        let endDate = startDate.addingTimeInterval(TimeInterval(durationSeconds))

        return .init(mode: timer.mode.rawValue,
                     timerState: timer.state.rawValue,
                     startDate: startDate,
                     endDate: endDate,
                     remainingSeconds: remainingSeconds,
                     durationSeconds: durationSeconds)
    }
}
#endif
