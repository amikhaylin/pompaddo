//
//  FocusSounds.swift
//  PomPadDo.watch Watch App
//
//  Created by Andrey Mikhaylin on 29.08.2025.
//

import WatchKit

struct FocusSounds {
    static func play() {
        WKInterfaceDevice.current().play(.success)
    }
}

