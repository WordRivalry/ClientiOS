//
//  AchievementNotificationView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-02.
//

import SwiftUI

@Observable
class NotificationManager {
    static let shared = NotificationManager()
    var showNotification: Bool = false
    var currentAchievementName: AchievementName = .ButtonClicker
    
    func triggerNotification(for achievementName: AchievementName) {
        currentAchievementName = achievementName
        showNotification = true
        
        // Automatically hide the notification after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showNotification = false
        }
    }
}

struct AchievementNotificationView: View {
    var achievementName: AchievementName

    var body: some View {
        VStack {
            Text("Achievement Unlocked!")
                .font(.headline)
                .foregroundColor(.white)
            Text("You've unlocked: \(achievementName.rawValue)")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.blue)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
    }
}

#Preview {
    AchievementNotificationView(achievementName: .ButtonClicker)
}
