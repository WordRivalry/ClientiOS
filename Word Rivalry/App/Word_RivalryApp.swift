//
//  Word_RivalryApp.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-29.
//

import SwiftUI
import SwiftData

@main
struct Word_RivalryApp: App {
    var notificationManager = NotificationManager.shared
    let appService = AppService()
    
    init() {}
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Check if appService is ready
                if !appService.isReady {
                    VStack {
                        ProgressView(value: appService.progress, total: 1)
                            .onAppear {
                                appService.startApplication()
                            }
                        Text(appService.message)
                    }
                    .frame(width: 400)
                  
                } else {
                    ContentView()
                        // When appService is ready, services MUST be available
                        .environment(appService.services!.launchService)
                        .environment(appService.services!.audioService)
                    
                    if notificationManager.showNotification {
                        AchievementNotificationView(achievementName: notificationManager.currentAchievementName)
                            .transition(.move(edge: .top))
                            .animation(.easeOut, value: notificationManager.showNotification)
                            .zIndex(1) // Ensure notification appears above other content
                    }
                }
            }
        }
    }
}
