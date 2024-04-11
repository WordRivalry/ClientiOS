//
//  AppTabView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI
import os.log

struct AppTabView: View {
    private let logger = Logger(subsystem: "com.WordRivalry", category: "AppTabView")
    @Binding var selection: AppScreen?
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(AppScreen.allCases) { screen in
                screen.destination
                    .animation(.easeIn,value: selection)
                    .tag(screen as AppScreen?)
                    .tabItem { screen.label }
            }
        }
        .navigationBarColor(.white)
        .onAppear {
            self.logger.debug("*** AppTabView Appear ***")
        } 
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
    }
}



#Preview {
    ModelContainerPreview {
        previewContainer
    } content: {
        AppTabView(selection: .constant(.home))
            .environment(BattleOrchestrator(profile: PublicProfile.preview, modeType: .NORMAL))
            .environment(AppDataService.preview)
            .environment(PublicProfile.preview)
            .environment(Friends.preview)
            .environment(Profile.preview)
            .environment(AchievementsProgression.preview)
            .environment(LeaderboardService.preview)
    }
}

