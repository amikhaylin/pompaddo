# Project: PomPadDo

## Technology stack
- **Language:** Swift 6
- **UI Framework:** SwiftUI
- **Localization:** SwiftUI Localization (используются `Text("key")`)
- **Local Database:** SwiftData
- **Multithreading:** `@MainActor`, async/await

## Project structure (folders)
- **Shared**: Shared files
- **PomPadDo**: macOS implementation
- **PomPadDo.safari**: macOS Safari extension
- **PomPadDo.mobile**: iOS/iPadOS implementation
- **PomPadDo.mobileUITests**: iOS/iPadOS UI tests
- **PomPadDo.Tests**: Unit tests
- **PomPadDo.watch Watch App**: watchOS implementation
- **PomPadDoWidgets**: iOS/iPadOS widgets
- **PomPadDoWatchWidgets**: watchOS widgets
- **PomPadDo.mobile.share**: iOS/iPadOS share extension

## Important files
- **Focus Timer**: `Shared/Activities/Focus/FocusTimer.swift`
- **Focus Timer Tests**: `PomPadDo.Tests/FocusTimerTests.swift`

## Testing notes
- Run FocusTimer tests:
  - `xcodebuild test -project PomPadDo.xcodeproj -scheme PomPadDo -destination 'platform=macOS' -only-testing:PomPadDoTests/FocusTimerTests CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=''`
- Covered FocusTimer transfer scenario:
  - Start timer `T1`, wait, create `T2`, call `receiveState(mode:state:dateStarted:secondsPassedBeforePause:)` from `T1`, start `T2`, then assert both timers stay aligned (`mode`, `state`, `secondsPassed`, `secondsLeft`).
