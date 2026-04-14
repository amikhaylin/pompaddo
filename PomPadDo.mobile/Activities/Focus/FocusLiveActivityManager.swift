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
    private var activityId: String?

    init() {
        activityId = Activity<FocusTimerLiveActivityAttributes>.activities.first?.id
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

        if let updatedActivityId = await Self.updateCurrentActivity(content, matching: activityId) {
            activityId = updatedActivityId
        } else {
            do {
                let requestedActivity = try Self.requestNewActivity(content)
                activityId = requestedActivity.id
            } catch {
                return
            }
        }
    }

    private func endActivities() async {
        await Self.endAllActivities()
        activityId = nil
    }

    private nonisolated static func updateCurrentActivity(
        _ content: ActivityContent<FocusTimerLiveActivityAttributes.ContentState>,
        matching activityId: String?
    ) async -> String? {
        let activities = Activity<FocusTimerLiveActivityAttributes>.activities
        let activity = activities.first(where: { $0.id == activityId }) ?? activities.first
        guard let activity else { return nil }

        await activity.update(content)
        return activity.id
    }

    private nonisolated static func requestNewActivity(
        _ content: ActivityContent<FocusTimerLiveActivityAttributes.ContentState>
    ) throws -> Activity<FocusTimerLiveActivityAttributes> {
        try Activity<FocusTimerLiveActivityAttributes>.request(
            attributes: FocusTimerLiveActivityAttributes(title: "PomPadDo Timer"),
            content: content,
            pushType: nil
        )
    }

    private nonisolated static func endAllActivities() async {
        for activity in Activity<FocusTimerLiveActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
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
