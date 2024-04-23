//
//  StartUpView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-20.
//

import SwiftUI


@Observable class MainRouter {
    var showTabScreen: Bool = true
}

struct MainContentView: View {
    @Environment(AppServiceManager.self) private var appService
    @State private var appScreen: AppScreen? = .home
    @State private var router = MainRouter()
    @State private var displaySettings = InGameDisplaySettings()
    
    var body: some View {
        Group {
            switch router.showTabScreen {
            case true:
                AppTabView(selection: $appScreen)
                    .environment(JITLeaderboard())
            case false:
                MatchView(profile: appService.myPublicProfile.publicProfile)
            }
        }
        .environment(appService.myPublicProfile)
        .environment(appService.myPersonalProfile)
        .environment(appService.audioService)
        .environment(router)
        .environment(displaySettings)
    }
}

#Preview {
    ViewPreview {
        MainContentView()
    }
}
