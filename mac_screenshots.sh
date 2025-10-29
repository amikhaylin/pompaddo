#!/bin/zsh

xcodebuild test -project PomPadDo.xcodeproj -scheme PomPadDo -testPlan PomPadDo -resultBundlePath TestResults

xcodebuild test -project PomPadDo.xcodeproj -scheme PomPadDo -testPlan PomPadDoRU -resultBundlePath TestResultsRU