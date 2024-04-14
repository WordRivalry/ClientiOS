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
    
    init() {
        debugPrint("~~~ ContentView init ~~~")
    }

    var body: some View {
        ZStack {
            Group {
                switch StartUpViewModel.shared.screen {
                case .noIcloud:
                    IcloudStatusMessageView()
                case .noInternet:
                    InternetStatusMessageView(message: "This is required to create your profile or fetch it on this device")
                case .loading:
                    loadingView
                case .main:
                    AppTabView(selection: $appScreen)
                        .environment(SYPData<MatchHistoric>())
                        .environment(LeaderboardService())
                        .environment(appService.profileDataService.ppLocal.player!)
                        .environment(appService.audioService)
                case .error:
                    Text("An error occured")
                }
            }
            .onAppear {
                Task {
                    Logger.serviceManager.debug("Attempting to start app services.")
                    _ = await self.appService.start()
                }
            }
        }
        .logLifecycle(viewName: "ContentView")
        .preferredColorScheme(colorSchemeManager.getPreferredColorScheme())
    }
    
    
    @ViewBuilder
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView(value: appService.progressReporter.progress, total: 100)
            Text(appService.messages.last ?? "Nothing to worry!")
            Spacer()
        }
        .frame(width: 350)
        .transition(.opacity)
    }
}

#Preview {
    let jitDataService = JITDataService<JITDataType>()
    jitDataService.registerService(LeaderboardService(), forType: .leaderboard)
   // jitDataService.registerService(MatchHistoryService(), forType: .matchHistoric)
    
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
