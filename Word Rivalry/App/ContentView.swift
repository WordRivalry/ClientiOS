//
//  ContentView2.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-08.
//

import SwiftUI

struct ContentView: View {
    // Handle the entire color scheme of the app
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
    @Environment(AppServiceManager.self) private var appService: AppServiceManager
    var notificationManager = NotificationManager.shared
    
    @State var showNoInternet = false
    
    @State private var appScreen: AppScreen? = .home
    
    var body: some View {
        ZStack {
            if appService.isReady {
                Group {
                    switch appService.screenToDisplay {
                    case .noIcloud:
                        IcloudStatusMessageView()
                    case .noInternet:
                        InternetStatusMessageView(message: "For profile creation")
                    case .main:
                        AppTabView(selection: $appScreen)
                            .environment(appService.profileDataService.ppLocal.player!)
                            .environment(appService.profileDataService.swiftData.profile!)
                            .environment(appService.audioService)
                            .environment((appService.jitData.getService(for: .leaderboard) as LeaderboardService))
                            .environment((appService.jitData.getService(for: .achievements) as AchievementsService))
                    case .error:
                        Text("An error occured")
                    }
                }
            } else {
                VStack {
                    Spacer()
                    ProgressView(value: appService.progress)
                        .onAppear {Task{
                            await self.appService.start()
                        }}
                    Text(appService.messages.last ?? "Nothing to worry!")
                    Spacer()
                }
                .frame(width: 350)
                
                .transition(.opacity)
                .preferredColorScheme(colorSchemeManager.getPreferredColorScheme())
                
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

#Preview {
    let jitDataService = JITDataService<JITDataType>()
    jitDataService.registerService(LeaderboardService(), forType: .leaderboard)
    jitDataService.registerService(AchievementsService(), forType: .achievements)
    
    return ContentView()
        .environment(
            AppServiceManager(
                audioService: AudioSessionService(),
                profileDataService: ProfileDataService(),
                jitData: jitDataService
            )
        )
}
