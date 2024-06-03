//
//  NotofocationManager.swift
//  PomPadDoMac
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
    static func checkAuthorization(completion: @escaping (Bool) -> Void) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                completion(true)
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { allowed, error in
                    if let error {
                        print(error.localizedDescription)
                    }
                    completion(allowed)
                }
            default:
                completion(false)
            }
        }
    }
    
    static func setNotification(timeInterval: TimeInterval, identifier: String, title: String, body: String) {
        checkAuthorization { authorized in
            if authorized {
                let notificationCenter = UNUserNotificationCenter.current()
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
                
                let request = UNNotificationRequest(identifier: identifier,
                                                    content: content,
                                                    trigger: trigger)
                
                notificationCenter.add(request)
            }
        }
    }
    
    static func setTaskNotification(task: Todo) {
        // Set request
        if let alertDate = task.alertDate, (alertDate - Date()) > 0 {
            setNotification(timeInterval: (alertDate - Date()),
                            identifier: task.uid,
                            title: "PomPadDo Task",
                            body: task.name)
        }
    }
    
    // check if task in requests
    static func checkTaskHasRequest(task: Todo) async -> Bool {
        if task.alertDate != nil {
            let notificationCenter = UNUserNotificationCenter.current()
            let requests = await notificationCenter.pendingNotificationRequests()
            
            for request in requests where request.identifier == task.uid {
                return true
            }
        }
        return false
    }
    
    // remove old requests
    static func removeRequest(identifier: String) {
        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
