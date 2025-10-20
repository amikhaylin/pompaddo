//
//  FocusSounds.swift
//  PomPadDo
//
//  Created by Andrey Mikhaylin on 29.08.2025.
//

import AudioToolbox

struct FocusSounds {
    static func play() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_UserPreferredAlert))
    }
}
