//
//  ContentView2.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-08.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppService.self) private var appService: AppService
    var notificationManager = NotificationManager.shared
    
    var body: some View {
        ZStack {
            // Check if appService is ready
            if !appService.isReady {
                VStack {
                    //    Spacer()
                    //   IntroView(onFinished: {})
                    Spacer()
                    ProgressView(value: appService.progress)
                        .onAppear {
                            appService.startApplication()
                        }
                    Text(appService.message)
                    Spacer()
                }
                .frame(width: 350)
                
            } else {
                ScreenView()
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
//        .onChange(of: iCloudService.shared.iCloudStatus) { b, a in
//            if b != .available && a == .available {
//                appService.startApplication()
//            }
//        }
    }
}

#Preview {
    ContentView()
        .environment(AppService())
        .environment(AppDataService())
}
