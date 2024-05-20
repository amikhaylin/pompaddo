//
//  BadgeManager.swift
//  test
//
//  Created by Andrey Mikhaylin on 13.03.2024.
//

import SwiftUI
import UserNotifications

actor BadgeManager {
    @MainActor
    func setBadge(number: Int) {
        #if os(macOS)
        NSApplication.shared.dockTile.badgeLabel = "\(number)"
        #else
        NotificationManager.checkAuthorization { authorized in
            if authorized {
                UNUserNotificationCenter.current().setBadgeCount(number)
            }
        }
        #endif
    }
    
    @MainActor
    func resetBadgeNumber() {
        #if os(macOS)
        NSApplication.shared.dockTile.badgeLabel = nil
        #else
        NotificationManager.checkAuthorization { authorized in
            if authorized {
                UNUserNotificationCenter.current().setBadgeCount(0)
            }
        }
        #endif
    }
}
