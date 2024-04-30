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

struct NotificationManager {
    static func setNotification(task: Todo) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                // Set request
                if let alertDate = task.alertDate, (alertDate - Date()) > 0 {
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
    static func checkTaskHasRequest(task: Todo) async -> Bool {
        if task.alertDate != nil {
            let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
            
            for request in requests where request.identifier == task.uid {
                return true
            }
        }
        return false
    }
    
    // TODO: remove old requests
    static func removeRequest(task: Todo) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.uid])
    }
}
