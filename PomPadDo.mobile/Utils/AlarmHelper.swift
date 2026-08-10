//
//  AlarmHelper.swift
//  PomPadDo
//
//  Created by Andrey Mikhaylin on 05.08.2026.
//

import AlarmKit

struct TimerData: AlarmMetadata {

}

struct AlarmHelper {
//    static func checkAuthorization(completion: @escaping (Bool) -> Void) {
//        switch AlarmManager.shared.authorizationState {
//        case .notDetermined:
//            Task {
//                try? await AlarmManager.shared.requestAuthorization()
//            }
//        case .authorized:
//            completion(true)
//        case .denied:
//            completion(false)
//        default:
//            completion(false)
//        }
//    }
    
    static func checkAuthorization() -> Bool {
        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            Task {
                try? await AlarmManager.shared.requestAuthorization()
            }
        case .authorized:
            return true
        case .denied:
            return false
        default:
            return false
        }
        return false
    }


//    static func setAlarm(timeInterval: TimeInterval, identifier: String, title: String, body: String) {
//        checkAuthorization { authorized in
//            if authorized {
//                let duration = Alarm.CountdownDuration(preAlert: timeInterval, postAlert: 1)
//
//                // Create a Dismiss button
//                let stopButton = AlarmButton(
//                    text: "Dismiss",              // button label
//                    textColor: .white,            // button text color
//                    systemImageName: "stop.circle" // SF Symbol icon
//                )
//
//                // Create the alert presentation
//                let alertPresentation = AlarmPresentation.Alert(
//                    title: LocalizedStringResource(stringLiteral: title),         // shown in alert + Dynamic Island
//                    stopButton: stopButton
//                )
//
//                // Bundle presentation & style into attributes
//                let attributes = AlarmAttributes<TimerData>(
//                    presentation: AlarmPresentation(alert: alertPresentation),
//                    tintColor: .green  // used for UI accents and button highlights
//                )
//
//                // Combine everything into an alarm config
//                let alarmConfiguration = AlarmManager.AlarmConfiguration(
//                    countdownDuration: duration,
//                    attributes: attributes
//                )
//                
//                guard let id = UUID(uuidString: identifier) else { return }
//                
//                // Schedule it with the system
//                try await AlarmManager.shared.schedule(id: id, configuration: alarmConfiguration)
//            }
//        }
//    }
    
    static func setAlarm(timeInterval: TimeInterval, identifier: String, title: String, body: String) async throws {
        if checkAuthorization() {
                let duration = Alarm.CountdownDuration(preAlert: timeInterval, postAlert: 1)

                // Create a Dismiss button
                let stopButton = AlarmButton(
                    text: "Dismiss",              // button label
                    textColor: .white,            // button text color
                    systemImageName: "stop.circle" // SF Symbol icon
                )

                // Create the alert presentation
                let alertPresentation = AlarmPresentation.Alert(
                    title: LocalizedStringResource(stringLiteral: title),         // shown in alert + Dynamic Island
                    stopButton: stopButton
                )

                // Bundle presentation & style into attributes
                let attributes = AlarmAttributes<TimerData>(
                    presentation: AlarmPresentation(alert: alertPresentation),
                    tintColor: .green  // used for UI accents and button highlights
                )

                // Combine everything into an alarm config
                let alarmConfiguration = AlarmManager.AlarmConfiguration(
                    countdownDuration: duration,
                    attributes: attributes
                )
                
                guard let id = UUID(uuidString: identifier) else { return }
                
                // Schedule it with the system
                try await AlarmManager.shared.schedule(id: id, configuration: alarmConfiguration)
        }
    }

    // remove old requests
    static func removeAlarm(identifier: String) {
        guard let id = UUID(uuidString: identifier) else { return }
        try? AlarmManager.shared.cancel(id: id)
    }
}
