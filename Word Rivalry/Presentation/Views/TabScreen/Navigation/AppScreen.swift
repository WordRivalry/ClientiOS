//
//  AppScreen.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI

enum AppScreen: Codable, Hashable, Identifiable, CaseIterable {
    case 
    case home
    case settings
    
    var id: AppScreen { self }
}

extension AppScreen {
    @ViewBuilder
    var label: some View {
        switch self {
        case .career:
            Image(systemName: "heart.fill")
        case .leaderboard:
            Image(systemName: "heart.fill")
        case .play:
            Image(systemName: "heart.fill")
        case .achievement:
            Image(systemName: "flag.filled.and.flag.crossed") // "flag.checkered")
        case .collection:
            Image(systemName: "gear")
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .career:
            HomeNavigationStack()
        case .leaderboard:
            BattleNavigationStack()
        case .play:
            SettingsView()
        case .achievement:
            SettingsView()
        case .collection:
            SettingsView()
        }
    }
}

#Preview {
    ViewPreview {
        AppScreen.play.label
    }
}
