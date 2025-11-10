//
//  ReviewManager.swift
//  PomPadDo.mobile
//
//  Created by Andrey Mikhaylin on 10.11.2025.
//

import SwiftUI
import StoreKit

class ReviewManager: ObservableObject {
    private let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let userDefaults = UserDefaults.standard
    private let daysThreshold = 1
    
    @MainActor func appLaunched() {
        checkForReview()
    }
    
    @MainActor private func checkForReview() {
        // Получаем данные для текущей версии
        let versionKey = "appVersion_\(currentVersion)"
        let firstLaunchDateKey = "\(versionKey)_firstLaunch"
        let reviewRequestedKey = "\(versionKey)_reviewRequested"
        
        let firstLaunchDate = userDefaults.object(forKey: firstLaunchDateKey) as? Date
        let hasRequestedReview = userDefaults.bool(forKey: reviewRequestedKey)
        
        let now = Date()
        
        // Если это первый запуск версии - сохраняем дату
        if firstLaunchDate == nil {
            userDefaults.set(now, forKey: firstLaunchDateKey)
            return
        }
        
        // Проверяем условия для показа ревью
        guard !hasRequestedReview,
              let firstLaunch = firstLaunchDate,
              let daysSinceFirstLaunch = Calendar.current.dateComponents([.day], from: firstLaunch, to: now).day,
              daysSinceFirstLaunch >= daysThreshold else { return }
        
        // Запрашиваем ревью
        if let scene = UIApplication.shared.connectedScenes.first(where: {
            $0.activationState == .foregroundActive
        }) as? UIWindowScene {
            AppStore.requestReview(in: scene)
            userDefaults.set(true, forKey: reviewRequestedKey)
        }
    }
}
