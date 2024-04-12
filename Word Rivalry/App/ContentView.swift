//
//  ContentView2.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-08.
//

import SwiftUI
import Combine
import OSLog

struct ContentView: View {
    // Handle the entire color scheme of the app
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
    @Environment(AppServiceManager.self) private var appService: AppServiceManager
    @State private var cancellable: AnyCancellable?
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
                Group {
                    switch appService.screenToDisplay {
                    case .noIcloud:
                        IcloudStatusMessageView()
                    case .noInternet:
                        InternetStatusMessageView(message: "This is required to create your profile or fetch it on this device")
                    case .main:
                        VStack {
                            Spacer()
                            ProgressView(value: appService.progress)
                            Text(appService.messages.last ?? "Nothing to worry!")
                            Spacer()
                                .onAppear {
                                    Task {
                                        Logger.serviceManager.debug("Attempting to start app services.")
                                        _ = await self.appService.start()
                                    }
                                }
                        }
                        .frame(width: 350)
                        .transition(.opacity)
                        .preferredColorScheme(colorSchemeManager.getPreferredColorScheme())
                    case .error:
                        Text("An error occured")
                    }
                }
                .handleNetworkChanges(onConnect:  {
                    Task {
                        Logger.serviceManager.debug("Attempting to start app services.")
                        _ = await self.appService.start()
                    }
                })
            }
        }.logLifecycle(viewName: "ContentView")
    }
}

#Preview {
    let jitDataService = JITDataService<JITDataType>()
    jitDataService.registerService(LeaderboardService(), forType: .leaderboard)
    jitDataService.registerService(AchievementsService(), forType: .achievements)
    
    return ViewPreview {
        ContentView()
            .environment(
                AppServiceManager(
                    audioService: AudioSessionService(),
                    profileDataService: ProfileDataService(),
                    jitData: jitDataService
                )
            )
    }
}
