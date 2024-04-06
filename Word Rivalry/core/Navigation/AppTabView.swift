//
//  AppTabView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI

struct AppTabView: View {
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
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
    }
}

#Preview {
    ModelContainerPreview {
        previewContainer
    } content: {
        AppTabView(selection: .constant(.home))
            .environment(Friends.preview)
            .environment(Profile.preview)
            .environment(AchievementsProgression.preview)
            .environment(LeaderboardService.preview)
    }
}

