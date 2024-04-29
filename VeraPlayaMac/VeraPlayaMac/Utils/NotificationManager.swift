//
//  NotofocationManager.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 29.04.2024.
//

import Foundation
import UserNotifications

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

actor NotificationManager {
    func setNotification(task: Todo) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                // Set request
                if let alertDate = task.alertDate {
                    let content = UNMutableNotificationContent()
                    content.title = "PomPadDo"
                    content.subtitle = task.name
                    content.sound = UNNotificationSound.default
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (alertDate - Date()), repeats: false)
                    
                    let request = UNNotificationRequest(identifier: task.uid,
                                                        content: content,
                                                        trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request)
                }
            } else if let error {
                print(error.localizedDescription)
            }
        }
    }
    
    // TODO: check if task in requests
    func checkTaskHasRequest(task: Todo) -> Bool {
        var result = false
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                if request.identifier == task.uid {
                    result = true
                }
            }
        }
        return result
    }
}
