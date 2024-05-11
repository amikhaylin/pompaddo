//
//  BadgeManager.swift
//  test
//
//  Created by Andrey Mikhaylin on 13.03.2024.
//

import SwiftUI

actor BadgeManager {
    @MainActor
    func setBadge(number: Int) {
        NSApplication.shared.dockTile.badgeLabel = "\(number)"
    }
    
    @MainActor
    func resetBadgeNumber() {
        NSApplication.shared.dockTile.badgeLabel = nil
    }
}
