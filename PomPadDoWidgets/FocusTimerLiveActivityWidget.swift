#if os(iOS) && canImport(ActivityKit)
import ActivityKit
import SwiftUI
import WidgetKit

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

private enum FocusTimerLiveActivityMode: String {
    case work
    case pause
    case longbreak

    var title: String {
        switch self {
        case .work:
            NSLocalizedString("work", comment: "")
        case .pause:
            NSLocalizedString("break", comment: "")
        case .longbreak:
            NSLocalizedString("long break", comment: "")
        }
    }

    var symbolName: String {
        switch self {
        case .work:
            "tomato.fill"
        case .pause, .longbreak:
            "cup.and.saucer.fill"
        }
    }
}

private enum FocusTimerLiveActivityState: String {
    case running
    case paused
    case idle
}

private struct FocusTimerLiveActivityHeaderView: View {
    let mode: FocusTimerLiveActivityMode

    var body: some View {
        if mode == .work {
            Label(mode.title, image: mode.symbolName)
                .symbolRenderingMode(.multicolor)
                .foregroundStyle(mode == .work ? Color.red : Color.green)
                .lineLimit(1)
        } else {
            Label(mode.title, systemImage: mode.symbolName)
                .foregroundStyle(mode == .work ? Color.red : Color.green)
                .lineLimit(1)
        }
    }
}

private struct FocusTimerLiveActivityTimeView: View {
    let state: FocusTimerLiveActivityAttributes.ContentState

    var body: some View {
        if timerState == .running {
            Text(timerInterval: state.startDate...state.endDate, countsDown: true)
                .monospacedDigit()
        } else {
            Text(Duration.seconds(Double(state.remainingSeconds)),
                 format: .time(pattern: state.remainingSeconds >= 3600 ? .hourMinuteSecond : .minuteSecond))
                .monospacedDigit()
        }
    }

    private var timerState: FocusTimerLiveActivityState {
        FocusTimerLiveActivityState(rawValue: state.timerState) ?? .idle
    }
}

private struct FocusTimerLiveActivityProgressView: View {
    let state: FocusTimerLiveActivityAttributes.ContentState

    var body: some View {
        if timerState == .running {
            ProgressView(timerInterval: state.startDate...state.endDate, countsDown: true)
        } else {
            ProgressView(value: pausedProgress)
        }
    }

    private var timerState: FocusTimerLiveActivityState {
        FocusTimerLiveActivityState(rawValue: state.timerState) ?? .idle
    }

    private var pausedProgress: Double {
        guard state.durationSeconds > 0 else { return 0 }
        return Double(state.durationSeconds - state.remainingSeconds) / Double(state.durationSeconds)
    }
}

private struct FocusTimerLiveActivityLockScreenView: View {
    let state: FocusTimerLiveActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FocusTimerLiveActivityHeaderView(mode: timerMode)
                Spacer()
                FocusTimerLiveActivityTimeView(state: state)
            }
            FocusTimerLiveActivityProgressView(state: state)
        }
        .padding()
    }

    private var timerMode: FocusTimerLiveActivityMode {
        FocusTimerLiveActivityMode(rawValue: state.mode) ?? .work
    }
}

struct FocusTimerLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusTimerLiveActivityAttributes.self) { context in
            FocusTimerLiveActivityLockScreenView(state: context.state)
                .activityBackgroundTint(.clear)
                .activitySystemActionForegroundColor(.primary)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    FocusTimerLiveActivityHeaderView(mode: FocusTimerLiveActivityMode(rawValue: context.state.mode) ?? .work)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    FocusTimerLiveActivityTimeView(state: context.state)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    FocusTimerLiveActivityProgressView(state: context.state)
                }
            } compactLeading: {
                if FocusTimerLiveActivityMode(rawValue: context.state.mode) ?? .work == .work {
                    Image((FocusTimerLiveActivityMode(rawValue: context.state.mode) ?? .work).symbolName)
                        .symbolRenderingMode(.multicolor)
                } else {
                    Image(systemName: (FocusTimerLiveActivityMode(rawValue: context.state.mode) ?? .work).symbolName)
                        .foregroundStyle(Color.green)
                }
            } compactTrailing: {
                FocusTimerLiveActivityTimeView(state: context.state)
                    .foregroundStyle(FocusTimerLiveActivityMode(rawValue: context.state.mode) ?? .work == .work ? Color.red : Color.green)
                    .lineLimit(1)
            } minimal: {
                if FocusTimerLiveActivityMode(rawValue: context.state.mode) ?? .work == .work {
                    Image((FocusTimerLiveActivityMode(rawValue: context.state.mode) ?? .work).symbolName)
                        .symbolRenderingMode(.multicolor)
                } else {
                    Image(systemName: (FocusTimerLiveActivityMode(rawValue: context.state.mode) ?? .work).symbolName)
                        .foregroundStyle(Color.green)
                }
            }
        }
    }
}
#endif
